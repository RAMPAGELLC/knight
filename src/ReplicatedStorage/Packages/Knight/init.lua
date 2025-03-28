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

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(script.Parent.Parent:WaitForChild("KNIGHT_CONFIG"))

local Knight = {
	["IsServer"] = RunService:IsServer(),
	["Version"] = "<v1.0.0-dev> KNIGHT FRAMEWORK on Roblox "
		.. (RunService:IsStudio() and "Studio" or "Experience")
		.. " | Experience Version: "
		.. version(),
	["Core"] = {},
	["runType"] = RunService:IsClient() and "Client" or "Server",
}

function Knight.Core.Error(...)
	warn("[Knight Framework] [ERROR] [" .. Knight.Version .. "]", ..., debug.traceback())
end

function Knight.Core.Log(...)
	warn("[Knight Framework] [LOG] [" .. Knight.Version .. "]", ...)
end

function Knight:PrintVersion()
	Knight.Core.Log(Knight.Version)
end

function Knight.Core:GetShared()
	warn(
		string.format(
			"[Knight:%s:Error] Knight.Core:GetShared() is deprecated, please use Knight.Core:GetStorage(IsShared: boolean | nil).",
			Knight.runType
		)
	)

	return Knight.Core:GetStorage(true)
end

function Knight.Core:GetStorage(IsShared: boolean | nil)
	if IsShared == nil then
		IsShared = false
	end

	local context = RunService:IsServer() and ServerStorage:WaitForChild("Knight")
		or Players.LocalPlayer.PlayerScripts:WaitForChild("Knight")

	if IsShared then
		context = ReplicatedStorage:WaitForChild("Knight")
	end

	if not context:FindFirstChild("Init") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Name = "Init"
		EnvironmentInit.Parent = context
	end

	return require(context:WaitForChild("Init"))
end

function Knight.Core:Init()
	if not ReplicatedStorage:WaitForChild("Knight"):FindFirstChild("Init") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Name = "Init"
		EnvironmentInit.Parent = ReplicatedStorage:WaitForChild("Knight")
	end

	local Storage = Knight.Core:GetStorage()
	local RuntypeServices = Storage.newKnightEnvironment(false, Knight)
	local Shared = RuntypeServices.Shared

	if Config.GLOBAL_API_ENABLED then
		_G.Knight = {}
		_G.Knight.API = RuntypeServices
		_G.Knight.API.Shared = Shared
		_G.Knight.Internal = Knight
	end

	return Knight, _G.Knight ~= nil and _G.Knight.API or RuntypeServices
end

return Knight