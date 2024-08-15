# Configuring Knight

<figure><img src="../.gitbook/assets/Configuring Knight.jpg" alt=""><figcaption></figcaption></figure>

## Configuring Knight

The `KNIGHT_CONFIG.lua` file is the core configuration file for the Knight framework, allowing developers to customize Knight’s behavior and optimize it for specific project requirements. This configuration file is located in `src/ReplicatedStorage` and contains settings that affect how services and other aspects of Knight operate.

## Setting Up `KNIGHT_CONFIG.lua`

By default, the `KNIGHT_CONFIG.lua` file might look like this:

```lua
-- Get essential services for later use
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Define the configuration table for the Knight framework
local config

config = {
    -- Specifies the time limit (in seconds) before considering a service to be taking too long to load
    TOO_LONG_LOAD_TIME = 20,

    -- Enables or disables cyclic indexing between services, allowing services to reference each other directly
    CYCLIC_INDEXING_ENABLED = true,

    -- Keeps shared resources accessible even if cyclic indexing is disabled
    KEEP_SHARED_ON_CYCLIC_DISABLE = true,

    -- Disables waiting for non-essential services to load during initialization
    DO_NOT_WAIT = true,

    -- Enables logging of startup information for debugging and diagnostics
    LOG_STARTUP_INFO = true,

    -- Enables tracking if startup is taking too long; false means no warnings or errors for long startups
    TRACKBACK_ON_STARTUP_TOOK_TOO_LONG = false,

    -- If true, the framework will automatically report any issues to a predefined external service
    AUTOMATIC_REPORT_FRAMEWORK_ISSUES = false,

    -- Function to report issues automatically when AUTOMATIC_REPORT_FRAMEWORK_ISSUES is enabled
    -- Only runs on the server to avoid unnecessary client requests
    REPORT_FUNC = function(Environment: string, Issue: string)
        -- Check if automatic issue reporting is enabled
        if not config.AUTOMATIC_REPORT_FRAMEWORK_ISSUES then
            return -- Exit if reporting is disabled
        end
        -- Ensure the code is running on the server before proceeding with the report
        if RunService:IsServer() then
            -- Attempt to send the issue report asynchronously using HTTP POST
            pcall(function()
                HttpService:PostAsync(
                    "https://api.vq9o.com/knight-issues.php",  -- Endpoint for reporting issues
                    HttpService:JSONEncode({ -- Encode the report as JSON
                        GAME_ID = game.GameId,  -- Include the game ID in the report
                        PLACE_ID = game.PlaceId, -- Include the specific place ID
                        ENVIRONMENT = Environment,  -- Include the environment (e.g., development/production)
                        ISSUE = Issue,  -- Include a description of the issue
                    })
                )
            end)
        end
    end,

    -- Specifies whether the game should shut down if the library initialization fails
    SHUTDOWN_ON_LIBRARY_FAIL = true,

    -- The delay (in seconds) before kicking players after a shutdown is triggered due to library failure
    SHUTDOWN_KICK_DELAY = 20,

    -- Defines the startup priorities for various Knight components
    -- Internal components have the highest priority, followed by objects, then services
    STARTUP_PRIORITY = {
        ["Internal"] = 4,  -- Priority level 4 (highest) for internal components
        ["Objects"] = 3,   -- Priority level 3 for objects
        ["Services"] = 2,  -- Priority level 2 for services
    },
}

-- Return the configuration table to be used throughout the Knight framework
return config

```

This configuration file returns a table containing various settings. These settings can be customized to control how Knight behaves within your project.

## Key Configuration Options

Let’s break down each of these configuration settings:

1. **`TOO_LONG_LOAD_TIME`**\
   This setting defines the maximum time (in seconds) that a service can take to load before it is flagged as taking too long. This is useful for identifying performance bottlenecks during game startup.
2. **`CYCLIC_INDEXING_ENABLED`**\
   This flag allows services to cyclically reference each other via the `Knight.Services.ServiceName` pattern. When enabled (the default), services can directly call other services within the framework, even if they depend on each other. Disabling this setting may improve performance in larger projects by reducing memory overhead.
