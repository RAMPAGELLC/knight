local function pack(folder, dont_get_values)
	if not folder then return end
	
	local tab = {}
	
	for i, child in pairs(folder:GetChildren()) do
		
		if child:IsA("Folder") then
			tab[child.Name] = pack(child, dont_get_values)
		else
			if dont_get_values then
				tab[child.Name] = child
			else
				if child:IsA("ValueBase") then
					tab[child.Name] = child.Value
				elseif child:IsA("ModuleScript") then
					tab[child.Name] = require(child)
				else
					tab[child.Name] = child
				end
			end
		end
	end
	
	return tab
end

return pack