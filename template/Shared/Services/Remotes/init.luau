--[[
 (©) Copyright 2025 Meta Games, LLC. All rights reserved.
 This software is licensed by Meta Games, LLC under the terms of the MIT License.
 You may not use this file except in compliance with the License.
 You may obtain a copy of the License at https://opensource.org/license/mit/

 Remotes Usage:
 local Remotes = require(to.remotes/)
	Remotes:GetAsync(RemoteName: string) -> await RemoteAPI
		yields thread until recives RemoteAPI successfully.
	Remotes:Get(RemoteName: string) -> RemoteAPI | boolean
	Remotes:Fire(RemoteName: string, ...) -> (...any)
	Remotes:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...) -> (...any)
	Remotes:FireAllExcept(RemoteName: string, Except: Player | { Player }, ...) -> (...any)
	Remotes:FireAll(RemoteName: string, ...) -> (...any)
	Remotes:Connect(RemoteName: string, callback: () -> void | nil | boolean) -> void
	Remotes:Register(RemoteName: string, RemoteClass: string, Callback: any) -> void
	Remotes:RegisterMiddleware(Target: string, Callback: (Player: Player, ...any) -> boolean): void
	Remotes:UnregisterMiddleware(Target: string): void

RemoteAPI Usage (Recieved from Get/GetAsync):
	RemoteAPI:Fire(...) -> (...any)
	RemoteAPI:FireAll(...) -> (...any)
	RemoteAPI:FireAllNearby(position: Vector3, maxDistance: number | boolean, ...) -> (...any)
	RemoteAPI:FireAllExcept(Except: Player | { Player }, ...) -> (...any)
	RemoteAPI:Connect(callback: () -> void | nil | boolean) -> void
	RemoteAPI:OnDestroying(callback: (RemoteName: string) -> void) -> void
	RemoteAPI:Destroy()
]]

