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

local require = require(script.Parent.Parent.require)
local Sift = require("core/sift")

local RunService = game:GetService("RunService")
local LogHelper = {}

LogHelper.LEVEL = {
	["INFO"] = 1,
	["WARN"] = 2,
	["ERROR"] = 3,
	["FATAL"] = 4,
}

LogHelper.DEFAULT_LEVEL = LogHelper.LEVEL.WARN
LogHelper.LEVEL_NUMBER_MAP = Sift.Dictionary.flip(LogHelper.LEVEL)

function LogHelper:Log(logLevel: any, ...)
	local args = { ... }
	local level = typeof(logLevel) == "number" and logLevel or LogHelper.DEFAULT_LEVEL

	if typeof(logLevel) ~= "number" then
		table.insert(args, 1, logLevel)
	end

	local context = RunService:IsServer() and "Server" or "Client"
	local header = string.format("[Knight:%s:%s] ", context, LogHelper.LEVEL_NUMBER_MAP[level] or "UNKNOWN"):lower()

	if level == LogHelper.LEVEL.INFO and not RunService:IsStudio() then
		return
	end

	if level == LogHelper.LEVEL.INFO then
		print(header, unpack(args))
	elseif level == LogHelper.LEVEL.WARN then
		warn(header, unpack(args))
	elseif level == LogHelper.LEVEL.ERROR then
		task.spawn(error, ("%s%s"):format(header, table.concat(args, " ")), 0)
	elseif level == LogHelper.LEVEL.FATAL then
		task.spawn(error, ("%s%s\n---- Stack trace ----\n%s"):format(header, table.concat(args, " "), debug.traceback(2)), 0)
	else
		LogHelper:Log(LogHelper.LEVEL.FATAL, "Unknown log level:", level, unpack(args))
	end
end

return setmetatable(LogHelper, {
	__call = function(_, ...)
		return LogHelper:Log(...)
	end,
})
