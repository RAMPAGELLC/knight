local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SharedKnight = ReplicatedStorage:WaitForChild("Knight")
local Knight = {}
local Services = {}

local IsClient = RunService:IsClient();
local runType = IsClient and "Client" or "Server";
local Config = require(ReplicatedStorage:WaitForChild("KNIGHT_CONFIG"))

local initCanceled = false;

local errorString = [[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue has been automatically reported based on the experience privacy settings, however please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font> <br /><br /><br /><font face="GothamMedium" size="35">KNIGHT ERROR REPORT REFERENCE ID:</font><br /><font face="Jura" size="55">%s</font>]]
local errorString2 = [[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue originated from a custom-class, please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font>]]

local function Shutdown(DoNotReport: boolean|nil)
	if DoNotReport == nil then DoNotReport = false end

	initCanceled = true
	warn("[Knight:Error] Framework failed to load, a code review is required!")
	if RunService:IsStudio() then warn("Report Knight framework issues at https://github.com/RAMPAGELLC/knight.") else warn("Report code issues to the experience developer's please.") end

	local ReportID = "Idk something";

	if IsClient then
		Players.LocalPlayer.PlayerGui:ClearAllChildren()
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = Players.LocalPlayer.PlayerGui
		ScreenGui.Enabled = true
		ScreenGui.DisplayOrder = 69999

		local TextLabel = Instance.new("TextLabel")
		TextLabel.RichText = true
		TextLabel.TextWrapped = true
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.Parent = ScreenGui
		TextLabel.BackgroundColor3 = Color3.fromRGB(93, 34, 34)
		TextLabel.Text = DoNotReport and errorString2:format(tostring(Config.SHUTDOWN_KICK_DELAY)) or string.format(errorString, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)
		TextLabel.Size = UDim2.new(1,0,1,0)
		TextLabel.Visible = true

		for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
			TextLabel.Text = DoNotReport and errorString2:format(tostring(i)) or string.format(errorString, tostring(i), ReportID)
			task.wait(1)
		end
		Players.LocalPlayer:Kick("Knight framework error occured.")
	else
		local function p(v)
			v.PlayerGui:ClearAllChildren()

			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Parent = v.PlayerGui
			ScreenGui.Enabled = true
			ScreenGui.DisplayOrder = 69999
	
			local TextLabel = Instance.new("TextLabel")
			TextLabel.RichText = true
			TextLabel.TextWrapped = true
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.Parent = ScreenGui
			TextLabel.BackgroundColor3 = Color3.fromRGB(93, 34, 34)
			TextLabel.Text = DoNotReport and errorString2:format(tostring(Config.SHUTDOWN_KICK_DELAY)) or string.format(errorString, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)
			TextLabel.Size = UDim2.new(1,0,1,0)
			TextLabel.Visible = true

			for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
				TextLabel.Text = DoNotReport and errorString2:format(tostring(i)) or string.format(errorString, tostring(i), ReportID)
				task.wait(1)
			end

			v:Kick("Knight framework error occured.")
		end

		for i, v in pairs(Players:GetPlayers()) do
			p(v)
		end

		Players.PlayerAdded:Connect(p)
	end
end

local function PackFramework(tab, folder)
	for i, child in pairs(folder:GetChildren()) do
		if child:IsA("Folder") then
			tab[child.Name] = PackFramework(
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
					end,
				}),
				child
			)
		elseif child:IsA("ModuleScript") then
			local moduleStart, moduleStartupError, moduleResult = tick(), false, nil

			if child.Name == "Internal" then
				tab = Knight["Services"]
			end

			task.spawn(function()
				moduleResult = table.pack(pcall(require, child))
			end)

			while moduleResult == nil and task.wait() do
				if (tick() - moduleStart) >= 20 and not moduleStartupError then
					warn(
						string.format("[Knight:%s:Warning] %s.lua is taking too long to startup.", runType, child.Name)
					)
					moduleStartupError = true
				end
			end

			if Config.LOG_STARTUP_INFO or moduleStartupError then
				print(
					string.format(
						"[Knight:%s:Info] %s.lua has loaded after %s second(s).",
						runType,
						child.Name,
						tostring(tick() - moduleStart)
					)
				)
			end

			local success, mod = table.unpack(moduleResult)

			if not success then
				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					Shutdown(true)
				end
				warn(
					string.format(
						"[Knight:%s:Error] Failed to import library %s.lua due to: %s.",
						runType,
						child.Name,
						mod
					)
				)
			end

			local name = (typeof(mod) == "table" and mod.ServiceName ~= nil and mod.ServiceName) or child.Name;

			if typeof(mod) == "table" and not CollectionService:HasTag(child, "KNIGHT_IGNORE_MODULE") then
				for k, v in pairs(Knight) do
					mod[k] = v
				end

				Services[name] = mod
			end

			tab[name] = mod
		elseif child:IsA("ValueBase") then
			tab[child.Name] = child.Value
		else
			tab[child.Name] = child
		end
	end

	return tab
end

