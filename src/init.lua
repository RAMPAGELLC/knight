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

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local KnightCore = require(script.constructor)
local Log = require(script.core_class.Log)
local importer = require(script.require)

function KnightCore:DefineImportAliases(aliases: { [string]: any })
	importer("_defineAliases", aliases)
end

function KnightCore:PrintVersion()
	return Log(Log.LEVEL.INFO, KnightCore.Version)
end

function KnightCore:GetEnvironmentInit(IsShared: boolean | nil)
	if IsShared == nil then
		IsShared = false
	end

	if not ReplicatedStorage:WaitForChild("Knight"):FindFirstChild("EnvironmentInit") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Parent = ReplicatedStorage:WaitForChild("Knight")
	end

	local context = RunService:IsServer() and ServerStorage:WaitForChild("Knight") or Players.LocalPlayer.PlayerScripts:WaitForChild("Knight")

	if IsShared then
		context = ReplicatedStorage:WaitForChild("Knight")
	end

	if not context:FindFirstChild("EnvironmentInit") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Parent = context
	end

	return (context:WaitForChild("EnvironmentInit"))
end

return KnightCore
