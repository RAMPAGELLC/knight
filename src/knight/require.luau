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
 Knight Package Manager (KPM): https://github.com/RAMPAGELLC/KnightPackageManager

 Links:
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

-- Example usage:

--[[
    local require = require(path.to.src)

    local module = require("shared/module")
    local somePackage = require("package/module")
    local somePackage2 = require("@/module")
    local external = require(ReplicatedStorage.SomeModule)
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
		current = current:WaitForChild(segment, waitForChildTimeout)
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
		assert(value, `Module Export '{v}' not found in module`)
		table.insert(exported, value)
	end

	return unpack(exported)
end

return function(target: string | Instance, exports: table?): any
	if target == "_defineAliases" then
		assert(exports and typeof(exports) == "table", "_defineAliases requires a table of aliases")

		for alias, source in pairs(exports) do
			assert(typeof(alias) == "string" and alias ~= "", "Alias must be a non-empty string")
			aliases[alias] = source
		end

		return
	end

	-- Standard Roblox require()
	if typeof(target) == "Instance" then
		if not target:IsA("ModuleScript") then
			error(`Target Instance '{target:GetFullName()}' is not a ModuleScript`)
		end

		local ok, result = pcall(require, target)
		if not ok then
			error(`Failed to require ModuleScript at Instance '{target:GetFullName()}': {result}`)
		end

		return export(result, exports)
	end

	if typeof(target) ~= "string" or target == "" then
		error("Target must be a non-empty string or ModuleScript")
	end

	for alias, source in pairs(aliases) do
		local aliasLength = #alias
		if target:sub(1, aliasLength + 1):lower() == (alias:lower() .. "/") then
			local path = target:sub(aliasLength + 2)
			if not source then
				error(`Alias '{alias}' is not defined`)
			end

			local result
			if typeof(source) == "Instance" then
				if source:IsA("Folder") then
					local success, moduleOrErr = pcall(function()
						return require(waitForPath(source, path))
					end)
					if not success then
						error(`Failed to require module at path '{path}' under alias '{alias}': {moduleOrErr}`)
					end
					result = moduleOrErr
				elseif source:IsA("ModuleScript") then
					local ok, val = pcall(require, source)
					if not ok then
						error(`Failed to require module for alias '{alias}': {val}`)
					end
					result = val
				else
					error(`Alias '{alias}' points to unsupported instance type: {source.ClassName}`)
				end
			elseif typeof(source) == "table" then
				local current = source
				for segment in path:gmatch("[^/]+") do
					if typeof(current) == "table" then
						current = current[segment]
					elseif typeof(current) == "Instance" then
						current = current:FindFirstChild(segment)
					else
						error(`Cannot index segment '{segment}' in alias '{alias}': expected table or Instance, got {typeof(current)}`)
					end

					if not current then
						error(`Module segment '{segment}' not found in alias '{alias}'`)
					end
				end

				if typeof(current) == "Instance" and current:IsA("ModuleScript") then
					local ok, result = pcall(require, current)
					if not ok then
						error(`Failed to require ModuleScript at alias '{alias}': {result}`)
					end
					return export(result, exports)
				elseif typeof(current) == "table" then
					return export(current, exports)
				else
					error(`Resolved object in alias '{alias}' is neither a ModuleScript nor a table (got {typeof(current)})`)
				end
			else
				error(`Alias '{alias}' must be an Instance or table, got: {typeof(source)}`)
			end

			return export(result, exports)
		end
	end

	-- Fallback to Services or Controllers
	local fallbackContainer = knightRoot:FindFirstChild("Services") or knightRoot:FindFirstChild("Controllers")
	if not fallbackContainer then
		error("No 'Services' or 'Controllers' folder found in Knight root for fallback resolution")
	end

	local success, finalModule = pcall(function()
		return require(fallbackContainer:WaitForChild(target, waitForChildTimeout))
	end)

	if not success then
		error(`Failed to fallback-require '{target}' from Knight root: {finalModule}`)
	end

	return export(finalModule, exports)
end
