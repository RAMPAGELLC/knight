local Knight = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Knight Corescript"
	}
}

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