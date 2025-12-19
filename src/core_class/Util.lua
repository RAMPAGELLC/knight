--!strict

--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2025 Meta Games LLC, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 
 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.metatable.dev
]]

local Util = {}

function Util.DeepCopy(orig: any)
	local orig_type = type(orig)
	local copy

	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Util.DeepCopy(orig_key)] = Util.DeepCopy(orig_value)
		end
		setmetatable(copy, Util.DeepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

function Util.SyncTable(data: table, template: table)
	assert(typeof(data) == "table")
	assert(typeof(template) == "table")

	for k, v in pairs(template) do
		if type(v) == "table" then
			if not data[k] then
				data[k] = Util.DeepCopy(template[k])
			else
				data[k] = Util.SyncTable(data[k], template[k])
			end
		else
			if not data[k] then
				data[k] = template[k]
			end
		end
	end

	return data
end

return Util
