local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local config

config = {
	TOO_LONG_LOAD_TIME = 20,
	CYCLIC_INDEXING_ENABLED = true,
	KEEP_SHARED_ON_CYCLIC_DISABLE = true,
	DO_NOT_WAIT = true,
	LOG_STARTUP_INFO = true,
	TRACKBACK_ON_STARTUP_TOOK_TOO_LONG = false,
	AUTOMATIC_REPORT_FRAMEWORK_ISSUES = false,
	REPORT_FUNC = function(Enivornment: string, Issue: string)
		if not config.AUTOMATIC_REPORT_FRAMEWORK_ISSUES then
			return
		end
		if RunService:IsServer() then
			pcall(function()
				HttpService:PostAsync(
					"https://api.vq9o.com/knight-issues.php",
					HttpService:JSONEncode({
						GAME_ID = game.GameId,
						PLACE_ID = game.PlaceId,
						ENVIORNMENT = Enivornment,
						ISSUE = Issue,
					})
				)
			end)
		end
	end,
	SHUTDOWN_ON_LIBRARY_FAIL = true,
	SHUTDOWN_KICK_DELAY = 20,
	STARTUP_PRIORITY = {
		["Internal"] = 4,
		["Objects"] = 3,
		["Services"] = 2,
	},
}

return config