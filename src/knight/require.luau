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

 Addons:
 Knight Script Profiler (KSP): https://github.com/RAMPAGELLC/KnightProfiler/tree/main
 Knight Package Manager (KPM): https://github.com/RAMPAGELLC/KnightPackageManager

 Links:
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

-- Example usage:

--[[
    local require = require(require..src)

    local module = require("shared/module")
    local somePackage = require("package/module")
    local somePackage2 = require("@/module")
    local external = require(ReplicatedStorage.SomeModule)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local waitForChildTimeout = 5

local aliases = {
	["core"] = require(script.Parent.constructor),
	["@"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["packages"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["shared"] = ReplicatedStorage:WaitForChild("Knight", waitForChildTimeout):WaitForChild("Services", waitForChildTimeout),
}

local function waitForPath(root: Instance, path: string, timeout: number): Instance
	local current = root
	for segment in path:gmatch("[^/]+") do
		current = current:WaitForChild(segment, timeout)
	end
	return current
end

-- Exporting only specific methods/variables of a module.
-- i.e: local New, Value = require("@/Fusion", {"New", "Value"}) would only provide New & Value from Fusion.
local function export(module: any, exports: table?): any
	-- If not exports or the module is returning a non-table (i.e: a Instance or function), return the module.
	if typeof(module) ~= "table" or not exports then
		return module
	end
	
	assert(typeof(exports) == "table", "Exports must be a table")

	local exported = {}

	for i,v in pairs(exports) do
		local value = module[v];
		assert(value, `Module Export '{v}' not found in module`)
		table.insert(exported, value)
	end
	
	return unpack(exported)
end

return function(target: string | Instance, exports: table?): any
	-- Default Roblox require() functionality
	if typeof(target) == "Instance" then
		assert(target:IsA("ModuleScript"), "Target must be a ModuleScript")

		return require(target)
	end

	assert(typeof(target) == "string", "Target must be a string")
	assert(target ~= "", "Target cannot be an empty string")

	for alias, source in pairs(aliases) do
		local aliasLower = alias:lower()
		if target:lower():find(aliasLower .. "/") then
			local path = target:gsub("^" .. aliasLower .. "/", "")
			assert(source, alias .. " alias not found")

			if typeof(source) == "Instance" then
				if source:IsA("Folder") then
					return export(require(waitForPath(source, path, waitForChildTimeout)), exports)
				elseif source:IsA("ModuleScript") then
					return export(require(source), exports)
				else
					error(`Alias '{alias}' points to unsupported Instance type`)
				end
			elseif typeof(source) == "table" then
				local current = source
				for segment in path:gmatch("[^/]+") do
					current = current[segment]
					assert(current, `Module '{segment}' not found in alias '{alias}'`)
				end

				if typeof(current) == "Instance" and current:IsA("ModuleScript") then
					return export(require(current), exports)
				end
				
				return export(current, exports)
			else
				error(`Alias '{alias}' must be an Instance or table`)
			end
		end
	end

	-- Fallback to `Knight/Services/` / `Knight/Controllers/` if not found in aliases
	local knightRoot = if RunService:IsServer()
		then ServerStorage:WaitForChild("Knight", waitForChildTimeout)
		else Players.LocalPlayer.PlayerScripts:WaitForChild("Knight", waitForChildTimeout)
	assert(knightRoot, "Knight folder not found")

	local contianer = knightRoot:FindFirstChild("Services") or knightRoot:FindFirstChild("Controllers")
	assert(contianer, "Knight Services or Controllers folder not found")

	return export(require(contianer:WaitForChild(target, waitForChildTimeout)), exports)
end;