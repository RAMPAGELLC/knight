local debris = game:GetService("Debris")

local wrapper = {}
wrapper.__index = wrapper

function wrapper:Play(part)
	if part then
		local new_sound = self.Sound:Clone()
		new_sound.Parent = part
		
		new_sound:Play()
		
		local c
		c = new_sound.Ended:Connect(function()
			c:Disconnect()
			c = nil
			
			new_sound:Destroy()
			new_sound = nil
		end)
		
		table.insert(self.__clones, new_sound)
		
		return new_sound
	else
		self.Sound:Play()
	end
end

function wrapper:Stop()
	self.Sound:Stop()
	
	for i, clone in pairs(self.__clones) do
		clone:Stop()
	end
end

function wrapper:Destroy()
	self:Stop()
	
	self = nil
	return self
end

function wrapper.new(sound)
	local new_wrapper = setmetatable({
		Sound = sound,
		
		__clones = {}
	}, wrapper)
	
	return new_wrapper
end

return wrapper
