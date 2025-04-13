# What are services?



<figure><img src="../../.gitbook/assets/what are services.jpg" alt=""><figcaption></figcaption></figure>

## What are services?

Services are module scripts that serve a specific purpose within your experience. For example, you might have services dedicated to handling the user interface (UI), managing player points, or controlling game-specific logic.

## **Creating a Service**

To create a service, you’ll need to place a new `ModuleScript` in one of the designated Knight service folders based on its purpose:

* **Server-side services**: `Server`
* **Client-side services**: `Client`
* **Shared services**: `Shared`

## Default Functions

*   **`Init()`**: Called during the initialization phase of the service. This is optional and typically used for setting up any necessary data or connections before the service starts.

    ```lua
    function Knight:Init()
        -- Initialization logic here
    end
    ```
*   **`Start()`**: Called when the service is ready to begin its main functionality. This is also optional and is typically used to start processes like event listeners, timers, etc.

    ```lua
    function Knight:Start()
        -- Start logic here
    end
    ```
*   **`Update(deltaTime)`**: Called every frame. This function is optional and is used for tasks that need to be updated regularly, such as animations or game logic.

    ```lua
    function Knight:Update(deltaTime)
        -- Frame update logic here
    end
    ```

## Configuration Options

*   **`CanStart`**, **`CanUpdate`**, **`CanInit`**:

    These booleans determine whether the `Start()`, `Update()`, and `Init()` functions will be called.

{% hint style="success" %}
If you're using a third-party module and don't want Knight to call its default start functions or inject the framework, set `Standalone`to `true`. This will disable the metatable inject and other framework features to ensure it remains Standalone.
{% endhint %}

### Priority Startup

Folders named **"Database"** will have the first priority during initialization, followed by manual **"Priority"** set within the modu**le**. This is useful for ensuring that core game systems, such as data management, are loaded before other services.

{% hint style="info" %}
The default priority levels are as follows:

* Internal Services: 4
* Objects: 3
* Services: 2

You can adjust the startup priority by setting `Knight.Priority` to a specific number in the script. Higher priority numbers indicate an earlier startup.
{% endhint %}

## Additional Configuration

Optionally, if you have the instance named "**Init**" or "**EnivornmentInit**" or it has the collection tag "**KNIGHT\_IGNORE**" it will be automatically ignored and not inited/imported into the framework.&#x20;

{% hint style="warning" %}
We recommend using the Collection Tag only to mark Modules as in-active/disabled.
{% endhint %}

## Template

Each service in Knight follows a standard template structure:

```lua
local Knight = {
    -- Optional variables
    ServiceName = script.Name,
    ServiceData = {
        Author = "YourName",
        Description = "Description of what this service does"
    },
    
    -- Defaults to true if not specified.
    CanStart = true,
    CanUpdate = true,
    CanInit = true,
    
    -- Automatic .Priority calculation; this forces the dependencies to start before
    -- this service/controller does.
    Dependencies = {
        "shared/someAPI",
        "PlayerData"
    }
}

Knight.__index = Knight;

-- Optional
function Knight:Init()
    warn(self.ServiceName .. " Service Initialized!")
    
    -- For client services only
    print(self.Player.Name)  -- self.Player is an reference to the LocalPlayer.
    
    -- Access shared modules and functions
    self.Shared.SomeSharedModule:DoSomething()
    
    -- Access server or client-specific functionality
    self.Services.SomeOtherService:DoSomethingElse()
end

-- Optional
function Knight:Start()
    warn(self.ServiceName .. " Service Started!")
end

-- Optional
function Knight:Update(deltaTime)
    -- This is ran every frame; this works on server & client!
end

return Knight

```

> Article & Art by vq9o
