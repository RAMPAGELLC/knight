# What are services?



<figure><img src="../.gitbook/assets/what are services.jpg" alt=""><figcaption></figcaption></figure>

## What are services?

Services are module scripts that serve a specific purpose within your experience. For example, you might have services dedicated to handling the user interface (UI), managing player points, or controlling game-specific logic.

## **Creating a Service**

To create a service, you’ll need to place a new `ModuleScript` in one of the designated Knight service folders based on its purpose:

* **Server-side services**: `src/ServerStorage/Knight`
* **Client-side services**: `src/StarterPlayer/StarterPlayerScripts/Knight`
* **Shared services**: `src/ReplicatedStorage/Knight`

## Default Functions

*   **`Init()`**: Called during the initialization phase of the service. This is optional and typically used for setting up any necessary data or connections before the service starts.

    ```lua
    function Knight.Init()
        -- Initialization logic here
    end
    ```
*   **`Start()`**: Called when the service is ready to begin its main functionality. This is also optional and is typically used to start processes like event listeners, timers, etc.

    ```lua
    function Knight.Start()
        -- Start logic here
    end
    ```
*   **`Update(deltaTime)`**: Called every frame. This function is optional and is used for tasks that need to be updated regularly, such as animations or game logic.

    ```lua
    function Knight.Update(deltaTime)
        -- Frame update logic here
    end
    ```

## Configuration Options

*   **`CanStart`**, **`CanUpdate`**, **`CanInit`**:

    These booleans determine whether the `Start()`, `Update()`, and `Init()` functions will be called.

{% hint style="info" %}
If you're using a third-party module and don't want Knight to call its default start function, set `CanStart` to `false`.
{% endhint %}

### Priority Startup

Folders named **"Database"** will have the first priority during initialization, followed by manual **"Priority"** set within the modu**le**. This is useful for ensuring that core game systems, such as data management, are loaded before other services.

{% hint style="info" %}
Default Priority's is;

* For Internal Services it's 4.
* For Objects its 3
* For Services its 2

You can manually set the Priority to startup sooner or latet by setting Knight.Priority to a number in the script. Higher Priority = Start's sooner.
{% endhint %}

## Template

Each service in Knight follows a standard template structure:

```lua
local Knight = {
    ServiceName = script.Name,
    ServiceData = {
        Author = "YourName",
        Description = "Description of what this service does"
    },
    CanStart = true,
    CanUpdate = true,
    CanInit = true,  -- Optional, defaults to true if not specified
}

function Knight:Init()
    warn(Knight.ServiceName .. " Service Initialized!")
end

function Knight:Start()
    warn(Knight.ServiceName .. " Service Started!")
end

function Knight:Update(deltaTime)
    -- This is ran every frame
end

return Knight

```

## Example Service Class

```lua
local Knight = {
    ServiceName = script.Name,
    ServiceData = {
        Author = "YourName",
        Description = "This service manages the game's UI"
    },
    CanStart = true,
    CanUpdate = false,
}

function Knight.Init()
    -- For client services only
    print(Knight.Player.Name)  -- Prints the LocalPlayer's name
    
    -- Access shared modules and functions
    local sharedModule = Knight.Shared.SomeModule
    sharedModule:DoSomething()
    
    -- Access server or client-specific functionality
    Knight.Services.SomeOtherService:DoSomethingElse()
end

return Knight

```

> Article & Art by vq9o
