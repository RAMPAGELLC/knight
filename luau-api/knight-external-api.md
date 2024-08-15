# Knight External API

<figure><img src="../.gitbook/assets/knight external api.jpg" alt=""><figcaption></figcaption></figure>

The `ReplicatedStorage.Packages.Knight` module is the core of the Knight framework. It provides essential functions for managing the framework's initialization, service access, logging, and module imports. This module is the backbone of the Knight system, handling both server-side and client-side logic depending on the environment/context in which it is run.

## Accessing the Knight API Module

To use the `Knight` module, you first need to require it:

```lua
local Knight = require(game.ReplicatedStorage.Packages.Knight)
```

Once you have access to the module, you can use its various core functions.

#### Functions Overview

***

### `Knight.Core.Log(Type: string, ...)`

**Description**:\
Logs messages to the console, with support for different log levels (`print`, `warn`, `error`). This function prefixes the log with the Knight framework version for easy identification.

**Usage**:

```lua
Knight.Core.Log("print", "Knight Framework has started.")
```

**Parameters**:

* `Type: string`: The type of log (`"print"`, `"warn"`, `"error"`).
* `...`: The message or messages to log.

***

### `Knight:PrintVersion()`

**Description**:\
Prints the current version of the Knight framework to the console. Useful for tracking which version of the framework is currently running.

**Usage**:

```lua
Knight:PrintVersion()
```

**Parameters**:\
None.

**Returns**:\
None.

***

### `Knight.Core.Import(Path: string)`

**Description**:\
Imports a module based on the specified path. This function handles importing from different parts of the framework (`Knight/Shared`, `Knight/Client`, `Knight/Server`, etc.) and external systems like KPM.

**Usage**:

```lua
local Module = Knight.Core.Import("Knight/Shared/MyModule")
```

**Parameters**:

* `Path: string`: The path to the module you want to import.

**Returns**:\
The module at the specified path, or throws an error if the path is invalid or not found.

***

### `Knight.Core:GetStorage(IsShared: boolean | nil)`

**Description**:\
Fetches the appropriate Knight storage context based on whether the request is for shared storage or not. This method is responsible for locating the storage in the server (`ServerStorage`) or client (`PlayerScripts`), or the shared space (`ReplicatedStorage`).

**Usage**:

```lua
local Storage = Knight.Core:GetStorage(true)  -- Fetch shared storage
```

**Parameters**:

* `IsShared: boolean | nil`: If `true`, fetches the shared storage from `ReplicatedStorage`. If `false` or `nil`, fetches the storage specific to the environment (server or client).

**Returns**:\
The storage context (`ServerStorage`, `PlayerScripts`, or `ReplicatedStorage`).

***

### `Knight.Core:GetShared()`

**Description**:\
Deprecated. Fetches shared storage. Use `Knight.Core:GetStorage(true)` instead.

**Usage**:

```lua
local SharedStorage = Knight.Core:GetShared()
```

**Parameters**:\
None.

**Returns**:\
The shared storage context (`ReplicatedStorage`).

{% hint style="danger" %}
This method is deprecated and will print a warning recommending the use of `Knight.Core:GetStorage(true)`.
{% endhint %}

***

### `Knight.Core:Init()`

**Description**:\
Initializes the Knight framework, setting up the internal environment and populating the `_G.Knight` global variable with the API and shared resources. This method also ensures that the required "Init" module is present in the storage context and loads it.

**Usage**:

```lua
Knight.Core:Init()
```

**Returns**:\
`Knight`: The Knight module itself.\
`_G.Knight.API`: The initialized API.

***

#### Example Usage

Below is an example of how you might use the Knight API module in your game:

```lua
local Knight = require(game.ReplicatedStorage.Packages.Knight)

-- Initialize the Knight framework
local KnightInstance, KnightAPI = Knight.Core:Init()

-- Import a shared module
local MySharedModule = Knight.Core.Import("Knight/Shared/MyModule")

-- Print the framework version
Knight:PrintVersion()

-- Log a message
Knight.Core.Log("print", "Knight framework initialized successfully!")

-- Fetch storage
local Storage = Knight.Core:GetStorage(true)
```

#### Best Practices

* **Use `Knight.Core.Import()`**: This method allows for clean and dynamic importing of modules based on their paths within the framework. Be sure to use correct paths to avoid import errors.
* **Initialize Once**: Always initialize the Knight framework at the start of your game using `Knight.Core:Init()`. This sets up the internal environment and ensures services are loaded correctly.
* **Log with Context**: Use `Knight.Core.Log()` to log important events, errors, or warnings during runtime, especially during initialization and service execution.



> Article & Art by vq9o
