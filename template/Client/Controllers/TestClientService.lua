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