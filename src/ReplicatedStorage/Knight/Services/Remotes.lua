local rs = game:GetService("RunService")
local Service = {

	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Remote Service for handling remotes across client and server."
	}
}

local function GetRemote(name)
	local remote = Service.Remotes[name]
	if not remote then
		warn("Remote", name, "not found. Did you add it to the Remotes folder?")
	end
	return remote
end

function Service:Fire(name, ...)
	local remote = GetRemote(name)

	if remote then
		if rs:IsServer() then
			if remote:IsA("RemoteEvent") then
				remote:FireClient(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				return remote:InvokeClient(...)
			end
		else
			if remote:IsA("RemoteEvent") then
				remote:FireServer(...)
			elseif remote:IsA("BindableEvent") then
				remote:Fire(...)
			elseif remote:IsA("RemoteFunction") then
				return remote:InvokeServer(...)
			end
		end
	end
end

function Service:FireAll(name, ...)
	local remote = GetRemote(name)

	if remote then
		if rs:IsServer() then
			if remote:IsA("RemoteEvent") then
				remote:FireAllClients(...)
			end
		end
	end
end

function Service:Connect(name, callback)
	local remote = GetRemote(name)

	if remote then
		local signal

		if rs:IsServer() then
			if remote:IsA("RemoteEvent") then
				signal = remote.OnServerEvent
			elseif remote:IsA("BindableEvent") then
				signal = remote.Event
			elseif remote:IsA("RemoteFunction") then
				remote.OnServerInvoke = callback
			end
		else
			if remote:IsA("RemoteEvent") then
				signal = remote.OnClientEvent
			elseif remote:IsA("BindableEvent") then
				signal = remote.Event
			elseif remote:IsA("RemoteFunction") then
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
	return Service.Shared.Remotes[RemoteName] and Service.Shared.Remotes[RemoteName]:Destroy() and true or false
end

-- @Knight.Shared.Services.Remotes:Register(string: Remote Name, string: RemoteClass (RemoteEvent, RemoteFunction), function: callback)
-- returns connection from shared services.
function Service:Register(RemoteName: string, RemoteClass: string, Callback)
	if Service.Shared.Remotes[RemoteName] then return false end
	
	local Remote = Instance.new(RemoteClass, Service.Shared.Remotes)
	Remote.Name = RemoteName

	return Service.Shared.Services.Remotes:Connect(RemoteName, Callback)
end

return Service