local Service = {
	HashingEnabled = true, -- Requires "dekkonot/md5@1.0.0" from wally.
	AutoRegisterIfDoesNotExist = false, -- Server :Fire() only. RemoteFunction is default. Useless unless client connects AFTER auto-creation.

	RemoteAPICache = {},
	Middleware = {},
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Maid = if Packages:FindFirstChild("knight")
	then require(Packages.knight).maid
	else Packages:FindFirstChild("Maid")
assert(
	Maid,
	"[Knight Library]: Maid not found in ReplicatedStorage.Packages. Please use the Knight framework or install maid manually."
)

local MD5 = if Packages:FindFirstChild("md5") then require(Packages.md5) else nil

if not Service.HashingEnabled and RunService:IsServer() then
	warn("[Knight:Remotes]: Hashing is disabled, it's recommended to enable hashing for better security.")
end

if Service.HashingEnabled and not MD5 then
	warn(
		"[Knight:Remotes]: Hashing is enabled but 'md5' package is not found in ReplicatedStorage.Packages. Disabling hashing."
	)
	Service.HashingEnabled = false
end

local Knight = ReplicatedStorage:WaitForChild("Knight")
local Events = Knight:FindFirstChild("Events") or Instance.new("Folder", Knight)
Events.Name = "Events"

export type RemotesService = typeof(Service)
export type KnightRemote = RemoteFunction | RemoteEvent | UnreliableRemoteEvent | BindableEvent | BindableFunction
export type void = nil
export type ConnectionCallbackId = number
export type RemoteAPI = {
	Destroy: () -> void,
	Fire: (...any) -> any...,
	FireAll: (...any) -> any...,
	RegisterMiddleware: (RemoteName: string, Callback: (RemoteName: string, Player: Player, ...any) -> boolean) -> void,
	UnregisterMiddleware: (RemoteName: string) -> void,
	FireAllNearby: (Vector3, number | boolean, ...any) -> any...,
	OnDestroying: (callback: (RemoteName: string) -> void) -> void,
	SpoofFire: (...any) -> {
		[ConnectionCallbackId]: any,
	},
}

local function GetRemoteName(RemoteName: string): string
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	if RemoteName:find(";") then
		RemoteName = RemoteName:gsub(";", "_")
	end

	if RemoteName:find(":") then
		RemoteName = RemoteName:gsub(":", "_")
	end

	return if Service.HashingEnabled and MD5 then MD5(RemoteName)[1] else RemoteName
end

local function GetRemote(RemoteName: string): KnightRemote | boolean
	RemoteName = GetRemoteName(RemoteName)

	local remote = Events:FindFirstChild(RemoteName)

	if not remote then
		if Service.AutoRegisterIfDoesNotExist and RunService:IsServer() then
			remote = Instance.new("RemoteFunction")
			remote.Parent = Events
			remote.Name = RemoteName
			warn(("%s does not exist, remote was auto-created as a remote function."):format(RemoteName))
			return remote
		end

		warn(
			("Remote '%s' was not found. You must manually create the event or register it with the API."):format(
				RemoteName
			)
		)
		return false
	end

	return remote
end

local RemoteAPI = {}
RemoteAPI.__index = RemoteAPI

function RemoteAPI.new(Remote: KnightRemote)
	local self = setmetatable({}, RemoteAPI)

	self.Maid = Maid.new()
	self.Remote = Remote
	self.RemoteName = self.Remote.Name

	self.ConnectionCallbacks = {}
	self.DestroyingCallbacks = {}

	self.Maid:GiveTask(self.Remote.Destroying:Connect(function()
		return self:Destroy()
	end))

	return self
end

function RemoteAPI:Connect(callback: () -> void | nil | boolean): RBXScriptConnection?
	table.insert(self.ConnectionCallbacks, callback)
	return Service:Connect(self.RemoteName, callback)
end

function RemoteAPI:OnDestroying(callback: (RemoteName: string) -> void): void
	table.insert(self.DestroyingCallbacks, callback)
end

function RemoteAPI:SpoofFire(...): {
	[ConnectionCallbackId]: any,
}
	local responses = {}

	for i, v in pairs(self.ConnectionCallbacks) do
		responses[i] = v(...)
	end

	return responses
end

function RemoteAPI:FireAllExcept(...)
	return Service:FireAllExcept(self.Remote, ...)
end

function RemoteAPI:FireAllNearby(...): any...
	return Service:FireAllNearby(self.Remote, ...)
end

function RemoteAPI:FireAll(...): any...
	return Service:FireAll(self.Remote, ...)
end

function RemoteAPI:Fire(...): any...
	return Service:Fire(self.Remote, ...)
end

function RemoteAPI:Destroy()
	for _, v in pairs(self.DestroyingCallbacks) do
		v(self.RemoteName)
	end

	self.Maid:DoCleaning()
	Service.RemoteAPICache[self.RemoteName] = nil
	self = nil
end

function Service:RegisterMiddleware(
	Target: string,
	Callback: (RemoteName: string, Player: Player, ...any) -> boolean
): void
	if Target ~= "*" then
		assert(
			self:IsRegistered(Target) == true,
			("[Knight:Remotes]: Failed to register middleware for event '%s' as it does not exist!"):format(Target)
		)
	end

	self.Middleware[Target] = Callback
end

function Service:UnregisterMiddleware(Target: string): void
	self.Middleware[Target] = nil
end

function Service:GetAsync(RemoteName: string): RemoteAPI
	repeat
		task.wait(1)
	until Service:Get(RemoteName, true) ~= false

	return Service:Get(RemoteName, true)
end

function Service:Get(RemoteName: string, SilenceWarnings: boolean?): RemoteAPI | boolean
	if Service.RemoteAPICache[GetRemoteName(RemoteName)] ~= nil then
		return Service.RemoteAPICache[GetRemoteName(RemoteName)]
	end

	if SilenceWarnings == nil then
		SilenceWarnings = false
	end

	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")
	assert(typeof(SilenceWarnings) == "boolean", "[Knight:Remotes]: SilenceWarnings must be a boolean")

	local remote: Instance | boolean = GetRemote(RemoteName)

	if typeof(remote) ~= "Instance" and typeof(remote) == "boolean" then
		if not SilenceWarnings then
			warn(
				string.format(
					"[Knight:Remotes]: '%s' event is not registered, Remotes:Get() will now throw a boolean!",
					RemoteName
				)
			)
		end

		return false
	end

	RemoteName = GetRemoteName(RemoteName)

	local api = RemoteAPI.new(remote :: KnightRemote)
	Service.RemoteAPICache[RemoteName] = api

	return api
end

function Service:IsRegistered(RemoteName: string): boolean
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	return typeof(GetRemote(RemoteName)) ~= "boolean"
end

function Service:Fire(RemoteName: string | KnightRemote, ...): any...
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(
		typeof(RemoteName) == "string" or typeof(RemoteName) == "Instance",
		"[Knight:Remotes]: RemoteName must be a string or Remote instance"
	)

	local remote: KnightRemote | boolean = if typeof(RemoteName) == "string" then GetRemote(RemoteName) else RemoteName
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
				assert(
					typeof(args[1]) == "Instance" and args[1]:IsA("Player"),
					"[Knight:Remotes]: Fire() arg 1 must be 'Player' object."
				)

				if not Players:GetPlayerByUserId(args[1].UserId) then
					warn(string.format("%s has disconnected, remote operation aborted!", args[1].Name))
					return nil
				end

				remote:FireClient(...)
			elseif remote:IsA("RemoteEvent") then
				assert(args[1] ~= nil, "[Knight:Remotes]: Fire() arg 1 is nil.")
				assert(
					typeof(args[1]) == "Instance" and args[1]:IsA("Player"),
					"[Knight:Remotes]: Fire() arg 1 must be 'Player' object."
				)

				if not Players:GetPlayerByUserId(args[1].UserId) then
					warn(string.format("%s has disconnected, remote operation aborted!", args[1].Name))
					return nil
				end

				remote:FireClient(...)
			elseif remote:IsA("BindableFunction") then
				return remote:Invoke(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				assert(args[1] ~= nil, "[Knight:Remotes]: Fire() arg 1 is nil.")
				assert(
					typeof(args[1]) == "Instance" and args[1]:IsA("Player"),
					"[Knight:Remotes]: Fire() arg 1 must be 'Player' object."
				)

				if not Players:GetPlayerByUserId(args[1].UserId) then
					warn(string.format("%s has disconnected, remote operation aborted!", args[1].Name))
					return nil
				end

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

function Service:FireAllNearby(
	RemoteName: string | KnightRemote,
	position: Vector3,
	maxDistance: number | boolean,
	...
): any...
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(
		typeof(RemoteName) == "string" or typeof(RemoteName) == "Instance",
		"[Knight:Remotes]: RemoteName must be a string or Remote instance"
	)

	assert(position ~= nil, "[Knight:Remotes]: position is nil")
	assert(typeof(position) == "Vector3", "[Knight:Remotes]: position must be a Vector3")

	assert(maxDistance ~= nil, "[Knight:Remotes]: maxDistance is nil")
	assert(
		typeof(maxDistance) == "number" or typeof(maxDistance) == "boolean",
		"[Knight:Remotes]: maxDistance must be a number or boolean."
	)

	if typeof(maxDistance) == "boolean" then
		maxDistance = 50
	end

	local remote = if typeof(RemoteName) == "string" then GetRemote(RemoteName) else RemoteName

	if remote then
		for _, player in pairs(Players:GetPlayers()) do
			if not player.Character or not player.Character.PrimaryPart then
				continue
			end

			if (player.Character.PrimaryPart.Position - position).Magnitude < maxDistance then
				Service:Fire(remote, player, ...)
			end
		end
	end
end

function Service:FireAll(RemoteName: string | KnightRemote, ...): any...
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(
		typeof(RemoteName) == "string" or typeof(RemoteName) == "Instance",
		"[Knight:Remotes]: RemoteName must be a string or Remote instance"
	)

	local remote = if typeof(RemoteName) == "string" then GetRemote(RemoteName) else RemoteName

	if remote and RunService:IsServer() and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
		remote:FireAllClients(...)
	else
		warn(
			("[Knight:Remotes]: Failed to FireAll for '%s' as the remote does not exist or is not a RemoteEvent/UnreliableRemoteEvent!"):format(
				RemoteName
			)
		)
	end
end

function Service:FireAllExcept(RemoteName: string | KnightRemote, Except: Player | { Player }, ...): any...
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(
		typeof(RemoteName) == "string" or typeof(RemoteName) == "Instance",
		"[Knight:Remotes]: RemoteName must be a string or Remote instance"
	)
	assert(
		Except and (typeof(Except) == "Instance" and Except:IsA("Player") or typeof(Except) == "table"),
		"[Knight:Remotes]: Except must be a Player or table of Players."
	)

	if typeof(Except) == "Instance" and Except:IsA("Player") then
		Except = { Except }
	end

	local remote = if typeof(RemoteName) == "string" then GetRemote(RemoteName) else RemoteName

	if remote and RunService:IsServer() then
		for _, player in pairs(Players:GetPlayers()) do
			if table.find(Except, player) ~= nil then
				continue
			end

			Service:Fire(remote, player, ...)
		end
	else
		warn(("[Knight:Remotes]: Failed to FireAllExcept for '%s' as the remote does not exist!"):format(RemoteName))
	end
end

function Service:Connect(
	RemoteName: string | KnightRemote,
	callback: (...any) -> void | nil | boolean
): RBXScriptConnection?
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(
		typeof(RemoteName) == "string" or typeof(RemoteName) == "Instance",
		"[Knight:Remotes]: RemoteName must be a string or Remote instance"
	)
	assert(callback ~= nil, "[Knight:Remotes]: callback is nil")
	assert(typeof(callback) == "function", "[Knight:Remotes]: callback must be a function")

	local remote = if typeof(RemoteName) == "string" then GetRemote(RemoteName) else RemoteName

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
				remote.OnServerInvoke = function(player, ...)
					local args = table.pack(player, ...)
					local middleware = self.Middleware[RemoteName] or self.Middleware["*"]

					if middleware and not middleware(RemoteName, player, ...) then
						warn(
							("[Knight:Remotes]: Dropped Event '%s' from '%s' as it failed middleware!"):format(
								RemoteName,
								player.Name
							)
						)
						return
					end

					return callback(table.unpack(args))
				end
			else
				remote.OnClientInvoke = function(...)
					local middleware = self.Middleware[RemoteName] or self.Middleware["*"]

					if middleware and not middleware(RemoteName, Players.LocalPlayer, ...) then
						warn(
							("[Knight:Remotes]: Dropped Event '%s' from '%s' as it failed middleware!"):format(
								RemoteName,
								Players.LocalPlayer.Name
							)
						)
						return
					end

					return callback(...)
				end
			end
		end

		if signal then
			return signal:Connect(function(...)
				local args = table.pack(...)
				local playerArg = RunService:IsServer() and args[1] or Players.LocalPlayer or nil

				-- Remove player from args if on server
				if RunService:IsServer() and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
					table.remove(args, 1)
				end

				-- Handle middleware
				local middleware = self.Middleware[RemoteName] or self.Middleware["*"]
				if middleware and not middleware(RemoteName, playerArg, table.unpack(args)) then
					warn(("[Knight:Remotes]: Dropped Event '%s' as it failed middleware!"):format(RemoteName))
					return
				end

				return callback(...);
			end)
		end
	end
end

function Service:Unregister(RemoteName: string): void
	assert(RemoteName ~= nil, "[Knight:Remotes]: RemoteName is nil")
	assert(typeof(RemoteName) == "string", "[Knight:Remotes]: RemoteName must be a string")

	RemoteName = GetRemoteName(RemoteName)

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

	RemoteName = GetRemoteName(RemoteName)

	if Events:FindFirstChild(RemoteName) then
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
