--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2024 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.vq9o.com
]]

-- TODO: A massive code cleanup is required.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knight = {}
local Modules = {}

local IsClient = RunService:IsClient()
local runType = IsClient and "Client" or "Server"

local KnightPackage = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knight");
local manifestAPI = require(KnightPackage:WaitForChild("manifest"))
local Config = require(ReplicatedStorage:WaitForChild("KNIGHT_CONFIG"))

local initCanceled = false

local errorString =
	[[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue has been automatically reported based on the experience privacy settings, however please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font> <br /><br /><br /><font face="GothamMedium" size="35">KNIGHT ERROR REPORT REFERENCE ID:</font><br /><font face="Jura" size="55">%s</font>]]
local errorString2 =
	[[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue originated from a custom-class, please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font>]]

export type KnightInternal = any -- to-be-done.

local function Shutdown(DoNotReport: boolean | nil)
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

	local ReportID = "Idk something"

	if IsClient then
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
		TextLabel.Text = DoNotReport and errorString2:format(tostring(Config.SHUTDOWN_KICK_DELAY))
			or string.format(errorString, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)
		TextLabel.Size = UDim2.new(1, 0, 1, 0)
		TextLabel.Visible = true
		TextLabel.BackgroundTransparency = 0.7

		for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
			TextLabel.Text = DoNotReport and errorString2:format(tostring(i))
				or string.format(errorString, tostring(i), ReportID)
			task.wait(1)
		end
		--Players.LocalPlayer:Kick("Knight framework error occured.")
	else
		local function p(v)
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
			TextLabel.Text = DoNotReport and errorString2:format(tostring(Config.SHUTDOWN_KICK_DELAY))
				or string.format(errorString, tostring(Config.SHUTDOWN_KICK_DELAY), ReportID)
			TextLabel.Size = UDim2.new(1, 0, 1, 0)
			TextLabel.Visible = true
			TextLabel.BackgroundTransparency = 0.7

			for i = Config.SHUTDOWN_KICK_DELAY, 1, -1 do
				TextLabel.Text = DoNotReport and errorString2:format(tostring(i))
					or string.format(errorString, tostring(i), ReportID)
				task.wait(1)
			end

			--	v:Kick("Knight framework error occured.")
		end

		for i, v in pairs(Players:GetPlayers()) do
			p(v)
		end

		Players.PlayerAdded:Connect(p)
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
				moduleResult = table.pack(pcall(require, child))
			end)

			if moduleResult == nil then
				while moduleResult == nil and task.wait() do
					if (tick() - moduleStart) >= 20 and not moduleStartupError then
						warn(
							string.format(
								"[Knight:%s:Warning] %s.lua is taking too long to startup.",
								runType,
								child.Name
							)
						)
						moduleStartupError = true
					end
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
				warn(
					string.format(
						"[Knight:%s:Error] Failed to import library %s.lua due to: %s.",
						runType,
						child.Name,
						mod
					)
				)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					return Shutdown(true)
				end
			end

			local name = (typeof(mod) == "table" and mod.ServiceName ~= nil and mod.ServiceName) or child.Name

			if typeof(mod) == "table" and not CollectionService:HasTag(child, "KNIGHT_IGNORE_MODULE") then
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
				else
					mod["Player"] = Knight.Player;
					mod["Enum"] = Knight.Enum;
					mod["initStart"] = Knight.initStart;
					mod["Inited"] = Knight.Inited;
					mod["KnightCache"] = Knight.KnightCache;
					mod["GetService"] = Knight.GetService;

					if Config.KEEP_SHARED_ON_CYCLIC_DISABLE then
						mod["Shared"] = Knight.Shared;
					end
				end

				if mod.Priority == nil then
					mod.Priority = Config.STARTUP_PRIORITY[child.Parent.Name] ~= nil and Config.STARTUP_PRIORITY[child.Parent.Name] or 1;
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

