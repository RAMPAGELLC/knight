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

local RunService = game:GetService("RunService")

local require = require(script.Parent.Parent.require)
local Log = require("core/class/Log")

local IsClient = RunService:IsClient()
local runType = IsClient and "Client" or "Server"

local ErrorHandler = {}
ErrorHandler.OnError = Instance.new("BindableEvent")

function ErrorHandler:Handle(Knight, child, err)
	local trace = debug.traceback(err, 2)
	local message =
		string.format("%s An error occurred in %s.lua:\n---- Stack trace ----\n%s", (if Knight.IsShared then "[shared]" else ""), child.Name, trace)

	Log(Log.LEVEL.ERROR, message)
	ErrorHandler.OnError:Fire(child.Name, runType .. (Knight.IsShared and " (Shared)" or ""), trace)
end

return setmetatable(ErrorHandler, {
	__call = function(_, ...)
		return ErrorHandler:Handle(...)
	end,
})
