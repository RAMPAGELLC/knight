local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local require = require(require(Packages:WaitForChild("knight")).import)

local ClientPointsService = {}

function ClientPointsService:Start()
	warn("Got local points:", self.Server.PointService:GetLocalPoints())
	warn("Import test - GetService()", self:GetService("TestClientService"):foo())
	warn("Require test", require("TestClientService"):bar())
end

function ClientPointsService:Init()
	warn("ClientPointsService has inited!")
	--[[ local b = false
    assert(b == true, "expected b to be true")

   task.delay(.25, function()
		warn("Starting error logger test 2")
		local b = false
		assert(b == true, "expected b to be true")
    end)]]

	warn("ClientPointsService: ", self)
end

return ClientPointsService
