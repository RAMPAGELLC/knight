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
local RemotesModule = ReplicatedStorage:WaitForChild("Knight", 30):WaitForChild("Services", 30):WaitForChild("Remotes", 30)
local Types = require(script:WaitForChild("Types"))

local KnightCore = require(KnightPackage)

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
		container = ReplicatedStorage:FindFirstChild("Knight") or ReplicatedStorage:WaitForChild("Knight", 5)
	end

	local Service = container:FindFirstChild(ServiceName, true)

	if isSharedService then
		if not Service or (Service ~= nil and Modules.Shared[ServiceName] == nil) then
			Log(Log.LEVEL.WARN, string.format("[Knight:%s:Info] %s is not a valid shared service.", self.RunType or "Unknown", ServiceName))

			return nil
		end
	else
		if not Service or (Service ~= nil and Modules[ServiceName] == nil) then
			Log(Log.LEVEL.WARN, string.format("[Knight:%s:Info] %s is not a valid service.", self.RunType or "Unknown", ServiceName))

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
		Log(Log.LEVEL.INFO, "Knight is waiting for server to load..")

		repeat
			task.wait()
		until ReplicatedStorage:GetAttribute("ServerLoaded")

		Log(Log.LEVEL.INFO, "Server has fully loaded! Starting client...")
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
	self.Shared = {}

	-- Lazy load shared environment to parallelize loading
	if not isShared then
		local KnightFolder = ReplicatedStorage:FindFirstChild("Knight") or ReplicatedStorage:WaitForChild("Knight", 5)
		local EnvInit = KnightFolder:FindFirstChild("EnvironmentInit") or KnightFolder:WaitForChild("EnvironmentInit", 5)
		self.Shared = require(EnvInit).new(true, KnightInternal)
	end

	self.Inited = false
	self.Internal = KnightInternal

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

	if Config.ENABLE_KNIGHTDOTREMOTES ~= nil and Config.ENABLE_KNIGHTDOTREMOTES or Config.ENABLE_KNIGHTDOTREMOTES == nil then
		if RemotesModule ~= nil and RemotesModule:IsA("ModuleScript") then
			local moduleStart, moduleStartupError, moduleResult = tick(), false, nil

			task.spawn(function()
				moduleResult = table.pack(pcall(require, RemotesModule))
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
				mod.Standalone = true
				self.Remotes = mod
			else
				Log(Log.LEVEL.WARN, `Failed to import Knight remotes due to: {mod}.`)
			end
		else
			warn("[Knight] KnightRemotes module not found in ReplicatedStorage.Knight.Services.Remotes, creating a new instance.")
			Log(Log.LEVEL.WARN, "Knight.Remotes link will not work as the framework failed to detect KnightRemotes script.")
		end
	end

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
		Modules[moduleName].CanStart = Modules[moduleName].CanStart ~= nil and Modules[moduleName].CanStart or true

		if type(module.Server) ~= "table" then
			Modules[moduleName].Server = {}
		end

		if type(module.Client) ~= "table" then
			Modules[moduleName].Client = {}
		end

		-- Exposed server functions API
		if not isShared and RunService:IsServer() then
			for EventName: string, EventFunction in pairs(Modules[moduleName].Client) do
				if typeof(EventFunction) ~= "function" then
					continue
				end

				assert(self.Remotes, "KnightRemotes must be enabled to use the Knight Exposed-server functions API.")

				self.Remotes:TwoWay("KCE:" .. moduleName .. ":" .. EventName, function(...)
					assert(Modules[moduleName].Client[EventName] ~= nil, `Exposed API '{EventName}' is no longer a valid function.`)
					return Modules[moduleName].Client[EventName](Modules[moduleName], ...)
				end)
			end
		else
			Modules[moduleName].Client = {}
		end

		-- Exposed client functions API
		if not isShared and RunService:IsClient() then
			Modules[moduleName].Server = setmetatable({}, {
				__index = function(_, serviceName: string)
					return setmetatable({}, {
						__index = function(_, eventName: string)
							assert(self.Remotes, "KnightRemotes must be enabled to use the Knight Exposed-server functions API.")

							return function(...)
								if self.Remotes:IsRegistered("KCE:" .. serviceName .. ":" .. eventName, true) then
									return self.Remotes:Fire("KCE:" .. serviceName .. ":" .. eventName, ...)
								else
									Log(
										Log.LEVEL.WARN,
										("'%s' is not an valid exposed function of service '%s' is not registered."):format(eventName, serviceName)
									)
									return nil
								end
							end
						end,
					})
				end,
			})
		end
	end

	-- Init modules
	local initTasks = {}
	local initResults = {}
	local initStartTimes = {}

	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local initMethod = Modules[moduleName].Init or Modules[moduleName].init

		if initMethod and typeof(initMethod) == "function" and Modules[moduleName].CanInit then
			initStartTimes[moduleName] = tick()
			initResults[moduleName] = { ok = nil, state = nil, errorReported = false }

			table.insert(
				initTasks,
				task.spawn(function()
					local ok, state = xpcall(initMethod, function(...)
						return ErrorHandler(self, Modules[moduleName].src, ...)
					end, Modules[moduleName])

					initResults[moduleName].ok = ok
					initResults[moduleName].state = state
				end)
			)
		end
	end

	-- Wait for all init tasks to complete (with timeout handling)
	local allComplete = false
	local checkStart = tick()

	while not allComplete and task.wait() do
		allComplete = true

		for moduleName, result in pairs(initResults) do
			if result.ok == nil then
				allComplete = false
				local elapsed = tick() - initStartTimes[moduleName]

				if elapsed >= Config.TOO_LONG_LOAD_TIME and not result.errorReported then
					result.errorReported = true
					Log(Log.LEVEL.WARN, `{moduleName}.luau is taking too long to run Service Init.`)
				end

				if result.errorReported or Config.DO_NOT_WAIT then
					-- Mark as complete to not block startup
					result.ok = true
					result.state = "SKIPPED_DUE_TO_TIMEOUT"
				end
			end
		end

		-- Safety timeout to prevent infinite loops
		if (tick() - checkStart) >= 60 then
			Log(Log.LEVEL.WARN, "Init phase exceeded maximum timeout, proceeding anyway.")
			break
		end
	end

	-- Process init results
	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local result = initResults[moduleName]

		if result then
			local elapsed = tick() - initStartTimes[moduleName]

			if Config.LOG_STARTUP_INFO or result.errorReported then
				Log(Log.LEVEL.INFO, `{moduleName}.luau Init() function completed after {tostring(elapsed)} second(s).`)
			end

			if not result.ok and result.state == nil then
				result.state = "UNKNOWN"
			end

			Modules[moduleName].Init = nil

			if not result.ok and result.state ~= "SKIPPED_DUE_TO_TIMEOUT" then
				local errorLog = `{moduleName}.luau failed Service Init due to: {result.state} {debug.traceback()}`
				Log(Log.LEVEL.ERROR, errorLog)
				self:Shutdown(true, errorLog)
			end
		end

		if Config.LOG_STARTUP_INFO then
			Log(Log.LEVEL.INFO, `{moduleName}.luau took {tostring(math.floor(tick() - Modules[moduleName].moduleStart))} second(s) to load completely.`)
		end
	end

	if initCanceled then
		Log(Log.LEVEL.WARN, string.format("[Knight:%s:Error] Init aborted for enivornment.", runType))
		return false
	end

	-- Start modules (parallel execution for better performance)
	local startTasks = {}
	local startResults = {}
	local startStartTimes = {}

	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local startMethod = Modules[moduleName].Start or Modules[moduleName].start

		if startMethod and typeof(startMethod) == "function" and Modules[moduleName].CanStart then
			startStartTimes[moduleName] = tick()
			startResults[moduleName] = { ok = nil, state = nil, errorReported = false }

			table.insert(
				startTasks,
				task.spawn(function()
					local ok, state = xpcall(startMethod, function(...)
						return ErrorHandler(self, Modules[moduleName].src, ...)
					end, Modules[moduleName])

					startResults[moduleName].ok = ok
					startResults[moduleName].state = state
				end)
			)
		end
	end

	-- Wait for all start tasks to complete (with timeout handling)
	local allComplete = false
	local checkStart = tick()

	while not allComplete and task.wait() do
		allComplete = true

		for moduleName, result in pairs(startResults) do
			if result.ok == nil then
				allComplete = false
				local elapsed = tick() - startStartTimes[moduleName]

				if elapsed >= Config.TOO_LONG_LOAD_TIME and not result.errorReported then
					result.errorReported = true
					Log(Log.LEVEL.WARN, `{moduleName}.luau is taking too long to run Service Start.`)
				end

				if result.errorReported or Config.DO_NOT_WAIT then
					-- Mark as complete to not block startup
					result.ok = true
					result.state = "SKIPPED_DUE_TO_TIMEOUT"
				end
			end
		end

		-- Safety timeout to prevent infinite loops
		if (tick() - checkStart) >= 60 then
			Log(Log.LEVEL.WARN, "Start phase exceeded maximum timeout, proceeding anyway.")
			break
		end
	end

	-- Process start results
	for moduleName: any, module: any in pairs(Modules) do
		if module.Standalone ~= nil and module.Standalone then
			continue
		end

		local result = startResults[moduleName]

		if result then
			local elapsed = tick() - startStartTimes[moduleName]

			if Config.LOG_STARTUP_INFO or result.errorReported then
				Log(Log.LEVEL.WARN, `{moduleName}.luau Start completed after {tostring(math.floor(elapsed))} second(s).`)
			end

			if not result.ok and result.state == nil then
				result.state = "UNKNOWN"
			end

			Modules[moduleName].Start = nil

			if not result.ok and result.state ~= "SKIPPED_DUE_TO_TIMEOUT" then
				local errorLog = `{moduleName}.luau failed Service Start due to: {result.state}.`
				Log(Log.LEVEL.ERROR, errorLog)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					self:Shutdown(true, errorLog)
				end
			end
		end
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
