-- Copyright (c) 2025 Meta Games, LLC. All rights reserved.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local SelfTest = {} :: KNIGHT_TYPES.KnightClass

function SelfTest:Start()
    warn(self)
end

return SelfTest