Knight.newKnightEnvironment = function(isShared: boolean, KnightInternal: KnightInternal)
	local sRuntype = isShared and ("Shared:%s"):format(runType) or runType

	-- Setup Knight Dictionary
	Knight.Shared = not isShared
			and require(ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Init")).newKnightEnvironment(true, KnightInternal)
		or {}
	Knight.Inited = false
	Knight.initStart = tick()
	Knight.Enum = require(ReplicatedStorage:WaitForChild("KNIGHT_ENUM"))
	Knight.Player = RunService:IsClient() and Players.LocalPlayer or false
	Knight.Internal = KnightInternal
	Knight.KnightCache = { UpdateEvent = nil }

	for _, library: Folder in pairs(KnightPackage:WaitForChild("library"):GetChildren()) do
		local moduleStart, moduleStartupError, moduleResult = tick(), false, nil;
		local manifest = library:FindFirstChild("manifest")

		if not manifest then
			warn(
				string.format(
					"[Knight:%s:Info] Failed to import library %s as it does not contain a 'manifest.lua'.",
					sRuntype,
					library.Name
				)
			)
			continue;
		end

		if not manifest:IsA("ModuleScript") then
			warn(
				string.format(
					"[Knight:%s:Info] Failed to import library %s as manifest is not a ModuleScript.",
					sRuntype,
					library.Name
				)
			)
			continue;
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
					tostring(tick() - moduleStart)
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

			continue;
		end


		if manifestAPI.Validate(mod) == nil then
			warn(
				string.format(
					"[Knight:%s:Error] Failed to import library KnightLibrary.%s.lua due to: Manifest error.",
					runType,
					library.Name
				)
			)

			continue;
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
			continue;
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

	Knight.GetService = function(ServiceName: string): any
		local Service = script.Parent:FindFirstChild(ServiceName, true)

		if not Service or (Service ~= nil and Modules[ServiceName] == nil) then
			warn(
				string.format(
					"[Knight:%s:Info] %s is not a valid service.",
					sRuntype,
					ServiceName
				)
			)
		
			return nil;
		end

		return Modules[ServiceName];
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

	-- Startup modules
	for moduleName: any, module: any in pairs(Modules) do
		module.moduleStart = tick()
		module.GetMemoryUsageKB = function()
			return gcinfo()
		end

		module.Unload = function()
			module = nil
			print(string.format("%s.lua knight service has been stopped.", moduleName))
		end

		module.MemoryKBStart = module.GetMemoryUsageKB()
		module.CanInit = module.CanInit ~= nil and module.CanInit or true
		module.CanUpdate = module.CanUpdate ~= nil and module.CanUpdate or true
		module.CanStart = module.CanStart ~= nil and module.CanStart or true

		if module.Init ~= nil and typeof(module.Init) == "function" and module.CanInit then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = pcall(module.Init)
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

			if not ok then
				warn(
					string.format(
						"[Knight:%s:Error] %s.lua failed Service.Init() due to: %s %s.",
						sRuntype,
						moduleName,
						state,
						debug.traceback()
					)
				)
				Shutdown(true)
			end
		end

		if module.Update ~= nil and typeof(module.Update) == "function" and module.CanUpdate then
			--	Knight.KnightCache.UpdateEvent:Connect(module.Update)
		end

		if Config.LOG_STARTUP_INFO then
			print(
				string.format(
					"[Knight:%s:Info] %s.lua took %s second(s) to load completely.",
					sRuntype,
					moduleName,
					tostring(tick() - module.moduleStart)
				)
			)
		end
	end

	if initCanceled then
		warn(string.format("[Knight:%s:Error] Startup aborted for enivornment.", runType))
		return false
	end

	for moduleName: any, module: any in pairs(Modules) do
		if module.Start ~= nil and typeof(module.Start) == "function" and module.CanStart then
			local start, ok, state, errorReported = tick(), nil, nil, false

			task.spawn(function()
				ok, state = pcall(module.Start)
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

			if not ok then
				warn(
					string.format(
						"[Knight:%s:Error] %s.lua failed Service.Start() due to: %s.",
						sRuntype,
						moduleName,
						state
					)
				)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					Shutdown(true)
				end
			end
		end
	end

	if Knight.KnightCache ~= nil then
		RunService.Heartbeat:Connect(function(deltaTime)
			if Knight.KnightCache.UpdateEvent == nil then return; end
			Knight.KnightCache.UpdateEvent:Fire(deltaTime)
		end)
	end

	Knight.Inited = true;

	print(
		string.format(
			"[Knight:%s:Info] %s.Knight.Init.lua took %s to startup. %s",
			sRuntype,
			isShared and "Shared" or runType,
			tostring(tick() - Knight.initStart),
			debug.traceback()
		)
	)

	return Knight
end

return Knight