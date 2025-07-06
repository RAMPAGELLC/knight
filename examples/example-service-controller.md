# Example Service/Controller

```etlua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))
local require = require(require(Packages:WaitForChild("knight")).import)

local ClientPointsService = {} :: KNIGHT_TYPES.KnightClass

function ClientPointsService:Start()
    warn("ClientPointsService has started!")
    task.wait(1)
    warn("Got local points:", ClientPointsService.Server.PointService:GetLocalPoints())
    warn("Import test - GetService()", self:GetService("TestClientService"):foo())
    warn("Require test", require("TestClientService"):bar())
end

function ClientPointsService:Init()
    warn("ClientPointsService has inited!")
    warn("Starting error logger test 3000")
    
    local b = false
    assert(b == true, "expected b to be true")

    task.delay(0.25, function()
        warn("Starting error logger test 2")
        local b = false
        assert(b == true, "expected b to be true")
    end)
    
    warn(self)
end

return ClientPointsService

--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local TestClientService = {} :: KNIGHT_TYPES.KnightClass

function TestClientService:foo()
	warn("TestClientService has imported!")

    return self;
end

function TestClientService:bar()
    return "Hi mom from custom-require!";
end

return TestClientService
```
