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

 Remotes Usage:
 local Remotes = require(to.remotes/)
	Remotes:GetAsync(RemoteName: string) -> await RemoteAPI
		yields thread until recives RemoteAPI successfully.
	Remotes:Get(RemoteName: string) -> RemoteAPI | boolean
	Remotes:Fire(RemoteName: string, ...) -> (any...)
	Remotes:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...) -> (any...)
	Remotes:FireAll(RemoteName: string, ...) -> (any...)
	Remotes:Connect(RemoteName: string, callback: () -> void | nil | boolean) -> void
	Remotes:Register(RemoteName: string, RemoteClass: string, Callback: any) -> void

RemoteAPI Usage (Recieved from Get/GetAsync):
	RemoteAPI:Fire(...) -> (any...)
	RemoteAPI:FireAll(...) -> (any...)
	RemoteAPI:FireAllNearby(position: Vector3, maxDistance: number | boolean, ...) -> (any...)
	RemoteAPI:Destroy()
]]

local Service = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Remote Service for handling remotes across client and server.",
	},
	AutoRegisterIfDoesNotExist = true, -- Server :Fire() only. RemoteFunction is default. Useless unless client connects AFTER auto-creation.
	RemoteAPICache = {}
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knight = ReplicatedStorage:WaitForChild("Knight")
local Maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Maid"))

local Events = Knight:FindFirstChild("Events") or Instance.new("Folder", Knight)
Events.Name = "Events"

export type KnightRemote = RemoteFunction | RemoteEvent | UnreliableRemoteEvent | BindableEvent | BindableFunction;
export type void = nil
export type RemoteAPI = {
	Destroy: () -> void;
	Fire: (any...) -> (any...);
	FireAll: (any...) -> (any...);
	FireAllNearby: (Vector3, number | boolean, any...) -> (any...);
}

local function GetRemote(RemoteName: string): KnightRemote | boolean
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = Events:FindFirstChild(RemoteName)

	if not remote then
		if Service.AutoRegisterIfDoesNotExist and RunService:IsServer() then
			remote = Instance.new("RemoteFunction")
			remote.Parent = Events
			remote.Name = RemoteName
			warn(("%s does not exist, remote was auto-created as a remote function."):format(RemoteName))
			return remote
		end

		warn(("Remote '%s' was not found. You must manually create the event or register it with the API."):format(RemoteName))
		return false
	end

	return remote
end

local RemoteAPI = {}
RemoteAPI.__index = RemoteAPI

function RemoteAPI.new(Remote: KnightRemote)
	local self = setmetatable({}, RemoteAPI)

	self.Maid = Maid.new()
	self.Remote = Remote;
	self.RemoteName= self.Remote.Name;

	self.Maid:GiveTask(self.Remote.Destroying:Connect(function()
		return self:Destroy();
	end))

	return self;
end

function RemoteAPI:FireAllNearby(...): (any...)
	return Service:FireAllNearby(self.RemoteName, ...)
end

function RemoteAPI:FireAll(...): (any...)
	return Service:FireAll(self.RemoteName, ...)
end

function RemoteAPI:Fire(...): (any...)
	return Service:Fire(self.RemoteName, ...)
end

function RemoteAPI:Destroy()
	Service.RemoteAPICache[self.RemoteName] = nil;
	self = nil;	
end

function Service:GetAsync(RemoteName: string): RemoteAPI | boolean
	repeat
		task.wait(.1)
	until typeof(Service:Get(RemoteName) ~= "boolean")

	return Service:Get(RemoteName);
end

function Service:Get(RemoteName: string, SilenceWarnings: boolean?): RemoteAPI | boolean
	if Service.RemoteAPICache[RemoteName] ~= nil then
		return Service.RemoteAPICache[RemoteName];
	end

	if SilenceWarnings == nil then
		SilenceWarnings = false
	end

	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")
	assert(typeof(SilenceWarnings) == "boolean", "[Knight:Remotes]: SilenceWarnings must be a boolean")

	local remote: Instance | boolean = GetRemote(RemoteName)

	if typeof(remote) == "boolean" then
		warn(string.format("[Knight:Remotes]: '%s' event is not registered, Remotes:Get() will now throw a boolean!", RemoteName))
		return false
	end

	Service.RemoteAPICache[RemoteName] = RemoteAPI.new(remote);

	return Service.RemoteAPICache[RemoteName];
end

function Service:IsRegistered(RemoteName: string): boolean
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")
	
	return typeof(GetRemote(RemoteName)) ~= "boolean"
end

function Service:Fire(RemoteName: string, ...): (any...)
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote: Instance | boolean = GetRemote(RemoteName)
	local args = { ... }

	if typeof(remote) == "boolean" then
		local attempts = 10
		local took = 0
		local delay = 2

		warn("[Knight:Remotes]: Failed to locate event. Delaying remote fire for 10 attempts, 2s cooldown.")

		for i = 1, attempts do
			took += 1

			if typeof(GetRemote(RemoteName)) ~= "boolean" then
				break
			end

			task.wait(delay)
		end

		if typeof(GetRemote(RemoteName)) == "boolean" then
			warn("[Knight:Remotes]: Failed to locate event after 10 attempts.")
			return
		end

		remote = GetRemote(RemoteName)
		warn(("[Knight:Remotes]: Event was located after %d attempt(s)."):format(took))
	end

	if remote then
		if RunService:IsServer() then
			if remote:IsA("UnreliableRemoteEvent") then
				assert(args[1] ~= nil, "[Knight:Remotes]: Fire() arg 1 is nil.")
				assert(typeof(args[1]) == "Instance" and args[1]:IsA("Player"), "[Knight:Remotes]: Fire() arg 1 must be 'Player' object.")
				remote:FireClient(...)
			elseif remote:IsA("RemoteEvent") then
				assert(args[1] ~= nil, "[Knight:Remotes]: Fire() arg 1 is nil.")
				assert(typeof(args[1]) == "Instance" and args[1]:IsA("Player"), "[Knight:Remotes]: Fire() arg 1 must be 'Player' object.")
				remote:FireClient(...)
			elseif remote:IsA("BindableFunction") then
				return remote:Invoke(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				assert(args[1] ~= nil, "[Knight:Remotes]: Fire() arg 1 is nil.")
				assert(typeof(args[1]) == "Instance" and args[1]:IsA("Player"), "[Knight:Remotes]: Fire() arg 1 must be 'Player' object.")
				return remote:InvokeClient(...)
			end
		else
			if remote:IsA("UnreliableRemoteEvent") then
				remote:FireServer(...)
			elseif remote:IsA("RemoteEvent") then
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

function Service:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...): (any...)
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

function Service:FireAll(RemoteName: string, ...): (any...)
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = GetRemote(RemoteName)

	if remote and RunService:IsServer() and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
		remote:FireAllClients(...)
	end
end

function Service:Connect(RemoteName: string, callback: (any...) -> void | nil | boolean): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	local remote = GetRemote(RemoteName)

	if remote then
		local signal

		if remote:IsA("UnreliableRemoteEvent") then
			signal = RunService:IsServer() and remote.OnServerEvent or remote.OnClientEvent
		elseif remote:IsA("RemoteEvent") then
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

function Service:Unregister(RemoteName: string): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	if not Events:FindFirstChild(RemoteName) then
		return
	end

	Events[RemoteName]:Destroy()
end

function Service:Register(RemoteName: string, RemoteClass: string, Callback: any): void
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
