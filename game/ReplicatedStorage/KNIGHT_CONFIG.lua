-- Get essential services for later use
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- Define the configuration table for the Knight framework
local config

config = {
	GLOBAL_API_ENABLED = false, -- Enable or disable the exposed _G.Knight API

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
		if not config.AUTOMATIC_REPORT_FRAMEWORK_ISSUES then
			return
		end

		if not RunService:IsServer() then
			return
		end

		local SENTRY_CONFIG = require(ServerStorage.SENTRY_CONFIG) :: {
            SENTRY_KEY: string,
            SENTRY_URL: string,
        }

		pcall(function()
			local payload = {
				event_id = HttpService:GenerateGUID(false):gsub("-", ""),
				timestamp = os.time(),
				level = "error",
				logger = "knight.framework",
				platform = "roblox",
				environment = Environment,
				message = Issue,
				tags = {
					game_id = tostring(game.GameId),
					place_id = tostring(game.PlaceId),
				},
				server_name = game.JobId,
			}

			local headers = {
				["Content-Type"] = "application/json",
				["X-Sentry-Auth"] = string.format(
					"Sentry sentry_version=7, sentry_client=roblox/1.0, sentry_key=%s, sentry_timestamp=%d",
					SENTRY_CONFIG.SENTRY_KEY,
					os.time()
				),
			}

			HttpService:PostAsync(
				SENTRY_CONFIG.SENTRY_URL,
				HttpService:JSONEncode(payload),
				Enum.HttpContentType.ApplicationJson,
				false,
				headers
			)
		end)
	end,

	-- Specifies whether the game should shut down if the library initialization fails
	SHUTDOWN_ON_LIBRARY_FAIL = true,

	-- The delay (in seconds) before kicking players after a shutdown is triggered due to library failure
	SHUTDOWN_KICK_DELAY = 20,

	-- Defines the startup priorities for various Knight components
	-- Internal components have the highest priority, followed by objects, then services
	STARTUP_PRIORITY = {
		["Internal"] = 4, -- Priority level 4 (highest) for internal components
		["Objects"] = 3, -- Priority level 3 for objects
		["Services"] = 2, -- Priority level 2 for services
	},
}

-- Return the configuration table to be used throughout the Knight framework
return config
