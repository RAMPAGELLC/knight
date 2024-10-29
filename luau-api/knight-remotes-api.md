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

#### Remotes:GetAsync(RemoteName: string) -> await RemoteAPI

Waits to receive the `RemoteAPI` associated with `RemoteName`.

* **Arguments**:
  * `RemoteName` (string): The name of the remote event/function to retrieve.
* **Returns**: `RemoteAPI` (yields until available).

#### Remotes:Get(RemoteName: string) -> RemoteAPI | boolean

Fetches the `RemoteAPI` for a given remote name synchronously.

* **Arguments**:
  * `RemoteName` (string): The name of the remote.
* **Returns**: `RemoteAPI` if available, otherwise `false`.

#### Remotes:Fire(RemoteName: string, ...) -> (any...)

Fires the specified remote to a particular player or event handler with the provided arguments.

* **Arguments**:
  * `RemoteName` (string): Name of the remote.
  * `...` (any): Arguments passed to the remote event.

#### Remotes:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...) -> (any...)

Fires the remote to all players within a specified `maxDistance` from `position`.

* **Arguments**:
  * `RemoteName` (string): The remote's name.
  * `position` (Vector3): The center position for nearby players.
  * `maxDistance` (number | boolean): The maximum radius (defaults to `50` if `true`).
  * `...` (any): Additional arguments passed to the remote.

#### Remotes:FireAll(RemoteName: string, ...) -> (any...)

Fires the remote event for all connected players.

* **Arguments**:
  * `RemoteName` (string): The remote's name.
  * `...` (any): Arguments passed to each connected player.

#### Remotes:Connect(RemoteName: string, callback: () -> void | nil | boolean) -> void

Attaches a callback to the specified remote. This callback is triggered each time the remote event is fired.

* **Arguments**:
  * `RemoteName` (string): The name of the remote.
  * `callback` (function): The function to be executed on remote event.

#### Remotes:Register(RemoteName: string, RemoteClass: string, Callback: any) -> void

Registers a new remote with a specified class and optional callback.

* **Arguments**:
  * `RemoteName` (string): The name for the new remote.
  * `RemoteClass` (string): The class type (e.g., `RemoteFunction`).
  * `Callback` (function, optional): A function for the remote.

#### Remotes:RegisterMiddleware(Target: string, Callback: (Player: Player, ...any) -> boolean): void

Adds middleware for a specific remote, performing checks or validations before the remote is triggered.

* **Arguments**:
  * `Target` (string): The target remote or `*` for global middleware.
  * `Callback` (function): The middleware function that returns `true` to proceed or `false` to block.

#### Remotes:UnregisterMiddleware(Target: string): void

Removes the middleware associated with a target remote.

* **Arguments**:
  * `Target` (string): The name of the remote to remove middleware from.

### RemoteAPI Methods

**RemoteAPI:Fire(...) -> (any...)**

Triggers the remote with the provided arguments.

**RemoteAPI:FireAll(...) -> (any...)**

Fires the remote for all players.

**RemoteAPI:FireAllNearby(position: Vector3, maxDistance: number | boolean, ...) -> (any...)**

Triggers the remote for players within `maxDistance` of `position`.

**RemoteAPI:Connect(callback: () -> void | nil | boolean) -> void**

Attaches a callback to the remote event. Triggered upon the event firing.

**RemoteAPI:OnDestroying(callback: (RemoteName: string) -> void) -> void**

Sets a callback that runs when the remote is destroyed.

**RemoteAPI:Destroy()**

Cleans up and removes the remote from cache, firing any `OnDestroying` callbacks.

## Examples

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

## Firing a Remote to Nearby Players

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
