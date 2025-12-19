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

 Addons:
 Knight Script Profiler (KSP): https://github.com/RAMPAGELLC/KnightProfiler/tree/main


 Links:
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

--[[
USAGE EXAMPLES:

	-- Import the custom require function from Knight:
	local require = require(path.to.src)

	-- Require a module from the shared Knight Services folder:
	local sharedModule = require("shared/MyServiceModule")

	-- Require a module from a package in ReplicatedStorage.Packages:
	local fusion = require("@/Fusion")

	-- Require a nested module inside a package:
	local deepModule = require("@/Fusion/SubModule/EvenDeeper")

	-- Require a module from ReplicatedStorage.Packages directly:
	local somePackage = require("packages/SomePackageModule")

	-- Require a module from Knight's Objects folder:
	local objectModule = require("objects/SomeObjectModule")

	-- Require a module from ServerPackages (server only):
	local serverModule = require("@s/ServerOnlyModule")

	-- Require a module from a Knight Services/Controllers (supports nested paths):
	local controller = require("ClientGui/Prefabs/Animations/CardPopin")

	-- Require a ModuleScript instance directly:
	local external = require(ReplicatedStorage:WaitForChild("SomeModule"))

	-- Export only specific members from a module:
	local New, Value = require("@/Fusion", {"New", "Value"})

	-- Dynamically define new aliases:
	require("_defineAliases", { ["custom"] = ReplicatedStorage:WaitForChild("CustomFolder") })
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = if RunService:IsServer() then game:GetService("ServerStorage") else nil

local waitForChildTimeout = 5

local knightRoot = if RunService:IsServer()
	then ServerStorage:WaitForChild("Knight", waitForChildTimeout)
	else Players.LocalPlayer.PlayerScripts:WaitForChild("Knight", waitForChildTimeout)

assert(knightRoot, "Knight folder not found!")

local aliases = {
	["core"] = require(script.Parent.constructor),
	["@"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["@s"] = if RunService:IsServer()
		then ServerStorage:WaitForChild("ServerPackages", waitForChildTimeout)
		else ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["packages"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["shared"] = ReplicatedStorage:WaitForChild("Knight", waitForChildTimeout):WaitForChild("Services", waitForChildTimeout),
	["objects"] = knightRoot:WaitForChild("Objects", waitForChildTimeout),
}

local function waitForPath(root: Instance, path: string): Instance
	local current = root
	for segment in path:gmatch("[^/]+") do
		current = current:FindFirstChild(segment)
		if not current then
			error(`waitForPath: Segment '{segment}' not found in '{root:GetFullName()}' for path '{path}'`)
		end
	end
	return current
end

-- Exporting only specific methods/variables of a module.
-- i.e: local New, Value = require("@/Fusion", {"New", "Value"}) would only provide New & Value from Fusion.
local function export(module: any, exports: table?): any
	-- If not exports or the module is returning a non-table (i.e: a Instance or function), return the module variable.
	if typeof(module) ~= "table" or not exports then
		return module
	end

	assert(typeof(exports) == "table", "Exports must be a table")

	local exported = {}

	for i, v in pairs(exports) do
		local value = module[v]
		if value == nil then
			error(`Export error: Module export '{v}' not found in module. Available keys: {table.concat(table.keys(module), ", ")}`)
		end
		table.insert(exported, value)
	end

	return unpack(exported)
end

return function(target: string | Instance, exports: table?): any
	if target == "_defineAliases" then
		assert(exports and typeof(exports) == "table", "_defineAliases requires a table of aliases")

		for alias, source in pairs(exports) do
			assert(typeof(alias) == "string" and alias ~= "", `Alias definition error: Alias must be a non-empty string, got '{alias}'`)
			aliases[alias] = source
		end

		return
	end

	-- Standard Roblox require()
	if typeof(target) == "Instance" then
		if not target:IsA("ModuleScript") then
			error(`Require error: Target Instance '{target:GetFullName()}' is not a ModuleScript (type: {target.ClassName})`)
		end
		local ok, result = pcall(require, target)
		if not ok then
			error(`Require error: Failed to require ModuleScript at Instance '{target:GetFullName()}': {result}`)
		end
		return export(result, exports)
	end

	if typeof(target) ~= "string" or target == "" then
		error(`Require error: Target must be a non-empty string or ModuleScript, got '{typeof(target)}'`)
	end

	for alias, source in pairs(aliases) do
		local aliasLength = #alias
		if target:sub(1, aliasLength + 1):lower() == (alias:lower() .. "/") then
			local path = target:sub(aliasLength + 2)
			if not source then
				error(`Alias error: Alias '{alias}' is not defined. Check your alias definitions.`)
			end

			local result
			if typeof(source) == "Instance" then
				if source:IsA("Folder") then
					local targetInstance = waitForPath(source, path)
					if not targetInstance or not targetInstance:IsA("ModuleScript") then
						error(
							`Require error: Path '{path}' under alias '{alias}' did not resolve to a ModuleScript (got {targetInstance and targetInstance.ClassName or "nil"})`
						)
					end
					local success, moduleOrErr = pcall(function()
						return require(targetInstance)
					end)
					if not success then
						error(`Require error: Failed to require module at path '{path}' under alias '{alias}': {moduleOrErr}`)
					end
					result = moduleOrErr
				elseif source:IsA("ModuleScript") then
					local ok, val = pcall(require, source)
					if not ok then
						error(`Require error: Failed to require module for alias '{alias}': {val}`)
					end
					result = val
				else
					error(`Alias error: Alias '{alias}' points to unsupported instance type: {source.ClassName}`)
				end
			elseif typeof(source) == "table" then
				local current = source
				for segment in path:gmatch("[^/]+") do
					if typeof(current) == "table" then
						current = current[segment]
					elseif typeof(current) == "Instance" then
						current = current:FindFirstChild(segment)
					else
						error(`Alias error: Cannot index segment '{segment}' in alias '{alias}': expected table or Instance, got {typeof(current)}`)
					end
					if not current then
						error(`Alias error: Module segment '{segment}' not found in alias '{alias}' for path '{path}'.`)
					end
				end
				if typeof(current) == "Instance" and current:IsA("ModuleScript") then
					local ok, result = pcall(require, current)
					if not ok then
						error(`Require error: Failed to require ModuleScript at alias '{alias}': {result}`)
					end
					return export(result, exports)
				elseif typeof(current) == "table" then
					return export(current, exports)
				else
					error(`Alias error: Resolved object in alias '{alias}' is neither a ModuleScript nor a table (got {typeof(current)}) for path '{path}'.`)
				end
			else
				error(`Alias error: Alias '{alias}' must be an Instance or table, got: {typeof(source)}`)
			end

			return export(result, exports)
		end
	end

	-- Fallback: treat target as a path under Services or Controllers, supporting nested paths
	local fallbackContainer = knightRoot:FindFirstChild("Services") or knightRoot:FindFirstChild("Controllers")
	if not fallbackContainer then
		error("Fallback error: No 'Services' or 'Controllers' folder found in Knight root for fallback resolution.")
	end

	local segments = {}
	for segment in target:gmatch("[^/]+") do
		table.insert(segments, segment)
	end

	local current = fallbackContainer
	for i, segment in ipairs(segments) do
		current = current:FindFirstChild(segment)
		if not current then
			error(
				`Fallback error: Module segment '{segment}' not found in fallback container for path '{target}'. Container: '{current and current:GetFullName() or fallbackContainer:GetFullName()}'`
			)
		end
	end
	if not current:IsA("ModuleScript") then
		error(`Fallback error: Target '{target}' in fallback container is not a ModuleScript (type: {current.ClassName})`)
	end
	local success, finalModule = pcall(function()
		return require(current)
	end)
	if not success then
		error(`Fallback error: Failed to fallback-require '{target}' from Knight root: {finalModule}`)
	end
	return export(finalModule, exports)
end
