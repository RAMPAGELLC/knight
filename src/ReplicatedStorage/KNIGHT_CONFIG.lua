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
    LOG_STARTUP_INFO = false,

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