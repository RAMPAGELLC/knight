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
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local require = require(script.Parent.Parent.require)

local Config = require("core/config")
local DefaultConfig = require("core/default_config")
local ErrorHandler = require("core/class/ErrorHandler")

local IsClient = RunService:IsClient()
local runType = IsClient and "Client" or "Server"

local FrameworkPackager = {}

function FrameworkPackager:Package(Knight, Modules, tab, folder)
	-- Create metatable for the tab
	setmetatable(tab, {
		__index = function(t, k)
			-- Check raw table first
			if rawget(t, k) then
				local value = rawget(t, k)
				-- Wrap functions to preserve self
				if type(value) == "function" then
					return function(...)
						return value(t, ...)
					end
				end
				return value
			end

			-- Try to find in folder
			local child = folder:FindFirstChild(k)
			if child then
				if child:IsA("ModuleScript") then
					-- Lazy load modules
					local result = require(child)
					-- Store raw result
					rawset(t, k, result)
					-- But return wrapped if function
					if type(result) == "function" then
						return function(...)
							return result(t, ...)
						end
					end
					return result
				end
				return child
			end
			return nil
		end,
	})

	for _, child in pairs(folder:GetChildren()) do
		if child.Name == "KnightInit" or child.Name == "EnvironmentInit" then
			continue
		end

		if CollectionService:HasTag(child, "KNIGHT_IGNORE") then
			continue
		end

		if child:IsA("Folder") then
			tab[child.Name] = FrameworkPackager:Package(
				Knight,
				Modules,
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
				tab = Knight["Services"] or Knight["Controllers"] or tab
			end

			task.spawn(function()
				local success, result = xpcall(function()
					local mod = require(child)
					if type(mod) == "table" then
						if table.isfrozen(mod) or child:HasTag("KnightStandalone") then
							return mod
						end

						if mod.Standalone ~= nil and mod.Standalone == true then
							return mod
						end

						-- Create proper metatable with self reference
						setmetatable(mod, {
							__index = function(t, k)
								-- Check Knight framework methods first
								if Knight[k] then
									return Knight[k]
								end
								-- Check self methods
								if rawget(t, k) then
									if type(rawget(t, k)) == "function" then
										-- Bind self to functions
										return function(...)
											return rawget(t, k)(t, ...)
										end
									end
									return rawget(t, k)
								end
								return nil
							end,
						})
					end
					return mod
				end, function(...)
					return ErrorHandler(Knight, child, ...)
				end)

				moduleResult = { success, result }
			end)

			while moduleResult == nil and task.wait() do
				if (tick() - moduleStart) >= 20 and not moduleStartupError then
					warn(string.format("[Knight:%s:Warning] %s.lua is taking too long to startup.", runType, child.Name))
					moduleStartupError = true
				end
			end

			if Config.LOG_STARTUP_INFO or moduleStartupError then
				print(string.format("[Knight:%s:Info] %s.lua has loaded after %s second(s).", runType, child.Name, tostring(math.floor(tick() - moduleStart))))
			end

			local success, mod = unpack(moduleResult)

			if not success then
				local errorLog = string.format("[Knight:%s:Error] Failed to import library %s.lua due to:\n%s", runType, child.Name, mod)

				warn(errorLog)

				if Config.SHUTDOWN_ON_LIBRARY_FAIL then
					return Knight:Shutdown(true, errorLog)
				end
			end

			local name = (typeof(mod) == "table" and mod.ServiceName ~= nil and mod.ServiceName) or child.Name

			if Modules[name] ~= nil then
				warn(
					string.format(
						"[Knight:%s:Warning] A module with the name '%s' already exists in the environment. This may cause unexpected behavior and should be resolved.\nModule: %s\nPlease ensure each module has a unique ServiceName or use a different name for your module.",
						runType,
						child.Name,
						child.Name
					)
				)
			end

			if typeof(mod) == "table" and not CollectionService:HasTag(child, "KNIGHT_IGNORE_MODULE") then
				if not table.isfrozen(mod) then
					mod.src = child
				end

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
					for i, v in pairs(DefaultConfig.CYCLIC_DISABLE_KEEP_INDEX) do
						mod[v] = Knight[v]
					end

					if Config.KEEP_SHARED_ON_CYCLIC_DISABLE then
						mod["Shared"] = Knight.Shared
					end
				end

				if mod.Priority == nil then
					mod.Priority = Config.STARTUP_PRIORITY[child.Parent.Name] ~= nil and Config.STARTUP_PRIORITY[child.Parent.Name]
						or DefaultConfig.DEFAULT_STARTUP_PRIORITY
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

return FrameworkPackager
