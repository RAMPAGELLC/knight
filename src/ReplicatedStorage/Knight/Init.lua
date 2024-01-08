local repStor = game:GetService("ReplicatedStorage")

local folder = script.Parent

local directory = {}
directory["Knight"] = {}
directory[game:GetService("RunService"):IsServer() and "Server" or "Client"] = {}
directory.Inited = false

local modules = {}

local function PackFolder(tab, folder)
	for i, child in pairs(folder:GetChildren()) do
		if child:IsA("Folder") then
			tab[child.Name] = PackFolder(
				setmetatable({}, {
					__call = function(t)
						return child
					end
				}),
				child
			)
		elseif child:IsA("ModuleScript") then
			local mod = require(child)

			if typeof(mod) == "table" then
				for k, v in pairs(directory) do
					mod[k] = v
				end

				if mod.Init and not script:FindFirstChild("KnightInited") then
					mod:Init()
					mod.Init = nil
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

return function(RuntypeServices, KnightCore)
	directory.Knight = KnightCore;
	
	for i, folder in pairs(folder:GetChildren()) do
		if folder:IsA("Folder") then
			directory[folder.Name] = {}
		end
	end
	
	for i, folder in pairs(folder:GetChildren()) do
		if folder:IsA("Folder") then
			PackFolder(directory[folder.Name], folder)
		end
	end

	if not script:FindFirstChild("KnightInited") then
		for i, mod in ipairs(modules) do
			if mod.Start then
				spawn(function()
					mod:Start()
					mod.Start = nil
				end)
			end
		end
	end
	
	for i, v in pairs(RuntypeServices) do
		directory[game:GetService("RunService"):IsServer() and "Server" or "Client"][i] = v
	end

	directory.Inited = true;
	
	if not script:FindFirstChild("KnightInited") then
		local KnightInited = Instance.new("Configuration", script)
		KnightInited.Name = "KnightInited"
	end
	
	return directory
end