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
	["@"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["packages"] = ReplicatedStorage:WaitForChild("Packages", waitForChildTimeout),
	["shared"] = ReplicatedStorage:WaitForChild("Knight", waitForChildTimeout)
		:WaitForChild("Services", waitForChildTimeout),
}

local function waitForPath(root: Instance, path: string, timeout: number): Instance
	local current = root
	for segment in path:gmatch("[^/]+") do
		current = current:WaitForChild(segment, timeout)
	end
	return current
end

return function(target: string | Instance)
	-- Default Roblox require() functionality
	if typeof(target) == "Instance" then
		assert(target:IsA("ModuleScript"), "Target must be a ModuleScript")

		return require(target)
	end

	assert(typeof(target) == "string", "Target must be a string")
	assert(target ~= "", "Target cannot be an empty string")

	for alias, path in pairs(aliases) do
		alias = alias:lower()

		if target:lower():find(alias .. "/") then
			target = target:gsub("^" .. alias .. "/", "")
			assert(path, alias .. " folder not found in alias.")

			return require(waitForPath(path, target, waitForChildTimeout))
		end
	end

	if RunService:IsServer() then
		assert(ServerStorage:WaitForChild("Knight", waitForChildTimeout), "Knight folder not found in ServerStorage")
		return require(
			ServerStorage:WaitForChild("Knight", waitForChildTimeout)
				:WaitForChild("Services", waitForChildTimeout)
				:WaitForChild(target, waitForChildTimeout)
		)
	else
		assert(
			Players.LocalPlayer.PlayerScripts:WaitForChild("Knight", waitForChildTimeout),
			"Knight folder not found in PlayerScripts"
		)
		return require(
			Players.LocalPlayer.PlayerScripts
				:WaitForChild("Knight", waitForChildTimeout)
				:WaitForChild("Services", waitForChildTimeout)
				:WaitForChild(target, waitForChildTimeout)
		)
	end

	error("Invalid src target: " .. target)
end