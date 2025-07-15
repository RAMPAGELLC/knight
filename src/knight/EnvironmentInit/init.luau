--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2025 Meta Games LLC, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knight = {}
Knight.__index = Knight

local Modules = {}

local initCanceled: boolean = false
local IsClient = RunService:IsClient()
local runType = IsClient and "Client" or "Server"

local KnightPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("knight")
local Remotes = ReplicatedStorage:WaitForChild("Knight", 30):WaitForChild("Services", 30):WaitForChild("Remotes", 30)
local Types = require(script:WaitForChild("Types"))

local KnightCore = require(KnightPackage)
local manifestAPI = require(KnightCore.manifest)

local ErrorHandler = require(KnightCore.class.ErrorHandler)
local Log = require(KnightCore.class.Log)
local Packager = require(KnightCore.class.Packager)

local Maid = KnightCore.maid
local Config = KnightCore.config
local DefaultConfig = KnightCore.default_config

function Knight:Shutdown(DoNotReport: boolean?, errorLog: string?)
	warn(string.format("Knight is shutting down due to an error. %s", errorLog or "Unknown error occured!"))

	if DoNotReport == nil then
		DoNotReport = false
	end

	initCanceled = true

	Log(Log.LEVEL.FATAL, "An error occured while loading the framework.", debug.traceback())

	if RunService:IsStudio() then
		Log(Log.LEVEL.WARN, "Report Knight framework issues at https://github.com/RAMPAGELLC/knight.")
	else
		Log(Log.LEVEL.WARN, "Report code issues to the experience developer's please.")
	end

	local ReportID = HttpService:GenerateGUID(false)

	local Blur = Instance.new("BlurEffect")
	Blur.Size = 64
	Blur.Enabled = true
	Blur.Parent = Lighting

	if IsClient then
		self.ErrorPageState.text:set(
			DoNotReport and DefaultConfig.ERR_EN_NO_REF_ID:format(tostring(Config.SHUTDOWN_KICK_DELAY))
				or string.format(DefaultConfig.ERROR_EN_WITH_REF_ID, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)
		)

		self.ErrorPageState.enabled:set(true)

		for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
			self.ErrorPageState.text:set(
				DoNotReport and DefaultConfig.ERR_EN_NO_REF_ID:format(tostring(i)) or string.format(DefaultConfig.ERROR_EN_WITH_REF_ID, tostring(i), ReportID)
			)
			task.wait(1)
		end

		Players.LocalPlayer:Kick("An error occured with the Knight framework. Report ID: " .. ReportID)
	else
		local function p(v)
			v:Kick("An error occured with the Knight framework. Report ID: " .. ReportID)
		end

		for i, v in pairs(Players:GetPlayers()) do
			p(v)
		end

		Players.PlayerAdded:Connect(p)

		if not DoNotReport then
			pcall(function()
				error(("Error ID: %s - Error: %s\nTraceback: %s"):format(ReportID, errorLog or "Unknown error occured!", debug.traceback()))
			end)
		end
	end

	self = nil
end

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
			Log(Log.LEVEL.WARN, string.format("[Knight:%s:Info] %s is not a valid shared service.", self.RunType, ServiceName))

			return nil
		end
	else
		if not Service or (Service ~= nil and Modules[ServiceName] == nil) then
			Log(Log.LEVEL.WARN, string.format("[Knight:%s:Info] %s is not a valid service.", self.RunType, ServiceName))

			return nil
		end
	end

	if isSharedService then
		return Modules.Shared[ServiceName]
	end

	return Modules[ServiceName]
end

