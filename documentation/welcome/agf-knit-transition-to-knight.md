# AGF/Knit Transition to Knight

<figure><img src="../../.gitbook/assets/AGFKnitTransition.jpg" alt=""><figcaption></figcaption></figure>

## **Introduction**

As Roblox developers, you may have been using frameworks like AeroGameFramework (AGF) or Knit to structure your projects. Both of these frameworks follow a modular approach, offering client-server communication patterns, service organization, and utilities that ease game development. Now, if you're transitioning to the **Knight framework**, this article will guide you through key differences, similarities, and how to adjust your workflow to fit the Knight framework’s approach.

## **Why Transition to Knight?**

The **Knight framework** offers a flexible, modular, and scalable structure tailored for Roblox development. It emphasizes strong typing, configuration through enums and types, and integrates easily with modern tools. Here are some reasons you might consider transitioning:

* **Enhanced modularity** with well-defined service and object separation.
* **Configurable behaviors** using `KNIGHT_CONFIG`, `KNIGHT_ENUM`, and `KNIGHT_TYPES`.
* **Improved organization** of shared, client, and server scripts across the game's services.
* **Seamless replication** and synchronization mechanisms that optimize network calls.

## **Key Concepts in Knight**

Before jumping into code, let’s go over some key concepts in the Knight framework:

1. **Services**: Just like in AGF or Knit, Knight uses **Services** to structure server-side and shared logic. Services are stored under `ReplicatedStorage/Knight/Services` for shared services and `ServerScriptService/Knight/Services` for server-only services.
2. **Objects**: These are reusable components, typically representing specific game logic that can be instantiated multiple times. Knight encourages storing these under `ReplicatedStorage/Knight/Objects`.
3. **Configurations and Types**: Knight makes heavy use of configuration files like `KNIGHT_CONFIG.lua` and `KNIGHT_TYPES.lua`, which define custom behaviors, types, and constants to be reused across the codebase.
4. **Packages**: Knight uses a `Packages` folder structure that contains utilities or third-party packages. This setup is similar to how AGF or Knit organizes third-party dependencies.

## **Transitioning from AGF/Knit to Knight**

Let’s break down the transition by focusing on core areas like **service management**, **client-server communication**, and **initialization logic**.

***

## **1. Service Management in Knight**

In AGF/Knit, services are organized in `ServerScriptService` or `ReplicatedStorage` (for shared services). Similarly, Knight organizes services across these locations, but with a focus on stronger separation between server-only and shared services.

**AGF/Knit Example:**

```lua
-- KnitService Example
local PointsService = Knit.CreateService {
    Name = "PointsService",
    Client = {},
}

function PointsService:AwardPoints(player, amount)
    -- Logic to award points to the player
end
```

**Knight Example:**

In Knight, services are also module-based and are organized under `Knight/Services`. Here's a transition example of how you would define a service in Knight:

```lua
-- KnightService
local PointsService = {}

function PointsService:AwardPoints(player, amount)
    -- Logic to award points to the player
end
```

## **2. Client-Server Communication**

In AGF/Knit, client-server communication is handled via `RemoteFunction` or `RemoteEvent` abstractions like `Client` tables within services. Knight, on the other hand, exposes **remote functions** and **remote events** dynamically through the `Knight.Remotes` API.

**AGF/Knit Example:**

```lua
-- Server-side Knit service with a remote method
PointsService.Client.GetPoints = function(self, player)
    return PointsService:GetPlayerPoints(player)
end

-- Client-side
function ClientPointService:Start()
    local points = Knit.GetService("PointsService"):GetPoints()
end
```

**Knight Example:**

In Knight, you would dynamically expose server functions to the client using the **Exposed-Server Functions API**. Here’s how you would achieve the same functionality:

```lua
-- Server-side Knight Service
local PointsService = {}
PointsService.Client = {}

function PointsService.Client:GetPoints(player)
    return PointsService:GetPlayerPoints(player)
end

-- Client-side
function ClientPointService:Start()
    local points = self.Server.PointsService:GetPoints()
end
```

## **3. Initialization and Configuration**

Both AGF and Knit have initialization flows, but in Knight, you have more configuration options using the `KNIGHT_CONFIG.lua` and `KNIGHT_TYPES.lua` files to specify game-wide settings and behaviors.

**AGF/Knit Example:**

```lua
Knit.Start():Then(function()
    print("Knit started")
end):Catch(warn)
```

**Knight Example:**

<pre class="language-lua"><code class="lang-lua"><strong>require(game:GetService("ReplicatedStorage").Packages.Knight).Core.Init()
</strong></code></pre>

***

## **Adapting to Knight’s Structure**

As you transition to Knight, it’s important to understand its directory structure and how services, objects, and configurations are separated:

* **Server-only services**: `src/ServerScriptService/Knight/Services`
* **Shared services**: `src/ReplicatedStorage/Knight/Services`
* **Objects (reusable game logic)**: `src/ReplicatedStorage/Knight/Objects`
* **Configuration files**: `src/ReplicatedStorage/KNIGHT_CONFIG.lua`, `KNIGHT_ENUM.lua`, `KNIGHT_TYPES.lua`

This clear separation of concerns allows for easier management of client-server logic and reusable components. We highly recommend going to [.](./ "mention")to read further about our framework!
