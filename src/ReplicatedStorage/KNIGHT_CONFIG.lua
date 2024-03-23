local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local config;config = {
	LOG_STARTUP_INFO = true,
	AUTOMATIC_REPORT_FRAMEWORK_ISSUES = true,
	REPORT_FUNC = function(Enivornment: string, Issue: string)
        if not config.AUTOMATIC_REPORT_FRAMEWORK_ISSUES then return end
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
}

return config;