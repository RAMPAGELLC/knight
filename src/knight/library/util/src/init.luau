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
]]

local log = require("core/class/Log")
local require = require(script.Parent.Parent.Parent:WaitForChild("require"))
local util = require("core/class/Util")

return setmetatable(table.clone(util), {
	__index = function(_, key)
		local value = util[key]

		if typeof(value) == "function" then
			return function(...)
				log(
					log.LEVEL.WARN,
					"'Knight.util' has been deprecated, it has been moved to 'Knight.Core.Util'. It's recommended to import it via require(\"core/Util\")."
				)
				return value(...)
			end
		end

		return value
	end,
})
