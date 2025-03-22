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
    local external = require(ReplicatedStorage.SomeModule)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

return function(target: string | Instance)
	-- Default Roblox require() functionality
	if typeof(target) == "Instance" then
		assert(target:IsA("ModuleScript"), "Target must be a ModuleScript")

		return require(target)
	end

	assert(typeof(target) == "string", "Target must be a string")

	-- Custom functionality for Knight
	if target:lower():find("package/") then
		target = target:gsub("package/", "")

		assert(ReplicatedStorage:FindFirstChild("Packages"), "Packages folder not found in ReplicatedStorage")

		return require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild(target))
	end

	if target:lower():find("shared/") then
		assert(ReplicatedStorage:FindFirstChild("Knight"), "Knight folder not found in ReplicatedStorage")

		return require(ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Services"):WaitForChild(target))
	end

	if RunService:IsServer() then
		assert(ServerStorage:FindFirstChild("Knight"), "Knight folder not found in ServerStorage")
		return require(ServerStorage:WaitForChild("Knight"):WaitForChild("Services"):WaitForChild(target))
	else
		assert(Players.LocalPlayer.PlayerScripts:FindFirstChild("Knight"), "Knight folder not found in PlayerScripts")
		return require(
			Players.LocalPlayer.PlayerScripts:WaitForChild("Knight"):WaitForChild("Services"):WaitForChild(target)
		)
	end

	error("Invalid src target: " .. target)
end
