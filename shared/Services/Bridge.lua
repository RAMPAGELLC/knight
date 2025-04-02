local Bridge = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Easier version of Remote Events & Remotes without calling several remotes."
	}
}

--[[
@Knight.Shared.Services.Bridge.new(BridgeName, IsShared  (optional; default false), Callback (optional; default false))

If you are registering something shared, you must register it server-sided.

-- Register bridge with callback
Knight.Shared.Services.Bridge.new("Example", true, function(Player)
	print("Got event")
end)

-- Register bridge without callback
local bridge = Knight.Shared.Services.Bridge.new("Example", true)

-- Connection onto the bridge
bridge.Event:Connect(function(Player)

end)
]]

function Bridge.New(BridgeName, IsShared, Callback)
	local NewBridge = {}
	
	if IsShared == nil then IsShared = false end
	if Callback == nil then Callback = false end
	
	NewBridge.BridgeName = BridgeName
	NewBridge.Shared = IsShared
	NewBridge.Event = Bridge.Shared.Objects.Event.new()
	NewBridge.Internal = {
		Trigger = Bridge.Shared.Services.Remotes:Register(BridgeName, IsShared and "RemoteFunction" or "BindableEvent", function(...)
			NewBridge.Event:Fire(...)
		end)
	}
	
	NewBridge.Event:Connect(function(...)
		if Callback then
			Callback(...)
		end
	end)
	
	return NewBridge
end

return Bridge