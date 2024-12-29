local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local PointsService = {} :: KNIGHT_TYPES.KnightClass
PointsService.Client = {}

function PointsService.Client:GetLocalPoints(Player: Player)
    local points = 100
    return points
end

return PointsService