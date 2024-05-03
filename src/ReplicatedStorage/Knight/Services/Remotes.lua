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
local Events = ReplicatedStorage:WaitForChild("Knight"):WaitForChild("Events")
export type void = nil

local function GetRemote(name): RemoteFunction | RemoteEvent | BindableEvent | BindableFunction | boolean
	local remote = game:GetService("ReplicatedStorage").Knight.Events:FindFirstChild(name)

	if not remote then
		warn(
			"Remote "
				.. name
				.. " was not found. Ensure you have a folder called 'Events' in the Knight Shared Folder, also ensure you register the remote with Knight or manually create it."
		)
		return false
	end

	return remote
end

function Service:Fire(name: string, ...): void
	local remote = GetRemote(name)

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

function Service:FireAllNearby(name: string, position: Vector3, maxDistance: number | boolean, ...): void
	if maxDistance == nil then
		maxDistance = 50
	end

	local remote = GetRemote(name)

	if remote then
		for _, player in pairs(Players:GetPlayers()) do
			if not player.Character or not player.Character.PrimaryPart then
				continue
			end

			if (player.Character.PrimaryPart.Position - position).Magnitude < maxDistance then
				Service:Fire(name, player, ...)
			end
		end
	end
end

function Service:FireAll(name: string, ...): void
	local remote = GetRemote(name)

	if remote and RunService:IsServer() and remote:IsA("RemoteEvent") then
		remote:FireAllClients(...)
	end
end

function Service:Connect(name: string, callback: () -> void | nil | boolean)
	local remote = GetRemote(name)

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
	if not Events:FindFirstChild(RemoteName) then
		return
	end

	return Events[RemoteName] and Events[RemoteName]:Destroy() and true or false
end

-- @Knight.Shared.Services.Remotes:Register(string: Remote Name, string: RemoteClass (RemoteEvent, RemoteFunction), function: callback)
-- returns connection from shared services.
function Service:Register(RemoteName: string, RemoteClass: string, Callback: any)
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
