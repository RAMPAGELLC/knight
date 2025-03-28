local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local ClientPointsService = {} :: KNIGHT_TYPES.KnightClass

function ClientPointsService:Start()
	warn("ClientPointsService has started!")
	task.wait(1)
	warn("Got local points:", ClientPointsService.Server.PointService:GetLocalPoints())
end

function ClientPointsService:Init()
	warn("ClientPointsService has inited!")
    warn("Starting error logger test 3000")
    local b = false
    assert(b == true, "expected b to be true")

    task.delay(.25, function()
		warn("Starting error logger test 2")
		local b = false
		assert(b == true, "expected b to be true")
    end)
end

return ClientPointsService