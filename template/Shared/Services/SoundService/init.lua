local m = {}

local debris = game:GetService("Debris")

local soundWrapper = require(script.SoundWrapper)

function m:PlaySound(sound, part)
	if part then
		local new_sound = sound:Clone()
		new_sound.Parent = part
		
		new_sound:Play()
		
		local c
		c = new_sound.Ended:Connect(function()
			c:Disconnect()
			c = nil
			
			new_sound:Destroy()
			new_sound = nil
		end)
		
		return new_sound
	else
		sound:Play()
	end
end

function m:WrapSound(sound)
	return soundWrapper.new(sound)
end

return m
