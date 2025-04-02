--[[

 Copyright (c) 2024 RAMPAGE Interactive. All rights reserved.
 Copyright (c) 2024 Metatable Games. All rights reserved.
 
 Written by crn_tl <development@vortexz.net> and vq9o <business@vq9o.com>
]]

--[[

➜ ModerationModule:PermbanPlayerAsync()
	player: player: Player; or players as userID : {number}
	displayreason: reason displayed to the player on ban screen
	modnotice: notes for the ban from the moderator. private and only viewable by staff
	ApplyToUniverse: applies to universe or place specific {boolean}
	
		returns: boolean (true, false)
	
➜ ModerationModule:TempbanPlayerAsync()
	player: player: Player; or players as userID : {number}
	duration: string like 1d, 4d, 1y or numbers in seconds
	displayreason: reason displayed to the player on ban screen
	modnotice: notes for the ban from the moderator. private and only viewable by staff
	ApplyToUniverse: applies to universe or place specific {boolean}
	
		returns: boolean (true, false)

➜ ModerationModule:UnbanPlayerAsync()
	player: player userid or players userids
	ApplyToUniverse: applies to universe or place specific {boolean}
	
		returns: boolean (true, false)
	
➜ ModerationModule:GetPlayerBanAsync()
	player: player userid or players userids
	
		returns: table {}

]]

local PlayerService = game:GetService("Players")
local ModerationModule = {}

function ModerationModule:ConvertTimestamp(Timestamp: string)
	-- Convert timestrings like 6d into seconds
	local Multipliers = {
		s = 1,
		m = 60,
		h = 3600,
		d = 86400,
		w = 604800,
		y = 31556926
	}

	local Number, Unit = Timestamp:match("(%d+)(%a)")

	if Multipliers[Unit] then
		return Number * Multipliers[Unit]
	end
end

function ModerationModule:PermbanPlayerAsync(player: Player | {number}, displayreason: string, modnotice: string, ApplyToUniverse: boolean) : boolean
	if not (typeof(player) == "table") then
		player = {player.UserId}
	end

	local BanConfig : BanConfigType = {
		UserIds = player,
		Duration = -1;
		DisplayReason = displayreason,
		PrivateReason = modnotice,
		ExcludeAltAccounts = false,
		ApplyToUniverse = ApplyToUniverse
	}

	local success, errormessage = pcall(function()
		return PlayerService:BanAsync(BanConfig);
	end)

	if not success then
		warn("An error occured while trying to ban players... \n" .. errormessage)

		return false
	end

	return true
end

function ModerationModule:TempbanPlayerAsync(player: Player | {number}, duration: string | number, displayreason: string, modnotice: string, ApplyToUniverse: boolean) : boolean
	if not (typeof(player) == "table") then
		player = {player.UserId}
	end

	if typeof(duration) == "string" then
		duration = ModerationModule:ConvertTimestamp(duration);
	end

	local BanConfig : BanConfigType = {
		UserIds = player,
		Duration = duration;
		DisplayReason = displayreason,
		PrivateReason = modnotice,
		ExcludeAltAccounts = false,
		ApplyToUniverse = ApplyToUniverse
	}

	local success, errormessage = pcall(function()
		return PlayerService:BanAsync(BanConfig);
	end)

	if not success then
		warn("An error occured while trying to ban players... \n" .. errormessage)

		return false
	end

	return true
end

function ModerationModule:UnbanPlayerAsync(player: number | {number}, ApplyToUniverse: boolean) : boolean
	if not (typeof(player) == "table") then
		player = {player};
	end

	local UnbanConfig  : UnbanConfigType = {
		UserIds = player,
		ApplyToUniverse = ApplyToUniverse
	}

	local success, errormessage = pcall(function()
		return PlayerService:UnbanAsync(UnbanConfig)
	end)

	if not success then
		warn("An error occured while tryingto unban player! \n" .. errormessage)

		return false
	end

	return true
end

function ModerationModule:PlayerModerationHistory(player: Player, amount: number) : boolean | {}
	local Banhistory : {};

	local success, errormessage = pcall(function()
		Banhistory = PlayerService:GetBanHistoryAsync(player.UserId)

		if Banhistory and amount then
			local SortedBanhistory = {}

			for i = 1, amount do
				SortedBanhistory[i] = Banhistory[i];
			end

			Banhistory = SortedBanhistory;
		end

		return Banhistory;
	end)

	if not success then
		warn("An error occured while trying to retrieve players moderation history. \n" .. errormessage);

		return false
	end

	return Banhistory
end

return ModerationModule