Knight.InitKnight = function(RuntypeServices: any, KnightInternal: any)
	local initStart = tick()

	-- Load contents
	for i, folder in pairs(script.Parent:GetChildren()) do
		if folder:IsA("Folder") then
			Knight[folder.Name] = {}
		end
	end

	-- Setup Knight Dictionary
	Knight.Inited = false
	Knight.Shared = {}
	Knight.Enum = require(ReplicatedStorage:WaitForChild("KNIGHT_ENUM"));
	Knight.Types = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"));
	Knight.Player = RunService:IsClient() and Players.LocalPlayer or false;
	Knight.Internal = KnightInternal
	Knight.Knight = Knight.Internal -- LEAVING IN 0.0.8-prod;
	Knight.KnightCache = {
		UpdateEvent = nil,
	}

	setmetatable(Knight.Knight, {
		__index = function(table, key)
			warn(string.format("[Knight:%s:Error] Knight.Knight is deprecated, please use Knight.Internal.", runType))
			return rawget(table, key)
		end,
		__newindex = function(table, key, value)
			warn(string.format("[Knight:%s:Error] Knight.Knight is deprecated, please use Knight.Internal.", runType))
			rawset(table, key, value)
		end,
	})

	-- Init Shared & Cache
	if RuntypeServices then
		for i, v in pairs(RuntypeServices) do
			if Knight[runType] == nil then
				Knight[runType] = {}
			end
			Knight[runType][i] = v
		end
	else
		Knight.Shared = require(SharedKnight:WaitForChild("Init")).InitKnight(Knight, KnightInternal)
	end

	-- Load contents fully
	for i, folder in pairs(script.Parent:GetChildren()) do
		if folder:IsA("Folder") then
			PackFramework(Knight[folder.Name], folder)
		end
	end

	if RuntypeServices then
		Knight.KnightCache.UpdateEvent = Knight.Objects.Event.new()
	else
		Knight.KnightCache.UpdateEvent = Knight.Shared.Objects.Event.new()
	end

	-- Startup services
	task.spawn(function()
		repeat
			task.wait(0.1)

			if tick() - initStart > 15 then
				Shutdown()
				break
			end
		until _G.Knight ~= nil or initCanceled

		if initCanceled then
			return
		end

		repeat
			task.wait(0.1)
			if tick() - initStart > 15 then
				Shutdown()
				break
			end
		until _G.Knight.API ~= nil or initCanceled

		if initCanceled then
			return
		end

		for moduleName: string | number, module: any in pairs(Services) do
			module.moduleStart = tick()
			module.GetMemoryUsageKB = function()
				return gcinfo()
			end

			module.MemoryKBStart = module.GetMemoryUsageKB()

			if module.Init ~= nil and typeof(module.Init) == "function" then
				local start, ok, state, errorReported = tick(), nil, nil, false

				task.spawn(function()
					ok, state = pcall(module.Init, module)
				end)

				while ok == nil and task.wait() do
					if (tick() - start) >= 20 and not errorReported then
						errorReported = true
						warn(
							string.format(
								"[Knight:%s:Warning] %s.lua is taking too long to run Service.Init().",
								runType,
								moduleName
							)
						)
					end
				end

				if Config.LOG_STARTUP_INFO or errorReported then
					print(
						string.format(
							"[Knight:%s:Info] %s.lua Init() function completed after %s second(s).",
							runType,
							moduleName,
							tostring(tick() - start)
						)
					)
				end

				if not ok then
					Shutdown(true)
					warn(
						string.format(
							"[Knight:%s:Error] %s.lua failed Service.Init() due to: %s.",
							runType,
							moduleName,
							state
						)
					)
				end
			end

			if module.Update ~= nil and typeof(module.Update) == "function" then
				Knight.KnightCache.UpdateEvent:Connect(module.Update)
			end

			module.CleanupKnight = function()
				module = nil
				print(string.format("%s.lua knight service has been stopped.", moduleName))
			end

			if Config.LOG_STARTUP_INFO then
				print(
					string.format(
						"[Knight:%s:Info] %s.lua took %s second(s) to load completely.",
						runType,
						moduleName,
						tostring(tick() - module.moduleStart)
					)
				)
			end
		end
	end)

	if initCanceled then
		warn(string.format("[Knight:%s:Error] Startup aborted for enivornment.", runType))
		return false
	end

	if Knight.KnightCache ~= nil then
		RunService.Heartbeat:Connect(function(deltaTime)
			Knight.KnightCache.UpdateEvent:Fire(deltaTime)
		end)
	end
	
	for moduleName: string | number, module: any in pairs(Services) do
		if module.Start ~= nil and typeof(module.Start) == "function" then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = pcall(module.Start, module)
			end)

			while ok == nil and task.wait() do
				if (tick() - start) >= 20 and not errorReported then
					errorReported = true
					warn(
						string.format(
							"[Knight:%s:Warning] %s.lua is taking too long to run Service.Start().",
							runType,
							moduleName
						)
					)
				end
			end

			if Config.LOG_STARTUP_INFO or errorReported then
				print(
					string.format(
						"[Knight:%s:Info] %s.lua Start() function completed after %s second(s).",
						runType,
						moduleName,
						tostring(tick() - start)
					)
				)
			end

			if not ok then
				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					Shutdown(true)
				end

				warn(
					string.format(
						"[Knight:%s:Error] %s.lua failed Service.Start() due to: %s.",
						runType,
						moduleName,
						state
					)
				)
			end
		end
	end

	Knight.Inited = true

	if not script:FindFirstChild("KnightInited") then
		local KnightInited = Instance.new("Configuration", script)
		KnightInited.Name = "KnightInited"
	end

	print(
		string.format(
			"[Knight:%s:Info] %s.Knight.Init.lua took %s to startup.",
			runType,
			Knight.Shared ~= nil and runType or "Shared",
			tostring(tick() - initStart)
		)
	)

	return Knight
end

return Knight
