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

local Chat = game:GetService("Chat")
local CollectionService = game:GetService("CollectionService")

local VISIBLE_HASTAGS = true
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

function Util.FilterText(from: Player, text: string, VISIBLE_HASTAGS_OVERRIDE: boolean | nil)
	assert(typeof(from) == "Instance" and from:IsA("Player"))
	assert(typeof(text) == "string")
	assert(VISIBLE_HASTAGS_OVERRIDE == nil or VISIBLE_HASTAGS_OVERRIDE ~= nil and typeof(VISIBLE_HASTAGS_OVERRIDE) == "boolean")

	if VISIBLE_HASTAGS_OVERRIDE == nil then
		VISIBLE_HASTAGS_OVERRIDE = VISIBLE_HASTAGS
	end

	local UIF = Chat:FilterStringForBroadcast(text, from)

	if string.find(UIF, "#") then
		return VISIBLE_HASTAGS and UIF or "[Content Deleted]"
	end

	return UIF
end

function Util.studsToMiles(studs: number)
	assert(typeof(studs) == "number")

	-- Conversion factor from studs to miles
	local conversionFactor = 0.00017391

	-- Convert studs to miles
	local miles = studs * conversionFactor

	return miles
end

function Util.GetTableLength(tbl: { [string | number]: any }): number
	assert(typeof(tbl) == "table")

	local length = 0

	for _ in pairs(tbl) do
		length += 1
	end

	return length
end

function Util.showCharacter(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"))

	local character = player.Character or player.CharacterAdded:Wait()

	for _, object in pairs(character:GetDescendants()) do
		if object == character.PrimaryPart or object.Name == "HumanoidRootPart" then
			continue
		end

		if not object:IsA("BasePart") and not object:IsA("Decal") and not object:IsA("Texture") then
			continue
		end

		object.Transparency = 0

		if object.Name == "Head" then
			local face = script:FindFirstChild("face")
			if face then
				face.Transparency = 0
				face.Parent = object
			end
		end

		if not object:IsA("BasePart") then
			continue
		end

		object.CanCollide = true
	end
end

function Util.hideCharacter(player: Player)
	assert(typeof(player) == "Instance" and player:IsA("Player"))

	local character = player.Character or player.CharacterAdded:Wait()

	for _, object in pairs(character:GetDescendants()) do
		if object == character.PrimaryPart or object.Name == "HumanoidRootPart" then
			continue
		end

		if not object:IsA("BasePart") and not object:IsA("Decal") and not object:IsA("Texture") then
			continue
		end

		object.Transparency = 1

		if string.lower(object.Name) == "face" then
			object.Parent = script
		end

		if not object:IsA("BasePart") then
			continue
		end

		object.CanCollide = false
	end
end

function Util.getNamedChildren(parent: Instance)
	assert(typeof(parent) == "Instance")

	local children = {}

	for _, child in parent:GetChildren() do
		children[child.Name] = child
	end

	return children
end

function Util.InstanceTagged(tagName: string, callback: (Instance: Instance) -> nil)
	assert(typeof(tagName) == "string")
	assert(typeof(callback) == "function")

	CollectionService:GetInstanceAddedSignal(tagName):Connect(function(taggedInstance)
		callback(taggedInstance)
	end)

	for _, taggedInstance in CollectionService:GetTagged(tagName) do
		callback(taggedInstance)
	end
end

--[[
	Converts roblox units of mass to real world mass in kilograms

	source: https://devforum.roblox.com/t/conversion-of-roblox-and-real-world-units/133327/4
]]
function Util.toKg(mass: number)
	assert(typeof(mass) == "number")

	return mass / 8
end

function Util.getAssemblyMass(assembly: Model)
	assert(typeof(assembly) == "Instance" and assembly:IsA("Model"))

	local sum = 0

	for _, v in assembly:GetDescendants() do
		if v:IsA("BasePart") then
			sum += v.AssemblyMass
		end
	end

	return sum
end

function Util.fmtInt(number: number)
	assert(typeof(number) == "number")

	local i, j, minus, int, fraction = tostring(number):find("([-]?)(%d+)([.]?%d*)")

	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")

	-- reverse the int-string back remove an optional comma and put the
	-- optional minus and fractional part back
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function Util.toKilometerPerSec(velocity: number)
	assert(typeof(velocity) == "number")

	return velocity * 1.09728
end

function Util.toMeterPerSec(velocity: number)
	assert(typeof(velocity) == "number")

	return Util.toKilometerPerSec(velocity) / 3.6
end

function Util.toMilesPerHour(velocity: number)
	assert(typeof(velocity) == "number")

	return (velocity * 3600) * 0.0001739839
end

function Util.GetPlayerFromShort(shortName: string)
	assert(typeof(shortName) == "string")

	shortName = string.lower(shortName)

	for _, Player in pairs(game.Players:GetPlayers()) do
		local playerName = string.lower(Player.Name)
		if string.match(playerName, "^" .. shortName) then
			return Player
		end
	end

	return nil
end

return Util
