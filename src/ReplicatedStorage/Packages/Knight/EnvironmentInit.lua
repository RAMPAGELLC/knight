local repStor = game:GetService("ReplicatedStorage")

local Knight = script.Parent

local directory = {Inited = false, Shared={}}
local modules = {}

local function PackFolder(tab, folder)
	for i, child in pairs(folder:GetChildren()) do
		if child:IsA("Folder") then
			tab[child.Name] = PackFolder(
				setmetatable({}, {
					__index = function(t, i)
						if rawget(t, i) then
							return t[i]
						else
							local success, val = pcall(function()
								return child[i]
							end)

							if success then
								return val
							end
						end
					end,
					__call = function(t)
						return child
					end
				}),
				child
			)
		elseif child:IsA("ModuleScript") then
			if child.Name == "Internal" then -- override internal knight scripts into services
				tab = directory["Services"]
			end
			
			local mod = require(child)

			if typeof(mod) == "table" then
				for k, v in pairs(directory) do
					mod[k] = v
				end

				modules[#modules + 1] = mod
			end

			tab[typeof(mod) == "table" and mod.ServiceName ~= nil and mod.ServiceName or child.Name] = mod
		elseif child:IsA("ValueBase") then
			tab[child.Name] = child.Value
		else
			tab[child.Name] = child
		end
	end
	return tab
end

directory.InitKnight = function(KnightInternal)
	for i, folder in pairs(Knight:GetChildren()) do
		if folder:IsA("Folder") then
			directory[folder.Name] = {}
		end
	end
	
	directory.Inited = true
	directory.Knight = KnightInternal
	directory.Internal = KnightInternal
	directory.Shared = require(repStor:WaitForChild("Knight"):WaitForChild("Init"))(directory, KnightInternal)
	directory.KnightCache = {
		UpdateEvent = directory.Shared.Objects.Event.new()
	}
	
	for i, folder in pairs(Knight:GetChildren()) do
		if folder:IsA("Folder") then
			PackFolder(directory[folder.Name], folder)
		end
	end

	task.spawn(function()
		repeat
			task.wait(1)
		until _G.Knight ~= nil
		
		repeat
			task.wait(1)
		until _G.Knight.API ~= nil
		
		for i, mod in ipairs(modules) do
			if mod.Init then mod:Init() end
			if mod.Start then task.spawn(mod.Start) end
			
			if mod.Update then
				directory.KnightCache.UpdateEvent:Connect(function(deltaTime)
					mod.Update(deltaTime)
				end)
			end
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		directory.KnightCache.UpdateEvent:Fire(deltaTime)
	end)
	
	return directory
end

return directory