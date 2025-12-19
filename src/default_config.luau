return {
	ERROR_EN_WITH_REF_ID = [[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue has been automatically reported based on the experience privacy settings, however please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font> <br /><br /><br /><font face="GothamMedium" size="35">KNIGHT ERROR REPORT REFERENCE ID:</font><br /><font face="Jura" size="55">%s</font>]],
	ERR_EN_NO_REF_ID = [[<b><font size="130" face="GothamBold">An error occured</font></b><font face="GothamMedium" size="35"><br /> A error occured within the Knight Framework. This issue originated from a custom-class, please report this to the experience developer(s). You will be disconnected in <b>%s</b> seconds.</font>]],

	-- Specifies the default startup priority for services/controllers without a defined priority
	DEFAULT_STARTUP_PRIORITY = 1,

	-- Specifies the time limit (in seconds) before considering a service to be taking too long to load
	TOO_LONG_LOAD_TIME = 20,

	-- Enables or disables cyclic indexing between services, allowing services to reference each other directly
	CYCLIC_INDEXING_ENABLED = true,

	-- Keeps shared resources accessible even if cyclic indexing is disabled
	KEEP_SHARED_ON_CYCLIC_DISABLE = true,

	-- Disables waiting for non-essential services to load during initialization
	DO_NOT_WAIT = true,

	-- Enables logging of startup information for debugging and diagnostics (enable to debug startup times)
	LOG_STARTUP_INFO = false,

	-- Enables tracking if a service/controller is taking too long; false means no warnings or errors for long startups
	TRACKBACK_ON_STARTUP_TOOK_TOO_LONG = false,

	-- Specifies whether the game should shut down if the service/controller initialization fails
	SHUTDOWN_ON_LIBRARY_FAIL = true,

	-- The delay (in seconds) before kicking players after a shutdown is triggered due to service/controller failure
	SHUTDOWN_KICK_DELAY = 20,

	-- Defines the startup priorities for various Knight components
	-- Internal components have the highest priority, followed by objects, then services
	STARTUP_PRIORITY = {
		["Internal"] = 4, -- Priority level 4 (highest) for internal components
		["Objects"] = 3, -- Priority level 3 for objects
		["Services"] = 2, -- Priority level 2 for services
		["Controllers"] = 2, -- Priority level 2 for controllers (services alias for client)
	},

	-- Enables or disables self.Remotes pointing to "knight/shared/Service/Remotes" - Requires the Knight Remotes library
	ENABLE_KNIGHTDOTREMOTES = true,

	-- List of indexes to keep when CYCLIC_INDEXING_ENABLED is false
	CYCLIC_DISABLE_KEEP_INDEX = {
		"Player",
		"Enum",
		"initStart",
		"Inited",
		"KnightCache",
		"GetService",
		"Remotes",
	},
}
