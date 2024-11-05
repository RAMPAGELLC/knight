# Knight Remotes API

<figure><img src="../.gitbook/assets/knightremotesapi.jpg" alt=""><figcaption></figcaption></figure>

## KnightRemotes API Documentation - Version 1.0.4

The `KnightRemotes` module provides a robust framework for managing remote events and functions across the client and server in the Knight framework. This module handles remote creation, firing, middleware management, and connection, ensuring efficient, secure communication for your game.

## Overview

* **Get Remotes**: Synchronously or asynchronously retrieve `RemoteAPI` instances by name.
* **Fire Remotes**: Trigger remotes on specific players, all players, or players nearby a location.
* **Middleware**: Integrate middleware functions for security and validation checks on events.
* **Register/Unregister Remotes**: Add or remove remote functions/events dynamically.

## Functions

Here’s the revised documentation with the requested formatting changes:

***

### `Remotes:GetAsync(RemoteName: string) -> await RemoteAPI`

**Description:**\
Waits asynchronously to retrieve the `RemoteAPI` associated with the specified remote name.

**Usage:**

```lua
local remoteAPI = Remotes:GetAsync("ExampleRemote")
```

**Parameters:**

* **RemoteName** (string): The name of the remote event or function to retrieve.

**Returns:**

* **RemoteAPI**: The `RemoteAPI` associated with `RemoteName` (yields until available).

***

### `Remotes:Get(RemoteName: string) -> RemoteAPI | boolean`

**Description:**\
Fetches the `RemoteAPI` associated with the given remote name synchronously.

**Usage:**

```lua
local remoteAPI = Remotes:Get("ExampleRemote")
```

**Parameters:**

* **RemoteName** (string): The name of the remote.

**Returns:**

* **RemoteAPI**: The `RemoteAPI` if available, otherwise `false`.

***

### `Remotes:Fire(RemoteName: string, ...) -> (any...)`

**Description:**\
Triggers the specified remote event or function with the provided arguments.

**Usage:**

```lua
Remotes:Fire("ExampleRemote", arg1, arg2)
```

**Parameters:**

* **RemoteName** (string): The name of the remote.
* **...** (any): Arguments passed to the remote event.

***

### `Remotes:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...) -> (any...)`

**Description:**\
Fires the remote to all players within the specified distance from a central position.

**Usage:**

```lua
Remotes:FireAllNearby("ExampleRemote", Vector3.new(0, 0, 0), 100, any...)
```

**Parameters:**

* **RemoteName** (string): The name of the remote.
* **position** (Vector3): Center position for nearby players.
* **maxDistance** (number | boolean): Maximum radius; if `true`, defaults to 50.
* **...** (any): Additional arguments passed to the remote.

***

### `Remotes:FireAll(RemoteName: string, ...) -> (any...)`

**Description:**\
Triggers the remote for all connected players.

**Usage:**

```lua
Remotes:FireAll("ExampleRemote", arg1, arg2)
```

**Parameters:**

* **RemoteName** (string): The remote’s name.
* **...** (any): Arguments passed to each connected player.

***

### `Remotes:Connect(RemoteName: string, callback: () -> void | nil | boolean) -> void`

**Description:**\
Attaches a callback to the specified remote. The callback executes each time the remote event is fired.

**Usage:**

```lua
Remotes:Connect("ExampleRemote", function()
    print("Remote triggered!") 
end)
```

**Parameters:**

* **RemoteName** (string): The name of the remote.
* **callback** (function): Function executed on the remote event firing.

***

### `Remotes:Register(RemoteName: string, RemoteClass: string, Callback: any) -> void`

**Description:**\
Registers a new remote with a specified class type and optional callback function.

**Usage:**

<pre class="language-lua"><code class="lang-lua">Remotes:Register("ExampleRemote", "RemoteFunction", function()
<strong>    print("Remote registered!")
</strong>end)
</code></pre>

**Parameters:**

* **RemoteName** (string): Name for the new remote.
* **RemoteClass** (string): Class type (e.g., RemoteFunction).
* **Callback** (function, optional): Function to associate with the remote.

***

### `Remotes:RegisterMiddleware(Target: string, Callback: (Player: Player, ...any) -> boolean): void`

**Description:**\
Adds middleware for validation or checks before a remote is triggered.

**Usage:**

```lua
Remotes:RegisterMiddleware("ExampleRemote", function(player) 
    return player:IsInGroup(1234567890) 
end)
```

**Parameters:**

* **Target** (string): The target remote or `*` for global middleware.
* **Callback** (function): Middleware function, returning `true` to proceed or `false` to block.

***

### `Remotes:UnregisterMiddleware(Target: string): void`

**Description:**\
Removes middleware associated with a specific remote.

**Usage:**

```lua
Remotes:UnregisterMiddleware("ExampleRemote")
```

