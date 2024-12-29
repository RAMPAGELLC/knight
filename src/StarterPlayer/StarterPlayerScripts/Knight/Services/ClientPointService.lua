local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local ClientPointsService = {} :: KNIGHT_TYPES.KnightClass

function ClientPointsService:Start()
    warn("ClientPointsService has started!")
    task.wait(1)
    warn("Got local points:", ClientPointsService.Server.PointService:GetLocalPoints())
    warn("Got local points 2:", self.Server.PointService:GetLocalPoints())
end

function ClientPointsService:Init()
    warn("ClientPointsService has inited!")
end

return ClientPointsService