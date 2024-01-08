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
 Knight Package Manager (KPM): https://github.com/RAMPAGELLC/KnightPackageManager
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.vq9o.com
]]


local RunService = game:GetService("RunService")
local Knight = {
	["IsServer"] = RunService:IsServer(),
	["Version"] = "<0.0.5-prod> KNIGHT FRAMEWORK on Roblox " .. (RunService:IsStudio() and "Studio" or "Experience") .. " | Experience Version: " .. version(),
	["Core"] = {}
}

function Knight.Core.Log(Type, ...)
	local msgs = {...};
	local l = "[Knight Framework] [" .. Knight.Version .. "]";

	for _, message in pairs(msgs) do
		if string.lower(Type) == "print" then
			print(l .. message)
		elseif string.lower(Type) == "warn" then
			warn(l .. message)
		elseif string.lower(Type) == "error" then
			local s,e = pcall(function()
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
		task.wait(.2)
	end
	
	if _G.Knight.API == nil then
		repeat
			task.wait(1)
		until _G.Knight.API ~= nil
		task.wait(.2)
	end
	
	if string.sub(Path, 1, string.len("KPM")) == "KPM" then
		return require(game:GetService("ReplicatedStorage"):WaitForChild("Packages", 900):WaitForChild(string.gsub(Path, "KPM/", "")).init)
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
	return require(game:GetService("ReplicatedStorage"):WaitForChild("Knight").Init)
end

function Knight.Core:GetStorage(IsShared)
	if IsShared == nil then IsShared = false end
	if IsShared then return Knight.Core:GetShared() end

	local context;

	if RunService:IsServer() then
		context = game:GetService("ServerStorage"):WaitForChild("Knight")
	else
		context = game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Knight")
	end
	
	if not context:FindFirstChild("Init") then
		local EnvironmentInit = script.EnvironmentInit:Clone()
		EnvironmentInit.Name = "Init"
		EnvironmentInit.Parent = context
	end

	return require(context.Init)
end

function Knight.Core:Init()
	local Storage = Knight.Core:GetStorage()
	local RuntypeServices = Storage.InitKnight(Knight)
	local Shared = Knight.Core:GetShared()(RuntypeServices, Knight)
	
	_G.Knight = {}
	_G.Knight.API = RuntypeServices
	_G.Knight.Internal = Knight
	_G.Knight.API.Shared = Shared;
	
	return Knight, _G.Knight.API
end

function Knight.Core:GetService(ServiceName, IsShared)
	local Storage = Knight.Core:GetStorage()

	if not Storage.Inited then
		Knight.Core.Log("Warn", ServiceName .. " cannot be inited as it hasnt been started, " .. ServiceName .. " has been queued to return shortly.")

		repeat task.wait() until (Knight.Core:GetStorage(IsShared).Inited == true)
	end

	return Storage.Services[ServiceName] or {}
end

return Knight