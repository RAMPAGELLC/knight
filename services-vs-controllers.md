# Services vs Controllers

In the Knight Framework, the architecture is centered around **Services**. These are modules that encapsulate your game’s business logic, game state, and communication between the client and server.

While other frameworks often refer to client-side modules as **Controllers** for readability and clarity, under the hood, **everything is just a Service**.

***

## What is a Service?

A **Service** in Knight is any module placed in:

* `src/ServerStorage/Knight/Services` (server-side)
* `src/StarterPlayer/StarterPlayerScripts/Knight/Services` (client-side)
* `src/ReplicatedStorage/Knight/Shared/Services` (shared)

Services are automatically loaded and managed by the framework, and can depend on other Services via `self.Services`.

### Examples:

<pre class="language-lua"><code class="lang-lua">-- Server-side Service
local Players = game:GetService("Players")

local PlayerService= {}
PlayerService.__index = PlayerService;

function PlayerService:Start()
	Players.PlayerAdded:Connect(function(player)
		print("Player joined:", player.Name)
<strong>	end)
</strong>end

return PlayerService
</code></pre>

```lua
-- Client-side "Controller" (Still a Service under the hood)

local CameraController = {}
CameraController.__index = CameraController;

function CameraController:Start()
	print("Camera controller started")
end

return CameraController
```

***

## Why Call Them "Controllers" on the Client?

While technically still Services, developers often call client-side services **Controllers** because:

* They manage _input_, _UI_, _camera_, _audio_, and other _player-facing systems_
* It helps mentally separate **game logic** (server) from **player experience** (client)
* It mirrors common frontend/backend naming conventions

This naming convention is **optional** and purely for developer ergonomics.

***

## Best Practices

### 1. **Keep Logic Scoped to the Right Context**

* Server Services should **never** assume presence of GUI elements or player input.
* Client Services (aka Controllers) should **never** mutate global game state or kick players.

### 2. **Name Clearly and Consistently**

Use suffixes if it helps readability:

```lua
-- Server
PlayerService
InventoryService

-- Client
CameraController
HUDController
InputController
```

### 3. **Shared Services Are Powerful**

If you have logic that both client and server need (like data validation, math utilities, enum definitions), place them in `Knight/Shared/Services`.

Avoid placing business logic here — shared services should be **deterministic and stateless** when possible.

***

### Summary

| Concept        | Definition                                              |
| -------------- | ------------------------------------------------------- |
| Service        | A module that runs logic in the Knight Framework        |
| Controller     | A naming convention for client-side services            |
| Shared Service | A deterministic module usable by both client and server |

Ultimately, whether you call them Services or Controllers — **they all follow the same lifecycle** and are powered by the same Service system behind the scenes.

Stick to what makes sense for your team and stay consistent.

