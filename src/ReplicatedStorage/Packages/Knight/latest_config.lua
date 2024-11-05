--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2024 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

return {
	TOO_LONG_LOAD_TIME = 20,
	CYCLIC_INDEXING_ENABLED = true,
	KEEP_SHARED_ON_CYCLIC_DISABLE = true,
	DO_NOT_WAIT = true,
	LOG_STARTUP_INFO = true,
	TRACKBACK_ON_STARTUP_TOOK_TOO_LONG = false,
	AUTOMATIC_REPORT_FRAMEWORK_ISSUES = false,
	SHUTDOWN_ON_LIBRARY_FAIL = true,
	SHUTDOWN_KICK_DELAY = 20,
	STARTUP_PRIORITY = {
		["Internal"] = 4,
		["Objects"] = 3,
		["Services"] = 2,
	},
}
