--[[

 Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
 Copyright (c) 2024 Metatable Games. All rights reserved.
 
 Written by vq9o <business@vq9o.com>.

 Scuffed Luau "Sockets" locked for communication between the server & client with Middleware authentication. This is used for the CRP
 Tool objects system.

 License: MIT
 GitHub: https://github.com/RAMPAGELLC/RBLXLuauSockets
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Maid = if Packages:FindFirstChild("knight") then require(Packages.knight).maid else Packages:FindFirstChild("Maid")
assert(Maid, "[Knight Library]: Maid not found in ReplicatedStorage.Packages. Please use the Knight framework or install maid manually.")

export type ServerEventSocketAPI = {
	Init: (Player: Player) -> ServerEventSocketAPI,
	on: (socket: string, return_data: boolean, onTrigger: (...any) -> nil) -> nil,
	emit: (socket: string, ...any) -> ...any,
	Destroy: () -> nil,

	MiddlewareAuthentication: (Player: Player, SocketName: string) -> boolean,
	Events: Folder,
	Maid: any,
}

export type ClientEventSocketAPI = {
	Init: (Events: Folder) -> ClientEventSocketAPI,
	on: (SocketName: string, OnTrigger: (...any) -> nil) -> nil,
	emit: (socket: string, ...any) -> ...any,
	Destroy: () -> nil,

	Maid: any,
}

local Server = {}
Server.__index = Server

local Client = {}
Client.__index = Client

-- SERVER
function Server:Init(MiddlewareAuthentication): ServerEventSocketAPI
	local self = setmetatable({}, Server)

	self.Maid = Maid.new()
	self.MiddlewareAuthentication = MiddlewareAuthentication

	self.Events = Instance.new("Folder")
	self.Events.Name = "OESAPI_" .. HttpService:GenerateGUID(false)
	self.Events.Parent = ReplicatedStorage["__CACHE"]

	self.Maid:GiveTask(self.Events)

	return self
end

function Server:FindEvent(SocketName: string, AllowDataReturn: boolean)
	return self.Events:FindFirstChild(SocketName) or Instance.new(AllowDataReturn and "RemoteFunction" or "UnreliableRemoteEvent")
end

function Server:on(SocketName: string, AllowDataReturn: boolean, OnTrigger: (...any) -> nil)
	local Event = self:FindEvent(SocketName, AllowDataReturn)
    Event.Parent = self.Events;
	Event.Name = SocketName

	if AllowDataReturn then
		Event.OnServerInvoke = function(Player: Player, ...)
			if not self.MiddlewareAuthentication(Player, SocketName) then
                warn(("%s attempted to call a restricited socket '%s'."):format(Player.Name, SocketName))
				return nil
			end

			return OnTrigger(Player, ...)
		end
	else
		self.Maid:GiveTask(Event.OnServerEvent:Connect(function(Player: Player, ...)
			if not self.MiddlewareAuthentication(Player, SocketName) then
                warn(("%s attempted to call a restricited socket '%s'."):format(Player.Name, SocketName))
				return nil
			end

			return OnTrigger(Player, ...)
		end))
	end

	self.Maid:GiveTask(Event)
end

function Server:emit(SocketName: string, Player: Player | boolean, ...): (...any)
	local Event = self:FindEvent(SocketName, false)

	if Event:IsA("RemoteFunction") then
		if typeof(Player) == "boolean" then
            warn(("Socket %s cannot return data with no player specified, you will keep getting NIL."):format(SocketName))

            for i,v in pairs(Players:GetPlayers()) do
                Event:InvokeClient(v, ...)
            end

            return nil;
		else
			return Event:InvokeClient(Player, ...)
		end
	else
		if typeof(Player) == "boolean" then
			return Event:FireAllClients(...)
		else
			return Event:FireClient(Player, ...)
		end
	end
end

function Server:Destroy()
	self.Maid:DoCleaning()
	self = nil
end

function Server:Disconnect()
	return self:Destroy()
end

-- CLIENT
function Client:Init(Events: Folder): ClientEventSocketAPI
	local self = setmetatable({}, Client)

	self.Events = Events
	self.Maid = Maid.new()

	return self
end

function Client:on(SocketName: string, OnTrigger: (...any) -> nil)
	local Event = self.Events:FindFirstChild(SocketName)

	if Event == nil then
		warn("Socket " .. SocketName .. " does not exist.")
		return nil
	end

	if Event:IsA("RemoteFunction") then
		Event.OnClientInvoke = OnTrigger
	else
		self.Maid:GiveTask(Event.OnClientEvent:Connect(OnTrigger))
	end

	self.Maid:GiveTask(Event)
end

function Client:emit(SocketName: string, ...): (...any)
	local Event = self.Events:FindFirstChild(SocketName)

	if Event == nil then
		warn("Socket " .. SocketName .. " does not exist.")
		return nil
	end
	
	if Event:IsA("RemoteFunction") then
		return Event:InvokeServer(...)
	end
	
	Event:FireServer(...);
	
	return nil;
end

function Client:Destroy()
	self.Maid:DoCleaning()
	self = nil
end

function Client:Disconnect()
	return self:Destroy()
end

return RunService:IsServer() and Server or Client;