**Parameters:**

* **Target** (string): The name of the remote from which to remove middleware.

***

### `RemoteAPI:Fire(...) -> (any...)`

**Description:**\
Triggers the associated remote event with the provided arguments.

**Usage:**

```lua
remoteAPI:Fire(arg1, arg2)
```

**Parameters:**

* **...** (any): Arguments passed to the remote event.

***

### `RemoteAPI:FireAll(...) -> (any...)`

**Description:**\
Fires the associated remote for all players.

**Usage:**

```lua
remoteAPI:FireAll(arg1, arg2)
```

**Parameters:**

* **...** (any): Arguments passed to each connected player.

***

### `RemoteAPI:FireAllNearby(position: Vector3, maxDistance: number | boolean, ...) -> (any...)`

**Description:**\
Triggers the remote for players within a specific range from a center position.

**Usage:**

```lua
remoteAPI:FireAllNearby(Vector3.new(0, 0, 0), 100, arg1, arg2)
```

**Parameters:**

* **position** (Vector3): The central position for nearby players.
* **maxDistance** (number | boolean): Maximum radius; defaults to 50 if `true`.
* **...** (any): Additional arguments for the remote.

***

### `RemoteAPI:Connect(callback: () -> void | nil | boolean) -> void`

**Description:**\
Attaches a callback to the remote event, executed when the event fires.

**Usage:**

```lua
remoteAPI:Connect(function() print("Remote event triggered!") end)
```

**Parameters:**

* **callback** (function): Function to execute on the event firing.

***

### `RemoteAPI:OnDestroying(callback: (RemoteName: string) -> void) -> void`

**Description:**\
Sets a callback function to be executed when the remote is destroyed.

**Usage:**

```lua
remoteAPI:OnDestroying(function(remoteName) print(remoteName, "is being destroyed.") end)
```

**Parameters:**

* **callback** (function): Function called with the `RemoteName` when destroyed.

***

### `RemoteAPI:Destroy()`

**Description:**\
Removes the remote from cache and triggers any attached `OnDestroying` callbacks.

**Usage:**

```lua
remoteAPI:Destroy()
```

## Examples / Code Samples

### Getting and Firing a Remote

Retrieve a remote using `Get` and fire it with some arguments.

```lua
local myRemote = Remotes:Get("ExampleRemote")

if myRemote then
    myRemote:Fire("Hello", 42)
end
```

Additionally you can fire an event via:

```lua
-- Server-side
Remotes:Fire("ExampleRemote", game.Players.vq9o, "Hello", 42)
Remotes:FireAll("ExampleRemote", "Hello", 42)

-- Client-side
Remotes:Fire("ExampleRemote", "Hello", 42)
```

### Registering a New Remote with a Callback

Register a new remote that will respond with a callback function.

```lua
Remotes:Register("PlayerData", "RemoteFunction", function(player, data)
    print(player.Name .. " sent data:", data)
    return "Acknowledged"
end)
```

### Using Middleware for Validation

Add middleware to restrict access or validate conditions before a remote is triggered.

```lua
Remotes:RegisterMiddleware("PlayerData", function(player, data)
    return player:IsInGroup(123456)  -- Only allow players in group 123456
end)
```

### Firing a Remote to Nearby Players

Fire a remote to all players within a 100-stud radius of a specific position.

```lua
local position = Vector3.new(0, 10, 0)
Remotes:FireAllNearby("AlertNearby", position, 100, "An event occurred nearby!")
```

### Connecting a Callback to an Existing Remote

Attach a callback function to run when a remote is fired.

```lua
Remotes:Connect("PlayerJoined", function(player)
    print(player.Name .. " joined the game.")
end)
```

### Destroying a Remote and Handling Cleanup

Destroy a remote when it's no longer needed and execute cleanup code.

```lua
local api = Remotes:Get("TemporaryEvent")

api:OnDestroying(function(name)
    print(name .. " is being destroyed.")
end)

api:Destroy()
```

### Using Grouped Event Names

You can organize events into "groups" by naming them with a prefix, separated by a colon (e.g., `PointsService:GetPoints`). This allows for structured and readable event names within your system.

```lua
-- Register an event under the "PointsService" group
Remotes:Register("PointsService:GetPoints", "RemoteFunction", function(player)
    -- Assume there's a function that retrieves points for a player
    local points = PointsService:GetPlayerPoints(player.UserId)
    return points
end)

-- Retrieve and use the grouped event
local pointsRemote = Remotes:Get("PointsService:GetPoints")

if pointsRemote then
    local playerPoints = pointsRemote:Fire(somePlayer)
    print("Player's points:", playerPoints)
end
```

In this example, `PointsService:GetPoints` is treated as a single, valid event name, enabling a structured namespace approach for grouping related events in the `KnightRemotes` module.
