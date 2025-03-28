--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2025 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

-- TODO: A massive code cleanup is required.

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knight = {}
local Modules = {}

local initCanceled: boolean = false
local IsClient = RunService:IsClient()
local runType = IsClient and "Client" or "Server"

local KnightPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knight")

local Maid = require(ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Objects"):WaitForChild("Maid"))
local manifestAPI = require(KnightPackage:WaitForChild("manifest"))
local Config = require(ReplicatedStorage:WaitForChild("KNIGHT_CONFIG"))

local Types = require(script:WaitForChild("Types"))
local InternalConfig = require(script:WaitForChild("InternalConfig"))

local function onError(child, err)
	local trace = debug.traceback(err, 2)
	local message = string.format(
		"[Knight:%s:Error] An error occurred in %s.lua:\n---- Stack trace ----\n%s",
		runType .. (Knight.IsShared and " (Shared)" or ""),
		child.Name,
		trace
	)

	task.spawn(error, message, 0)

	if RunService:IsServer() then
		Config.REPORT_FUNC(
			runType,
			("Report ID: %s.\nError: %s"):format(
				HttpService:GenerateGUID(false),
				message
			)
		)
	end

	return message
end

local function Shutdown(DoNotReport: boolean?, errorLog: string?)
	if DoNotReport == nil then
		DoNotReport = false
	end

	initCanceled = true

	warn("[Knight:Error] Framework failed to load, a code review is required!", debug.traceback())

	if RunService:IsStudio() then
		warn("Report Knight framework issues at https://github.com/RAMPAGELLC/knight.")
	else
		warn("Report code issues to the experience developer's please.")
	end

	local ReportID = HttpService:GenerateGUID(false)

	local Blur = Instance.new("BlurEffect")
	Blur.Size = 64
	Blur.Enabled = true
	Blur.Parent = Lighting

	local MinIndex = 999999999
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = Players.LocalPlayer.PlayerGui
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Archivable = false
	ScreenGui.Enabled = false
	ScreenGui.DisplayOrder = MinIndex

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.Position = UDim2.new(0.5, 0, 0.22, 0)
	ImageLabel.Size = UDim2.new(0, 425, 0, 425)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.Image = "rbxassetid://11782559813"
	ImageLabel.ScaleType = Enum.ScaleType.Fit
	ImageLabel.Parent = ScreenGui
	ImageLabel.ZIndex = MinIndex + 2

	local TextLabel = Instance.new("TextLabel")
	TextLabel.RichText = true
	TextLabel.TextWrapped = true
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.Parent = ScreenGui
	TextLabel.BackgroundColor3 = Color3.fromRGB(93, 34, 34)
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Visible = true
	TextLabel.TextStrokeTransparency = 0.2
	TextLabel.BackgroundTransparency = 0.2
	TextLabel.ZIndex = MinIndex + 1

	if IsClient then
		TextLabel.Text = DoNotReport and InternalConfig.ERR_EN_NO_REF_ID:format(tostring(Config.SHUTDOWN_KICK_DELAY))
			or string.format(InternalConfig.ERROR_EN_WITH_REF_ID, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)

		ScreenGui.Enabled = true

		for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
			TextLabel.Text = DoNotReport and InternalConfig.ERR_EN_NO_REF_ID:format(tostring(i))
				or string.format(InternalConfig.ERROR_EN_WITH_REF_ID, tostring(i), ReportID)
			task.wait(1)
		end

		Players.LocalPlayer:Kick("Knight framework error occured. Report ID: " .. ReportID)
	else
		local function p(v)
			TextLabel.Text = DoNotReport
					and InternalConfig.ERR_EN_NO_REF_ID:format(tostring(Config.SHUTDOWN_KICK_DELAY))
				or string.format(InternalConfig.ERROR_EN_WITH_REF_ID, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)

			ScreenGui.Enabled = true

			for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
				TextLabel.Text = DoNotReport and InternalConfig.ERR_EN_NO_REF_ID:format(tostring(i))
					or string.format(InternalConfig.ERROR_EN_WITH_REF_ID, tostring(i), ReportID)
				task.wait(1)
			end

			v:Kick("Knight framework error occured. Report ID: " .. ReportID)
		end

		for i, v in pairs(Players:GetPlayers()) do
			p(v)
		end

		Players.PlayerAdded:Connect(p)

		if not DoNotReport then
			Config.REPORT_FUNC(
				"Server",
				("Report ID: %s.\nError: %s\nTraceback: %s"):format(
					ReportID,
					errorLog or "Unknown error occured!",
					debug.traceback()
				)
			)
		end
	end
end

local function PackFramework(tab, folder)
	for _, child in pairs(folder:GetChildren()) do
		if child.Name == "Init" or child.Name == "EnvironmentInit" then
			continue
		end

		if CollectionService:HasTag(child, "KNIGHT_IGNORE") then
			continue
		end

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

			continue
		end

		if child:IsA("ModuleScript") then
			local moduleStart, moduleStartupError, moduleResult = tick(), false, nil

			if child.Name == "Internal" then
				tab = Knight["Services"]
			end

			task.spawn(function()
				local success, result = xpcall(function()
					return require(child)
				end, function(...)
					return onError(child, ...)
				end);

				moduleResult = { success, result }
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
						tostring(math.floor(tick() - moduleStart))
					)
				)
			end

			local success, mod = unpack(moduleResult)

			if not success then
				local errorLog = string.format(
					"[Knight:%s:Error] Failed to import library %s.lua due to:\n%s",
					runType,
					child.Name,
					mod
				)

				warn(errorLog)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					return Shutdown(true, errorLog)
				end
			end

			local name = (typeof(mod) == "table" and mod.ServiceName ~= nil and mod.ServiceName) or child.Name

			if Modules[name] ~= nil then
				warn(string.format(
					"[Knight:%s:Warning] A module with the name '%s' already exists in the environment. This may cause unexpected behavior and should be resolved.\nModule: %s\nPlease ensure each module has a unique ServiceName or use a different name for your module.",
					runType,
					child.Name,
					mod
				))
			end

			if typeof(mod) == "table" and not CollectionService:HasTag(child, "KNIGHT_IGNORE_MODULE") then
				mod.src = child;

				if Config.CYCLIC_INDEXING_ENABLED then
					for k: any, v: any in pairs(Knight) do
						if typeof(k) == "string" and k == "" then
							continue
						end

						if typeof(k) == "string" and k == "KnightCache" then
							continue
						end

						mod[k] = v
					end
				end

				if not Config.CYCLIC_INDEXING_ENABLED then
					for i, v in pairs(InternalConfig.CYCLIC_DISABLE_KEEP_INDEX) do
						mod[v] = Knight[v]
					end

					if Config.KEEP_SHARED_ON_CYCLIC_DISABLE then
						mod["Shared"] = Knight.Shared
					end
				end

				if mod.Priority == nil then
					mod.Priority = Config.STARTUP_PRIORITY[child.Parent.Name] ~= nil
							and Config.STARTUP_PRIORITY[child.Parent.Name]
						or InternalConfig.DEFAULT_STARTUP_PRIORITY
				end

				Modules[name] = mod
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

