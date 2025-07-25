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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedKnight = ReplicatedStorage:WaitForChild("Knight")

export type int = number
export type integer = int
export type void = nil
export type Callable = () -> void

export type KnightObject = KnightClass | Instance

export type KnightInit = {
	InitKnight: (Services: any | nil, KnightCore: KnightCore) -> KnightClass,
}

export type KnightCore = {
	Log: (Log: "print" | "warn" | "error", ...any) -> void,
	GetShared: () -> KnightInit,
	Init: () -> (KnightClass, KnightClass),
	GetService: (ServiceName: string, IsShared: boolean | nil) -> KnightObject,
	GetStorage: (isShared: boolean | nil) -> KnightObject,
}

export type KnightRuntimeBase = {
	Inited: boolean,
	initStart: number,
	Player: Player | boolean,

	KnightCache: {
		UpdateEvent: BindableEvent,
	},
	Enum: { [string]: string },
	Types: { any },

	Internal: {
		IsServer: boolean,
		Version: string,
		Core: KnightCore,
		runType: string,
	},

	Objects: { KnightObject }?,
	Services: { KnightObject }?,
	Controllers: { KnightObject }?,
}

export type KnightShared = KnightRuntimeBase & {
	Database: { KnightObject }?,
}

export type KnightClass = KnightRuntimeBase & {
	Priority: number?,
	moduleStart: number,
	MemoryKBStart: number,
	CanInit: boolean,
	CanUpdate: boolean,
	CanStart: boolean,
	Standalone: boolean,

	Shared: KnightShared,
	Remotes: typeof(require(SharedKnight:WaitForChild("Services"):WaitForChild("Remotes"))),

	GetMemoryUsageMB: () -> number,
	GetMemoryUsageKB: () -> number,

	Unload: () -> void,

	Server: {
		[string]: (...any) -> any,
	},

	Client: {
		[string]: (...any) -> any,
	},

	src: ModuleScript?,

	ServiceName: string?,
	ServiceData: {
		Author: string?,
		Description: string?,
	}?,

	Init: Callable?,
	Start: Callable?,
	Update: Callable?,
}

return {}
