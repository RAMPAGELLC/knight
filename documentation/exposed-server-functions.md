# Exposed-Server Functions

<figure><img src="../.gitbook/assets/Exposed-server functions.jpg" alt=""><figcaption></figcaption></figure>

## **Overview**

In many modern Roblox frameworks, such as AeroGameFramework (AGF) or Knit, we expose server-side functions to the client through a structured and dynamic API. This pattern allows client scripts to access and invoke specific server functions seamlessly, mimicking the way you'd call local functions. These exposed server functions simplify client-server communication, ensuring that server-side logic can be invoked safely and efficiently from the client without manual remote event handling.

## **What Are Exposed-Server Functions?**

Exposed-server functions are server-side functions that are exposed to clients for remote invocation. These functions are wrapped around `RemoteFunction`s, allowing clients to call server-side logic just like they would call a local method.

### **Example Structure:**

```lua
-- Client-Side Example
local points = self.Server.PointsService:GetLocalPoints()
print("Received points:", points)
```

In this example, `PointsService` is a server-side service, and `GetLocalPoints` is a remote function exposed to the client. The client can directly call this function, and the server handles the logic.

## **How Exposed-Server Functions Work**

Exposed-server functions rely on a dynamic system that abstracts remote communication through a combination of **metatables**. This system allows developers to access server services and their exposed functions as if they were local.

### **Key Concepts:**

* **Service Name**: Represents the name of the service that contains the server logic (e.g., `PointsService`).
* **Event/Function Name**: Represents the name of the server function that you want to call remotely (e.g., `GetLocalPoints`).
* **Remote Function**: A `RemoteFunction` object on the server that handles requests from the client and returns a result.

## **Client-Side Usage**

On the client-side, you access these exposed functions via the `self.Server` object, which allows you to call server functions as if they were local.

### **Example:**

```lua
-- Client-side
local points = self.Server.PointsService:GetLocalPoints() -- Calling the exposed server function
print("Received points:", points) -- Output the result
```

## **Server-Side Implementation**

On the server, the functions that the client can call are registered and exposed through a dynamic API. These functions are typically defined within services and then registered as RemoteFunctions that the client can invoke.

### **Server-Side Example:**

```lua
local PointsService = {}
PointsService.Client = {}

-- Define a server-side function exposed to the client

-- Do note, everything ran inside this function is on the Server runtime.
-- Also do not worry, important variables like passwords are not exposed 
-- as we use roblox's networking solutions
function PointsService.Client:GetLocalPoints(Player: Player)
    -- This function is invoked by the client
    -- You can implement your logic here, such as fetching data from a database
    local points = 100 -- Example points logic
    return points -- Return the result to the client
end

return PointsService
```

In the example above:

* **PointsService** is the service.
* **GetLocalPoints** is the function within the service that the client can call.
* The function handles server-side logic, such as retrieving the player's points, and returns the result to the client.

#### **Why Use Exposed-Server Functions?**

1. **Simplified Client-Server Communication**:
   * The client doesn't need to manually handle RemoteFunction objects. Instead, they can call server functions as if they were local, making the code easier to read and manage.
2. **Dynamic and Flexible**:
   * Since service and function names are dynamically resolved using metatables, this system allows for easy scaling and customization. You can add new services and functions without changing much client-side code.

#### **Common Use Cases**

*   **Fetching Player Data**:

    * Clients often need to request data stored on the server (e.g., player points, inventory, etc.).

    ```lua
    local points = self.Server.PointsService:GetLocalPoints()
    ```
*   **Server-side Calculations**:

    * Sometimes the client may need to request complex calculations from the server.

    ```lua
    local result = self.Server.MathService:CalculateDistance(pointA, pointB)
    ```
*   **Interacting with Game State**:

    * Clients can send requests to update the game state, such as interacting with NPCs or triggering server-side events.

    ```lua
    self.Server.NPCService:TriggerInteraction(npcId)
    ```