Knight.newKnightEnvironment = function(isShared: boolean, KnightInternal: Types.KnightInternal)
	local sRuntype = isShared and ("Shared:%s"):format(runType) or runType

	-- Setup Knight Dictionary
	Knight.IsShared = isShared
	Knight.Shared = not isShared
			and require(ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Init")).newKnightEnvironment(
				true,
				KnightInternal
			)
		or {}
	Knight.Inited = false
	Knight.initStart = tick()
	Knight.Enum = require(ReplicatedStorage:WaitForChild("KNIGHT_ENUM"))
	Knight.Player = RunService:IsClient() and Players.LocalPlayer or false
	Knight.Internal = KnightInternal
	Knight.KnightCache = { UpdateEvent = nil }
	Knight.Remotes = ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Services"):WaitForChild("Remotes")

	if Knight.Remotes ~= nil and Knight.Remotes:IsA("ModuleScript") then
		Knight.Remotes = require(Knight.Remotes)
	else
		warn(
			string.format(
				"[Knight:%s:Info] Knight.Remotes link will not work as the framework failed to detect KnightRemotes script.",
				sRuntype
			)
		)
	end

	-- Inject librarys
	for _, library: Folder in pairs(KnightPackage:WaitForChild("library"):GetChildren()) do
		local moduleStart, moduleStartupError, moduleResult = tick(), false, nil
		local manifest = library:FindFirstChild("manifest")

		if not manifest then
			warn(
				string.format(
					"[Knight:%s:Info] Failed to import library %s as it does not contain a 'manifest.lua'.",
					sRuntype,
					library.Name
				)
			)
			continue
		end

		if not manifest:IsA("ModuleScript") then
			warn(
				string.format(
					"[Knight:%s:Info] Failed to import library %s as manifest is not a 'ModuleScript'.",
					sRuntype,
					library.Name
				)
			)
			continue
		end

		task.spawn(function()
			moduleResult = table.pack(pcall(require, manifest))
		end)

		if moduleResult == nil then
			while moduleResult == nil and task.wait() do
				if (tick() - moduleStart) >= 20 and not moduleStartupError then
					warn(
						string.format(
							"[Knight:%s:Warning] KnightLibrary.%s.lua is taking too long to startup.",
							runType,
							library.Name
						)
					)
					moduleStartupError = true
				end
			end
		end

		if Config.LOG_STARTUP_INFO or moduleStartupError then
			print(
				string.format(
					"[Knight:%s:Info] KnightLibrary.%s.lua has loaded after %s second(s).",
					runType,
					library.Name,
					tostring(math.floor(tick() - moduleStart))
				)
			)
		end

		local success, mod = table.unpack(moduleResult)

		if not success then
			warn(
				string.format(
					"[Knight:%s:Error] Failed to import library KnightLibrary.%s.lua due to: %s.",
					runType,
					library.Name,
					mod
				)
			)

			continue
		end

		if typeof(mod) == "string" then
			warn(
				string.format(
					"[Knight:%s:Error] Failed to import library KnightLibrary.%s.lua due to: Manifest is a 'string', expected 'table'.",
					runType,
					library.Name
				)
			)

			continue
		end

		if manifestAPI.Validate(mod) == nil then
			warn(
				string.format(
					"[Knight:%s:Error] Failed to import library KnightLibrary.%s.lua due to: Manifest error.",
					runType,
					library.Name
				)
			)

			continue
		end

		-- Not allowed runtime.
		if mod.runtime ~= "Shared" and mod.runtime ~= runType then
			continue
		end

		if Knight[mod.library_name] ~= nil then
			warn(
				string.format(
					"[Knight:%s:Error] Failed to import library KnightLibrary.%s.lua due to: Something is already registered within Knight as %s.",
					runType,
					library.Name,
					mod.library_name
				)
			)
			continue
		end

		Knight[mod.library_name] = require(mod.src)

		if Config.LOG_STARTUP_INFO then
			print(
				string.format(
					"[Knight:%s:Log] Library KnightLibrary.%s.lua has been imported to environment.",
					runType,
					library.Name
				)
			)
		end
	end

	-- Runtime GetService
	function Knight:GetService(ServiceName: string): any
		local container = script.Parent
		local isSharedService = ServiceName:lower():find("shared/") ~= nil

		if isSharedService then
			ServiceName = ServiceName:sub(8)
			container = ReplicatedStorage:WaitForChild("Knight")
		end

		local Service = container:FindFirstChild(ServiceName, true)

		if isSharedService then
			if not Service or (Service ~= nil and Modules.Shared[ServiceName] == nil) then
				warn(string.format("[Knight:%s:Info] %s is not a valid shared service.", sRuntype, ServiceName))

				return nil
			end
		else
			if not Service or (Service ~= nil and Modules[ServiceName] == nil) then
				warn(string.format("[Knight:%s:Info] %s is not a valid service.", sRuntype, ServiceName))

				return nil
			end
		end

		if isSharedService then
			return Modules.Shared[ServiceName]
		end

		return Modules[ServiceName]
	end

	-- Load contents fully
	for i, folder in pairs(script.Parent:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		if Knight[folder.Name] == nil then
			Knight[folder.Name] = {}
		end

		PackFramework(Knight[folder.Name], folder)
	end

	if isShared then
		Knight.KnightCache.UpdateEvent = Knight.Objects.Event.new()
	else
		Knight.KnightCache.UpdateEvent = Knight.Shared.Objects.Event.new()
	end

	table.sort(Modules, function(module1, module2)
		return (module1.Priority or 1) < (module2.Priority or 1)
	end)

	-- Prepare modules
	for moduleName: any, module: any in pairs(Modules) do
		Modules[moduleName].moduleStart = tick()
		Modules[moduleName].internalMaid = Maid.new()

		Modules[moduleName].GetMemoryUsageKB = function()
			return gcinfo()
		end

		Modules[moduleName].GetMemoryUsageMB = function()
			return Modules[moduleName].GetMemoryUsageKB * 1024
		end

		Modules[moduleName].Unload = function()
			if Modules[moduleName].internalMaid ~= nil then
				Modules[moduleName].internalMaid:DoCleaning()
			end

			warn(string.format("%s.lua knight service has been stopped via 'Service.Unload()'.", moduleName))
			Modules[moduleName] = nil
		end

		Modules[moduleName].MemoryKBStart = Modules[moduleName].GetMemoryUsageKB()
		Modules[moduleName].CanInit = Modules[moduleName].CanInit ~= nil and Modules[moduleName].CanInit or true
		Modules[moduleName].CanUpdate = Modules[moduleName].CanUpdate ~= nil and Modules[moduleName].CanUpdate or true
		Modules[moduleName].CanStart = Modules[moduleName].CanStart ~= nil and Modules[moduleName].CanStart or true

		if type(module.Server) ~= "table" then
			Modules[moduleName].Server = {}
		end

		if type(module.Client) ~= "table" then
			Modules[moduleName].Client = {}
		end

		if not isShared and RunService:IsClient() then
			-- Introduction of AGF/Knit like remotes api.
			-- On the client you would do; self.Server.PointsService:GetLocalPoints() for example.

			local ServerRCE = {}

			ServerRCE.__index = function(self, serviceName: string)
				local RCE = {}

				RCE.__index = function(_, eventName: string)
					if Knight.Remotes:IsRegistered("KCE:" .. serviceName .. ":" .. eventName) then
						return function(...)
							return Knight.Remotes:Fire("KCE:" .. serviceName .. ":" .. eventName, ...)
						end
					else
						warn(
							("RemoteFunction '%s' is not an valid exposed function of service  '%s' is not registered."):format(
								eventName,
								serviceName
							)
						)
						return nil
					end
				end

				return setmetatable({}, RCE)
			end

			Modules[moduleName].Server = setmetatable({}, ServerRCE)
		end

		if not isShared and RunService:IsServer() then
			for EventName: string, EventFunction in pairs(Modules[moduleName].Client) do
				if typeof(EventFunction) ~= "function" then
					continue
				end

				Knight.Remotes:Register("KCE:" .. moduleName .. ":" .. EventName, "RemoteFunction", function(...)
					return Modules[moduleName].Client[EventName](Modules[moduleName], ...)
				end)
			end
		else
			Modules[moduleName].Client = {}
		end
	end

	-- Startup modules
	for moduleName: any, module: any in pairs(Modules) do
		if
			Modules[moduleName].Init ~= nil
			and typeof(Modules[moduleName].Init) == "function"
			and Modules[moduleName].CanInit
		then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = xpcall(Modules[moduleName].Init, function(...)
					return onError(Modules[moduleName].src, ...)
				end);
			end)

			while ok == nil and task.wait() do
				if (tick() - start) >= Config.TOO_LONG_LOAD_TIME and not errorReported then
					errorReported = true
					warn(
						string.format(
							"[Knight:%s:Warning] %s.lua is taking too long to run Service.Init().",
							sRuntype,
							moduleName
						)
					)
				end

				if errorReported or Config.DO_NOT_WAIT then
					print(
						string.format(
							"[Knight:%s:Info] %s.lua is taking too long, DO_NOT_WAIT FFlag is enabled, not waiting for module.",
							sRuntype,
							moduleName
						)
					)
					break
				end
			end

			if Config.LOG_STARTUP_INFO or errorReported then
				print(
					string.format(
						"[Knight:%s:Info] %s.lua Init() function completed after %s second(s).",
						sRuntype,
						moduleName,
						tostring(tick() - start)
					)
				)
			end

			if not ok and state == nil then
				state = "UNKNOWN"
			end
			if not ok and Config.DO_NOT_WAIT then
				ok = true
			end

			Modules[moduleName].Init = nil

			if not ok then
				local errorLog = string.format(
					"[Knight:%s:Error] %s.lua failed Service.Init() due to: %s %s.",
					sRuntype,
					moduleName,
					state,
					debug.traceback()
				)

				warn(errorLog)
				Shutdown(true, errorLog)
			end
		end

		if
			Modules[moduleName].Update ~= nil
			and typeof(Modules[moduleName].Update) == "function"
			and Modules[moduleName].CanUpdate
		then
			Modules[moduleName].internalMaid:GiveTask(
				Knight.KnightCache.UpdateEvent:Connect(Modules[moduleName].Update)
			)
		end

		if Config.LOG_STARTUP_INFO then
			print(
				string.format(
					"[Knight:%s:Info] %s.lua took %s second(s) to load completely.",
					sRuntype,
					moduleName,
					tostring(math.floor(tick() - Modules[moduleName].moduleStart))
				)
			)
		end
	end

	if initCanceled then
		warn(string.format("[Knight:%s:Error] Startup aborted for enivornment.", runType))
		return false
	end

	for moduleName: any, module: any in pairs(Modules) do
		if
			Modules[moduleName].Start ~= nil
			and typeof(Modules[moduleName].Start) == "function"
			and Modules[moduleName].CanStart
		then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = xpcall(Modules[moduleName].Start, function(...)
					return onError(Modules[moduleName].src, ...)
				end);
			end)

			while ok == nil and task.wait() do
				if (tick() - start) >= Config.TOO_LONG_LOAD_TIME and not errorReported then
					errorReported = true

					warn(
						string.format(
							"[Knight:%s:Warning] %s.lua is taking too long to run Service.Start().",
							sRuntype,
							moduleName
						)
					)
				end

				if errorReported or Config.DO_NOT_WAIT then
					print(
						string.format(
							"[Knight:%s:Info] %s.lua is taking too long, DO_NOT_WAIT FFlag is enabled, not waiting for module.",
							sRuntype,
							moduleName
						)
					)

					break
				end
			end

			if Config.LOG_STARTUP_INFO or errorReported then
				print(
					string.format(
						"[Knight:%s:Info] %s.lua Start() function completed after %s second(s).",
						sRuntype,
						moduleName,
						tostring(math.floor(tick() - start))
					)
				)
			end

			if not ok and state == nil then
				state = "UNKNOWN"
			end

			if not ok and Config.DO_NOT_WAIT then
				ok = true
			end

			Modules[moduleName].Start = nil

			if not ok then
				local errorLog = string.format(
					"[Knight:%s:Error] %s.lua failed Service.Start() due to: %s.",
					sRuntype,
					moduleName,
					state
				)

				warn(errorLog)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					Shutdown(true, errorLog)
				end
			end
		end
	end

	if Knight.KnightCache ~= nil then
		RunService.Heartbeat:Connect(function(deltaTime)
			if Knight.KnightCache.UpdateEvent == nil then
				return
			end

			Knight.KnightCache.UpdateEvent:Fire(deltaTime)
		end)
	end

	Knight.Inited = true

	print(
		string.format(
			"[Knight:%s:Info] %s.Knight.Init.lua took %s to startup. %s",
			sRuntype,
			isShared and "Shared" or runType,
			tostring(math.floor(tick() - Knight.initStart)),
			Config.TRACKBACK_ON_STARTUP_TOOK_TOO_LONG and debug.traceback() or ""
		)
	)

	return Knight
end

return Knight
