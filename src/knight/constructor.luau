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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local KnightCore = {}

KnightCore.started = tick()
KnightCore.IsServer = RunService:IsServer()
KnightCore.runType = if KnightCore.IsServer then "Server" else "Client"
KnightCore.Version =
	`Knight Framework (v1.0.5) on Roblox {(RunService:IsStudio() and "Studio" or "Experience")} | Experience Version: {game.PlaceVersion} | Client Version: {version() or "unknown version"}>`

KnightCore.require = script.Parent.require
KnightCore.import = KnightCore.require
KnightCore.library = script.Parent:WaitForChild("library")
KnightCore.core = script.Parent:WaitForChild("core_class")
KnightCore.class = KnightCore.core
KnightCore.manifest = script.Parent:WaitForChild("manifest")

KnightCore.config = require(ReplicatedStorage:WaitForChild("KNIGHT_CONFIG"))
KnightCore.default_config = require(script.Parent:WaitForChild("default_config"))

for i, v in pairs(script.Parent.Parent:GetChildren()) do
	if v:IsA("ModuleScript") and v.Name ~= "knight" then
		KnightCore[v.Name] = require(v)
	end
end

return KnightCore