3. **`KEEP_SHARED_ON_CYCLIC_DISABLE`**\
   This option retains shared services and data even if `CYCLIC_INDEXING_ENABLED` is disabled. This is particularly useful when you still want to allow shared resources to be accessible while preventing full cyclic dependencies between services.
4. **`DO_NOT_WAIT`**\
   When enabled, Knight will not wait for non-essential services to load during initialization. This can help speed up game startup times by skipping non-critical services that can be started later or asynchronously.
5. **`LOG_STARTUP_INFO`**\
   This flag enables logging of startup information. If set to `true`, Knight will log details about service startup, which can be useful for debugging and performance analysis.
6. **`TRACKBACK_ON_STARTUP_TOOK_TOO_LONG`**\
   When enabled, this setting tracks whether startup is taking too long and logs warnings or errors if necessary. This can help identify potential bottlenecks in the game’s loading process.
7. **`AUTOMATIC_REPORT_FRAMEWORK_ISSUES`**\
   If this option is set to `true`, Knight will automatically report any issues encountered by the framework to an external endpoint. This is useful for tracking bugs or problems in real time. Reporting only occurs on the server side to avoid unnecessary client requests.
8. **`REPORT_FUNC`**\
   This function is used to send issue reports to a predefined external service. The function collects environment-specific data (such as the game’s ID and the place’s ID) and sends a JSON-encoded report to the endpoint. This function only runs when `AUTOMATIC_REPORT_FRAMEWORK_ISSUES` is enabled, and only on the server to ensure efficiency.
9. **`SHUTDOWN_ON_LIBRARY_FAIL`**\
   This option ensures that the game will automatically shut down if the Knight framework fails to initialize. This prevents the game from running in an incomplete or broken state.
10. **`SHUTDOWN_KICK_DELAY`**\
    Defines the delay (in seconds) before kicking players after a shutdown is triggered due to a Knight library failure. This gives players a buffer period before being disconnected.
11. **`STARTUP_PRIORITY`**\
    This table defines the priority order for starting Knight’s components. Higher numbers indicate higher priority, meaning components with higher priority numbers are started first. This is useful when certain components (e.g., internal systems) need to be initialized before others (e.g., services).

### Example Usage Scenarios

#### **Debugging Startup**

To debug startup performance, you might want to enable both `LOG_STARTUP_INFO` and `TRACKBACK_ON_STARTUP_TOOK_TOO_LONG`. These settings will log all startup activities and notify you if any services are taking too long to load:

```lua
return {
    LOG_STARTUP_INFO = true,
    TRACKBACK_ON_STARTUP_TOOK_TOO_LONG = true,
}
```

#### **Reporting Framework Issues**

If you want to automatically report framework issues in production environments but not during development, you can use the following configuration:

```lua
local isDevelopment = false  -- Set this flag based on your environment

return {
    AUTOMATIC_REPORT_FRAMEWORK_ISSUES = not isDevelopment,  -- Only report in production
}
```

#### **Optimizing Startup Times**

To speed up startup times by only loading critical services immediately, you could enable `DO_NOT_WAIT`:

```lua
return {
    DO_NOT_WAIT = true,
}
```

## Configuring Knight to Match Your Game's Needs

Configuring Knight is essential for customizing the framework to match your game’s needs. By adjusting the `KNIGHT_CONFIG.lua` file, you can control core features like service initialization, debugging, and memory optimization.

Whether you’re working on a small-scale game or a massive online experience, the flexibility provided by Knight’s configuration allows you to fine-tune performance, control service behavior, and ensure your game operates smoothly under various conditions.

## Best Practices for Configuration

* **Start Simple**: When first starting out, it’s a good idea to keep the configuration simple with the default settings and then gradually introduce more advanced options like priority folders and environment-specific settings as your game grows.
* **Test Configurations**: If you disable `CYCLIC_INDEXING_ENABLED`, be sure to test all services thoroughly to ensure they still function correctly with `GetService`.
* **Use DebugMode Wisely**: Enable `DebugMode` during development to help identify any issues or service dependencies. Remember to disable it for production to reduce unnecessary logging.

> Article & Art by vq9o
