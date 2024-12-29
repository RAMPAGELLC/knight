local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local Knight = {} :: KNIGHT_TYPES.KnightClass

function Knight:Init()
	local Import = Knight.Internal.Core.Import
	local Object = Import("Knight/Server/Services/ImportTest")
	
	--warn("Imported service object:", Object)
	--warn("Local 'cron' library:", Knight.cron)
end

return Knight