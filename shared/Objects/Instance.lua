local Knight = {}

function Knight.Init()
	getfenv(3).Instance = {
		new = Knight.new
	}
end

function Knight.new(InstanceName)
	local InstanceObject = typeof(InstanceName) == "string" and Instance.new(InstanceName) or InstanceName
	local self

	self = setmetatable({}, {
		__index = function(t, k)
			return function(v)
				local s,e = pcall(function()
					_ = InstanceObject[k]
				end)
				
				if s then
					InstanceObject[k] = v
				end
				
				return self
			end
		end,
	})

	function self.Build()
		return InstanceObject
	end

	return self
end

return Knight