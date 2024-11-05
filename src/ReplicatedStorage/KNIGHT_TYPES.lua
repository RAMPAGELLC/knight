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
 Documentation: https://knight.metatable.dev
]]

export type int = number
export type integer = int
export type void = nil
export type Callable = () -> void
export type KnightService = table?

export type KnightInit = {
	InitKnight: (Services: table | nil, KnightCore: KnightCore) -> Knight,
}

export type KnightCore = {
	PrintVersion: Callable,
	Log: (Log: string, any...) -> void,
	Import: (Path: string) -> void,
	GetShared: () -> KnightInit,
	Init: () -> (Knight, Knight),
	GetService: (ServiceName: string, IsShared: boolean | nil) -> KnightService,
}

export type Knight = {
	Inited: boolean,
	Player: Player | boolean,
	Shared: { any },
	Enum: { any },
	Types: { any },
	Shared: { any } | boolean,
	Database: { any }?,
	Objects: { any }?,
	Services: { any }?,
	Internal: {
		IsServer: boolean,
		Version: string,
		Core: KnightCore,
		runType: string,
	},
	KnightCache: { any },
}

export type KnightEvent = {
	Name: string,
	Fire: Callable,
}

return {}
