--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2024 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT

 Addons:
 Knight Script Profiler (KSP): https://github.com/RAMPAGELLC/KnightProfiler/tree/main
 Knight Package Manager (KPM): https://github.com/RAMPAGELLC/KnightPackageManager

 Links:
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.vq9o.com
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Knight = {
	["IsServer"] = RunService:IsServer(),
	["Version"] = "<v0.0.8-dev> KNIGHT FRAMEWORK on Roblox "
		.. (RunService:IsStudio() and "Studio" or "Experience")
		.. " | Experience Version: "
		.. version(),
	["Core"] = {},
	["runType"] = RunService:IsClient() and "Client" or "Server",
}

function Knight.Core.Log(Type: string, ...)
	local msgs = { ... }
	local l = "[Knight Framework] [" .. Knight.Version .. "]"

	for _, message in pairs(msgs) do
		if string.lower(Type) == "print" then
			print(l .. message)
		elseif string.lower(Type) == "warn" then
			warn(l .. message)
		elseif string.lower(Type) == "error" then
			local s, e = pcall(function()
				error(l .. message)
			end)
		end
	end
end

function Knight:PrintVersion()
	Knight.Core.Log("print", Knight.Version)
end

function Import(from_index, Path, Sub)
	local parts = {}
	local index = from_index

	for part in string.gmatch(string.sub(Path, Sub), "[^/]+") do
		table.insert(parts, part)
	end

	for _, part in ipairs(parts) do
		if typeof(index) == "Instance" then
			local success, result = pcall(function()
				return index:FindFirstChild(part)
			end)

			if success and result then
				index = result
			else
				error("Invalid path or unable to index: " .. Path .. ", part: " .. part)
			end
		elseif type(index) == "table" then
			local mt = getmetatable(index)
			if mt and type(mt.__index) == "table" then
				index = mt.__index[part]
			else
				index = index[part]
			end
		else
			error("Invalid path or unable to index: " .. Path .. ", part: " .. part)
		end
	end

	return index
end

function Knight.Core.Import(Path)
	if _G.Knight == nil then
		repeat
			task.wait(1)
		until _G.Knight ~= nil
		task.wait(0.2)
	end

	if _G.Knight.API == nil then
		repeat
			task.wait(1)
		until _G.Knight.API ~= nil
		task.wait(0.2)
	end

	if string.sub(Path, 1, string.len("KPM")) == "KPM" then
		return require(
			game:GetService("ReplicatedStorage")
				:WaitForChild("Packages", 900)
				:WaitForChild(string.gsub(Path, "KPM/", "")).init
		)
	end

	if string.sub(Path, 1, string.len("Knight/Shared/")) == "Knight/Shared/" then
		return Import(_G.Knight.API.Shared, Path, 14)
	end

	if string.sub(Path, 1, string.len("Knight/Env/")) == "Knight/Env/" then
		return Import(_G.Knight.API, Path, 14)
	end

	if string.sub(Path, 1, string.len("Knight/Client/")) == "Knight/Client/" then
		if RunService:IsServer() then
			error("You cannot import on Knight/Client on the server.")
		end
		return Import(_G.Knight.API, Path, 14)
	end

	if string.sub(Path, 1, string.len("Knight/Server/")) == "Knight/Server/" then
		if not RunService:IsServer() then
			error("You cannot import on Knight/Server on the client.")
		end

		return Import(_G.Knight.API, Path, 14)
	end

	if string.sub(Path, 1, string.len("Knight/Core/")) == "Knight/Core/" then
		return Import(_G.Knight.API.Core, Path, 12)
	end

	if string.sub(Path, 1, string.len("Roblox/")) == "Roblox/" then
		return Import(game, Path, 7)
	end
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

	_G.Knight = {}
	_G.Knight.API = RuntypeServices
	_G.Knight.API.Shared = Shared
	_G.Knight.Internal = Knight

	return Knight, _G.Knight.API
end

return Knight
