local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local Knight = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Knight Corescript"
	}
} :: KNIGHT_TYPES.KnightClass

function Knight.Init()
	Knight.Knight:PrintVersion()
end

function Knight.Start()
	if Knight.Gui ~= nil and Knight.Player.PlayerGui:FindFirstChild("KnightFramework") ~= nil then
		return
	end
	
	Knight.Gui = script.KnightFramework:Clone()
	Knight.Gui.Parent = Knight.Player.PlayerGui
end

return Knight