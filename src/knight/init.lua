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

function KnightCore:GetShared()
	warn(
		string.format(
			"[Knight:%s:Error] Knight.Core:GetShared() is deprecated, please use Knight.Core:GetStorage(IsShared: boolean | nil).",
			KnightCore.runType
		)
	)
	return KnightCore:GetStorage(true)
end

function KnightCore:GetStorage(IsShared: boolean | nil)
	if IsShared == nil then
		IsShared = false
	end

	local context = RunService:IsServer() and ServerStorage:WaitForChild("Knight") or Players.LocalPlayer.PlayerScripts:WaitForChild("Knight")

	if IsShared then
		context = ReplicatedStorage:WaitForChild("Knight")
	end

	if not context:FindFirstChild("KnightInit") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Name = `KnightInit`
		EnvironmentInit.Parent = context
	end

	return require(context:WaitForChild("KnightInit"))
end

function KnightCore:Init()
	if not ReplicatedStorage:WaitForChild("Knight"):FindFirstChild("KnightInit") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Name = `KnightInit`
		EnvironmentInit.Parent = ReplicatedStorage:WaitForChild("Knight")
	end

	local Storage = KnightCore:GetStorage()
	local RuntypeServices = Storage.new(false, KnightCore)
	local Shared = RuntypeServices.Shared

	if KnightCore.config.GLOBAL_API_ENABLED then
		_G.Knight = {}
		_G.Knight.API = RuntypeServices
		_G.Knight.API.Shared = Shared
		_G.Knight.Internal = KnightCore
	end

	return KnightCore, _G.Knight ~= nil and _G.Knight.API or RuntypeServices
end

KnightCore.Core = {}

KnightCore.Core.Init = function(...)
	Log(Log.LEVEL.WARN, "KnightCore.Core has been deprecated in v1.0.5, please use KnightCore:Init() instead.")
	return KnightCore:Init(...)
end

return KnightCore
