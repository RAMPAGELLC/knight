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

]]

local Service = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Remote Service for handling remotes across client and server.",
	},
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knight = ReplicatedStorage:WaitForChild("Knight")

local Events = Knight:FindFirstChild("Events") or Instance.new("Folder", Knight)
Events.Name = "Events";

export type void = nil

local function GetRemote(RemoteName: string): RemoteFunction | RemoteEvent | BindableEvent | BindableFunction | boolean
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = ReplicatedStorage.Knight.Events:FindFirstChild(RemoteName)

	if not remote then
		warn(
			("Remote \"%s\" was not found. You must manually create the event or register it with the API."):format(
				RemoteName
			)
		)
		return false
	end

	return remote
end

function Service:Fire(RemoteName: string, ...): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = GetRemote(RemoteName)

	if remote then
		if RunService:IsServer() then
			if remote:IsA("RemoteEvent") then
				remote:FireClient(...)
			elseif remote:IsA("BindableFunction") then
				return remote:Invoke(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				return remote:InvokeClient(...)
			end
		else
			if remote:IsA("RemoteEvent") then
				remote:FireServer(...)
			elseif remote:IsA("BindableFunction") then
				return remote:Invoke(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				return remote:InvokeServer(...)
			end
		end
	end
end

function Service:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	assert(position ~= nil, "[Knight:Remotes]: position is nil")
	assert(typeof(position) == "Vector3", "[Knight:Remotes]: position must be a Vector3")

	assert(maxDistance ~= nil, "[Knight:Remotes]: maxDistance is nil")
	assert(typeof(maxDistance) == "number" or typeof(maxDistance) == "boolean", "[Knight:Remotes]: maxDistance must be a number or boolean.")

	if typeof(maxDistance) == "boolean" then
		maxDistance = 50
	end

	local remote = GetRemote(RemoteName)

	if remote then
		for _, player in pairs(Players:GetPlayers()) do
			if not player.Character or not player.Character.PrimaryPart then
				continue
			end

			if (player.Character.PrimaryPart.Position - position).Magnitude < maxDistance then
				Service:Fire(RemoteName, player, ...)
			end
		end
	end
end

function Service:FireAll(RemoteName: string, ...): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = GetRemote(RemoteName)

	if remote and RunService:IsServer() and remote:IsA("RemoteEvent") then
		remote:FireAllClients(...)
	end
end

function Service:Connect(RemoteName: string, callback: () -> void | nil | boolean)
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = GetRemote(RemoteName)

	if remote then
		local signal

		if remote:IsA("RemoteEvent") then
			signal = RunService:IsServer() and remote.OnServerEvent or remote.OnClientEvent
		elseif remote:IsA("BindableEvent") then
			signal = remote.Event
		elseif remote:IsA("BindableFunction") then
			remote.OnInvoke = callback
		elseif remote:IsA("RemoteFunction") then
			if RunService:IsServer() then
				remote.OnServerInvoke = callback
			else
				remote.OnClientInvoke = callback
			end
		end

		if signal then
			return signal:Connect(callback)
		end
	end
end

-- @Knight.Shared.Services.Remotes:Unregister(string: Remote Name)
-- returns boolean on success or not
function Service:Unregister(RemoteName: string)
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	if not Events:FindFirstChild(RemoteName) then
		return
	end

	return Events[RemoteName] and Events[RemoteName]:Destroy() and true or false
end

-- @Knight.Shared.Services.Remotes:Register(string: Remote Name, string: RemoteClass (RemoteEvent, RemoteFunction), function: callback)
-- returns connection from shared services.
function Service:Register(RemoteName: string, RemoteClass: string, Callback: any)
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(RemoteClass ~= nil, "[Knight:Remotes]: RemoteClass is nil")

	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")
	assert(typeof(RemoteClass) == "string", "[Knight:Remotes]: RemoteClass must be a string")

	if Events:FindFirstChild(RemoteName) then
		warn(RemoteName, " is already registered")
		return
	end

	local Remote = Instance.new(RemoteClass)
	Remote.Parent = Events
	Remote.Name = RemoteName

	if Callback == nil or not Callback then
		return
	end

	return Service:Connect(RemoteName, Callback)
end

return Service