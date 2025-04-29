--[[
 _   __      _       _     _   
| | / /     (_)     | |   | |  
| |/ / _ __  _  __ _| |__ | |_ 
|    \| '_ \| |/ _` | '_ \| __|
| |\  \ | | | | (_| | | | | |_ 
\_| \_/_| |_|_|\__, |_| |_|\__|
                __/ |          
               |___/    
 
 (©) Copyright 2025 RAMPAGE Interactive, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(script.Parent:WaitForChild("require"))

local Util = require("core/util")
local DefaultConfig = require("core/default_config")
local KNIGHT_CONFIG = require("core/config")

return Util.SyncTable(KNIGHT_CONFIG, DefaultConfig);