function Knight.new(isShared: boolean, KnightInternal: Types.KnightInternal)
	local self = setmetatable({}, Knight)

	if RunService:IsClient() and not ReplicatedStorage:GetAttribute("ServerLoaded") then
		Log(Log.LEVEL.INFO, "Knight is waiting for server to load.")

		repeat
			task.wait()
		until ReplicatedStorage:GetAttribute("ServerLoaded")

		Log(Log.LEVEL.INFO, "Server has fully loaded on the server!")
	end

	-- Setup Knight Dictionary
	self.IsShared = isShared

	if RunService:IsClient() and not isShared then
		self.Player = Players.LocalPlayer

		self.KnightGui = Instance.new("ScreenGui")
		self.KnightGui.Name = "KnightGui"
		self.KnightGui.Parent = self.Player:WaitForChild("PlayerGui")
		self.KnightGui.DisplayOrder = 1000

		self.ErrorPageState = {
			enabled = KnightCore.fusion.Value(false),
			text = KnightCore.fusion.Value(""),
		}

		self.ErrorPage = require(script.ErrorPage)(KnightCore.fusion, self.ErrorPageState)
		self.ErrorPage.Parent = self.KnightGui
	end

	self.RunType = ("Shared:%s"):format(runType) or runType
	self.Shared = not isShared and require(ReplicatedStorage:WaitForChild("Knight"):WaitForChild("KnightInit")).new(true, KnightInternal) or {}
	self.Inited = false
	self.Enum = require(ReplicatedStorage:WaitForChild("KNIGHT_ENUM"))
	self.Internal = KnightInternal
	self.KnightCache = { UpdateEvent = nil }

	if Config.ENABLE_KNIGHTDOTREMOTES ~= nil and Config.ENABLE_KNIGHTDOTREMOTES or Config.ENABLE_KNIGHTDOTREMOTES == nil then
		if Remotes ~= nil and Remotes:IsA("ModuleScript") then
			local moduleStart, moduleStartupError, moduleResult = tick(), false, nil

			task.spawn(function()
				moduleResult = table.pack(pcall(require, Remotes))
			end)

			if moduleResult == nil then
				while moduleResult == nil and task.wait() do
					if (tick() - moduleStart) >= 20 and not moduleStartupError then
						Log(Log.LEVEL.INFO, `Knight Remotes is taking too long to startup.`)
						moduleStartupError = true
					end
				end
			end

			if Config.LOG_STARTUP_INFO or moduleStartupError then
				Log(Log.LEVEL.INFO, `Knight Remotes has loaded after {tostring(math.floor(tick() - moduleStart))} second(s).`)
			end

			local success, mod = table.unpack(moduleResult)

			if success and mod then
				self.Remotes = mod
			else
				Log(Log.LEVEL.WARN, `Failed to import Knight remotes due to: {mod}.`)
			end
		else
			warn("[Knight] KnightRemotes module not found in ReplicatedStorage.Knight.Services.Remotes, creating a new instance.")
			Log(Log.LEVEL.WARN, "Knight.Remotes link will not work as the framework failed to detect KnightRemotes script.")
		end
	end

	-- Inject librarys
	if Config.INJECT_DEFAULT_LIBRARIES then
		for _, library: Folder in pairs(KnightCore.library:GetChildren()) do
			local moduleStart, moduleStartupError, moduleResult = tick(), false, nil
			local manifest = library:FindFirstChild("manifest")

			if not manifest then
				Log(Log.LEVEL.WARN, `Failed to import library %s as it does not contain a 'manifest.luau'.`)
				continue
			end

			if not manifest:IsA("ModuleScript") then
				Log(Log.LEVEL.WARN, `Failed to import library %s as manifest is not a 'ModuleScript'.`)
				continue
			end

			task.spawn(function()
				moduleResult = table.pack(pcall(require, manifest))
			end)

			if moduleResult == nil then
				while moduleResult == nil and task.wait() do
					if (tick() - moduleStart) >= 20 and not moduleStartupError then
						Log(Log.LEVEL.INFO, `KnightLibrary.{library.Name}.luau is taking too long to startup.`)
						moduleStartupError = true
					end
				end
			end

			if Config.LOG_STARTUP_INFO or moduleStartupError then
				Log(Log.LEVEL.INFO, `KnightLibrary.{library.Name}.luau has loaded after {tostring(math.floor(tick() - moduleStart))} second(s).`)
			end

			local success, mod = table.unpack(moduleResult)

			if not success then
				Log(Log.LEVEL.WARN, `Failed to import library KnightLibrary.{library.Name}.luau due to: {mod}.`)
				continue
			end

			if typeof(mod) == "string" then
				Log(Log.LEVEL.WARN, `Failed to import library KnightLibrary.{library.Name}.luau due to: Manifest is a 'string', expected 'table'.`)
				continue
			end

			if manifestAPI.Validate(mod) == nil then
				Log(Log.LEVEL.WARN, `Failed to import library KnightLibrary.{library.Name}.luau due to: Manifest error.`)
				continue
			end

			-- Not allowed runtime.
			if mod.runtime ~= "Shared" and mod.runtime ~= runType then
				continue
			end

			if Knight[mod.library_name] ~= nil then
				Log(
					Log.LEVEL.WARN,
					`Failed to import library KnightLibrary.{library.Name}.luau due to: Something is already registered within Knight as {mod.library_name}.`
				)
				continue
			end

			if mod.src ~= nil then
				Knight[mod.library_name] = require(mod.src)
			end

			if Config.LOG_STARTUP_INFO then
				Log(Log.LEVEL.INFO, `Library KnightLibrary.{library.Name}.luau has been imported to environment.`)
			end
		end
	end

	-- Load contents fully
	for i, folder in pairs(script.Parent:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		if not self[folder.Name] then
			self[folder.Name] = {}
		end

		Packager:Package(self, Modules, self[folder.Name], folder)
	end

	self.KnightCache.UpdateEvent = if isShared then self.Objects.Event.new() else self.Shared.Objects.Event.new()

	-- Automatic dependency priority; make sure the dependencies are loaded first.
	-- Module.Dependencies = { "Module1", "shared/Module2" }

	local visited = {}
	local priorityCounter = 0

	local function resolveDependencyPriority(moduleName: string, isSharedDependency: boolean?)
		isSharedDependency = isSharedDependency or false

		if visited[moduleName] then
			return
		end

		visited[moduleName] = true

		local module = isSharedDependency and Modules.Shared[moduleName] or Modules[moduleName]

		if not module then
			Log(Log.LEVEL.WARN, `{moduleName} is not a valid service.`)
			return
		end

		if module.Dependencies and type(module.Dependencies) == "table" then
			if #module.Dependencies == 0 then
				return
			end

			for _, dependencyName in ipairs(module.Dependencies) do
				local isSharedDependency2 = dependencyName:lower():find("shared/") ~= nil

				if dependencyName:lower():find("shared/") ~= nil then
					dependencyName = dependencyName:sub(8)
				end

				resolveDependencyPriority(dependencyName, isSharedDependency2)
			end
		end

		priorityCounter += 1
		(isSharedDependency and Modules.Shared[moduleName] or Modules[moduleName]).Priority = priorityCounter
	end

	for moduleName in pairs(Modules) do
		resolveDependencyPriority(moduleName)
	end

	visited = nil
	priorityCounter = nil

	-- Startup priority sorting, Sorted by highest to lowest.
	table.sort(Modules, function(a, b)
		return (a.Priority or 1) > (b.Priority or 1)
	end)

	-- Prepare modules
	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

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

			Log(Log.LEVEL.WARN, string.format("%s.luau knight service has been stopped via 'Service.Unload()'.", moduleName))
			Modules[moduleName] = nil
		end

		Modules[moduleName].Standalone = false
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

			Modules[moduleName].Server = setmetatable({}, {
				__index = function(_, serviceName: string)
					return setmetatable({}, {
						__index = function(_, eventName: string)
							assert(self.Remotes, "KnightRemotes must be enabled to use the Knight Exposed-server functions API.")

							if self.Remotes:IsRegistered("KCE:" .. serviceName .. ":" .. eventName) then
								return function(...)
									return self.Remotes:Fire("KCE:" .. serviceName .. ":" .. eventName, ...)
								end
							else
								Log(
									Log.LEVEL.WARN,
									("RemoteFunction '%s' is not an valid exposed function of service '%s' is not registered."):format(eventName, serviceName)
								)
								return nil
							end
						end,
					})
				end,
			})
		end

		if not isShared and RunService:IsServer() then
			for EventName: string, EventFunction in pairs(Modules[moduleName].Client) do
				if typeof(EventFunction) ~= "function" then
					continue
				end

				assert(self.Remotes, "KnightRemotes must be enabled to use the Knight Exposed-server functions API.")

				self.Remotes:Register("KCE:" .. moduleName .. ":" .. EventName, "RemoteFunction", function(...)
					assert(Modules[moduleName].Client[EventName] ~= nil, `Exposed API '{EventName}' is no longer a valid function.`)
					return Modules[moduleName].Client[EventName](Modules[moduleName], ...)
				end)
			end
		else
			Modules[moduleName].Client = {}
		end
	end

	-- Init modules
	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local initMethod = Modules[moduleName].Init or Modules[moduleName].init

		if initMethod and typeof(initMethod) == "function" and Modules[moduleName].CanInit then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = xpcall(initMethod, function(...)
					return ErrorHandler(self, Modules[moduleName].src, ...)
				end, Modules[moduleName])
			end)

			while ok == nil and task.wait() do
				if (tick() - start) >= Config.TOO_LONG_LOAD_TIME and not errorReported then
					errorReported = true
					Log(Log.LEVEL.WARN, `{moduleName}.luau is taking too long to run Service Init.`)
				end

				if errorReported or Config.DO_NOT_WAIT then
					Log(Log.LEVEL.INFO, `{moduleName}.luau is taking too long, DO_NOT_WAIT FFlag is enabled, not waiting for module.`)
					break
				end
			end

			if Config.LOG_STARTUP_INFO or errorReported then
				Log(Log.LEVEL.INFO, `{moduleName}.luau Init() function completed after {tostring(tick() - start)} second(s).`)
			end

			if not ok and state == nil then
				state = "UNKNOWN"
			end
			if not ok and Config.DO_NOT_WAIT then
				ok = true
			end

			Modules[moduleName].Init = nil

			if not ok then
				local errorLog = `{moduleName}.luau failed Service Init due to: {state} {debug.traceback()}`
				Log(Log.LEVEL.ERROR, errorLog)
				self:Shutdown(true, errorLog)
			end
		end

		if Modules[moduleName].Update ~= nil and typeof(Modules[moduleName].Update) == "function" and Modules[moduleName].CanUpdate then
			Modules[moduleName].internalMaid:GiveTask(self.KnightCache.UpdateEvent:Connect(Modules[moduleName].Update))
		end

		if Config.LOG_STARTUP_INFO then
			Log(Log.LEVEL.INFO, `{moduleName}.luau took {tostring(math.floor(tick() - Modules[moduleName].moduleStart))} second(s) to load completely.`)
		end
	end

	if initCanceled then
		Log(Log.LEVEL.WARN, string.format("[Knight:%s:Error] Init aborted for enivornment.", runType))
		return false
	end

	-- Start modules
	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local startMethod = Modules[moduleName].Start or Modules[moduleName].start

		if startMethod and typeof(startMethod) == "function" and Modules[moduleName].CanStart then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = xpcall(startMethod, function(...)
					return ErrorHandler(self, Modules[moduleName].src, ...)
				end, Modules[moduleName])
			end)

			while ok == nil and task.wait() do
				if (tick() - start) >= Config.TOO_LONG_LOAD_TIME and not errorReported then
					errorReported = true
					Log(Log.LEVEL.WARN, `{moduleName}.luau is taking too long to run Service Start.`)
				end

				if errorReported or Config.DO_NOT_WAIT then
					Log(Log.LEVEL.INFO, `{moduleName}.luau is taking too long, DO_NOT_WAIT FFlag is enabled, not waiting for module.`)
					break
				end
			end

			if Config.LOG_STARTUP_INFO or errorReported then
				Log(Log.LEVEL.WARN, `{moduleName}.luau Start completed after {tostring(math.floor(tick() - start))} second(s).`)
			end

			if not ok and state == nil then
				state = "UNKNOWN"
			end

			if not ok and Config.DO_NOT_WAIT then
				ok = true
			end

			Modules[moduleName].Start = nil

			if not ok then
				local errorLog = `{moduleName}.luau failed Service Start due to: {state}.`
				Log(Log.LEVEL.ERROR, errorLog)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					self:Shutdown(true, errorLog)
				end
			end
		end
	end

	if self.KnightCache ~= nil then
		RunService.Heartbeat:Connect(function(deltaTime)
			if self.KnightCache.UpdateEvent == nil then
				return
			end
			self.KnightCache.UpdateEvent:Fire(deltaTime)
		end)
	end

	self.Inited = true

	Log(
		Log.LEVEL.INFO,
		`Knight.Init.luau{isShared and " (Shared) " or " "}took {("%.2f"):format((tick() - KnightCore.started))} second(s) to startup.{Config.TRACKBACK_ON_STARTUP_TOOK_TOO_LONG and debug.traceback() or ""}`
	)

	if RunService:IsServer() and not ReplicatedStorage:GetAttribute("ServerLoaded") then
		ReplicatedStorage:SetAttribute("ServerLoaded", true)
	end

	if RunService:IsClient() and not ReplicatedStorage:GetAttribute("ClientLoaded") then
		ReplicatedStorage:SetAttribute("ClientLoaded", true)
	end

	return self
end

return Knight
