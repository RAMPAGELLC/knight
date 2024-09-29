local ClientPointsService = {}

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