---
description: >-
  Bridges are a easier version of Knight Remotes to provide a much easier
  solution.
---

# Bridges

<pre class="language-lua"><code class="lang-lua">--@Knight.Shared.Services.Bridge.new(BridgeName, IsShared  (optional; default false), Callback (optional; default false))

<strong>-- If you are registering something shared, you must register it server-sided.
</strong>
-- Register bridge with callback
Knight.Shared.Services.Bridge.new("Example", true, function(Player)
	print("Got event")
end)

-- Register bridge without callback
local bridge = Knight.Shared.Services.Bridge.new("Example", true)

-- Connection onto the bridge
bridge.Event:Connect(function(Player)

end)</code></pre>
