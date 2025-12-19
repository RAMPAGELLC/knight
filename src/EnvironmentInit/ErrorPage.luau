return function(fusion, state)
	local New, Children = fusion.New, fusion.Children;

	return New("Frame")({
		Name = "Frame",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
        Visible = state.enabled;

		[Children] = {
			New("TextLabel")({
				Name = "TextLabel",
				BackgroundColor3 = Color3.fromRGB(93, 34, 34),
				BackgroundTransparency = 0.15,
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				TextColor3 = Color3.new(1, 1, 1),
				TextStrokeTransparency = 0.2,
				TextWrapped = true,
				ZIndex = 1,
			}),

			New("ImageLabel")({
				Name = "ImageLabel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://11782559813",
				Position = UDim2.fromScale(0.5, 0.22),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(425, 425),
				ZIndex = 2,
			}),
		},
	})
end
