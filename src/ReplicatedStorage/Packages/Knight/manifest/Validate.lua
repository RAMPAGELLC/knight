--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2024 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT

 Repository: https://github.com/RAMPAGELLC/knight
 Documentation: https://knight.vq9o.com
]]

-- TODO: More extensive validation.

local required_props = {
	library_name = { "string" },
	runtime = { "string" },
	src = { "ModuleScript" },
}

return function (manifest: table?): boolean?
    assert(typeof(manifest) == "table", "[Knight:Internal]: Failed to validate 'manifest.lua', bad input expected a 'table'.");

    for i,v in pairs(required_props) do
        assert(manifest[i] ~= nil, "[Knight:Internal]: Failed to validate 'manifest.lua', Missing required manifest property.")
        assert(table.find(manifest[i], typeof(v)) "[Knight:Internal]: Failed to validate 'manifest.lua', Exepected valid input type.")
    end

    return true
end