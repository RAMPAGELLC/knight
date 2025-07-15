-- (©) Copyright 2025 Meta Games LLC, all rights reserved.
-- Written by vq9o

-- License: MIT
-- GitHub: https://github.com/RAMPAGELLC/RBLXRolesAPI

local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not ReplicatedStorage:FindFirstChild("Constants") then
	warn("Failed to load library 'roles', package requires missing external config.")
	return {}
end

if not ReplicatedStorage:FindFirstChild("Constants"):FindFirstChild("Config") then
	warn("Failed to load library 'roles', package requires missing external config.")
	return {}
end

local Config = require(ReplicatedStorage.Constants.Config)

export type RoleName = string
export type Role = {
	Name: RoleName,
	Everyone: boolean | nil,
	Players: { string | number },
	Teams: { Team },
	Groups: { { number } },
	Roles: { RoleName },
	DiscordRoles: { string },
}

local Service = {}

function Service:GetRoleConfigByName(RoleName: RoleName): Role | nil
	for _, v: Role in pairs(Config.Roles) do
		if string.upper(v.Name) == string.upper(RoleName) then
			return v
		end
	end

	return nil
end

function Service:HasDiscordRole(Player: Player, RoleId: string | number): boolean
	return table.find(
		_G.PlayerData ~= nil
				and _G.PlayerData[Player.Name] ~= nil
				and _G.PlayerData[Player.Name].DiscordRoles ~= nil
				and _G.PlayerData[Player.Name].DiscordRoles
			or {},
		tostring(RoleId)
	)
end

function Service:HasRole(Player: Player, RoleName: RoleName): boolean
	local Role: Role | nil = Service:GetRoleConfigByName(RoleName)

	if Role == nil then
		warn(("%s role Does not exist!"):format(RoleName), debug.traceback())
		return false
	end

	if Role.Everyone then
		return true
	end

	local hasPerm = {}
	local requireAll: boolean = Role.RequireAll or false

	if Role.Teams == {} then
		hasPerm["Teams"] = true
	end

	for _, team: Team in pairs(Role.Teams) do
		if Player.Team == team then
			if requireAll then
				hasPerm["Teams"] = true
				break
			else
				return true
			end
		end
	end

	if Role.DiscordRoles == {} then
		hasPerm["DiscordRoles"] = true
	end

	for _, roleId: string in pairs(Role.DiscordRoles) do
		if Service:HasDiscordRole(Player, roleId) then
			if requireAll then
				hasPerm["DiscordRoles"] = true
				break
			else
				return true
			end
		end
	end

	if Role.Players == {} then
		hasPerm["Players"] = true
	end

	for _, value: number | string in pairs(Role.Players) do
		if typeof(value) == "number" and Player.UserId == value then
			if requireAll then
				hasPerm["Players"] = true
				break
			else
				return true
			end
		end

		if typeof(value) == "string" and Player.Name == value then
			if requireAll then
				hasPerm["Players"] = true
				break
			else
				return true
			end
		end
	end

	if Role.Groups == {} then
		hasPerm["Groups"] = true
	end

	for _, group: { number } in pairs(Role.Groups) do
		if Player:GetRankInGroup(group[1]) >= (group[2] or 1) then
			if requireAll then
				hasPerm["Groups"] = true
				break
			else
				return true
			end
		end
	end

	if Role.Roles == {} then
		hasPerm["Roles"] = true
	end

	for _, role: RoleName in pairs(Role.Roles) do
		if Service:HasRole(Player, role) then
			if requireAll then
				hasPerm["Roles"] = true
				break
			else
				return true
			end
		end
	end

	if requireAll then
		local passCount: number = 0

		for _, bool: boolean in pairs(hasPerm) do
			if bool then
				passCount += 1
			end
		end

		return passCount >= #hasPerm
	end

	return false
end

function Service:HasAllRoles(Player: Player, Roles: { RoleName }): boolean
	for _, role: RoleName in pairs(Roles) do
		if not Service:HasRole(Player, role) then
			return false
		end
	end

	return true
end

function Service:HasAnyRole(Player: Player, Roles: { RoleName }): boolean
	for _, role: RoleName in pairs(Roles) do
		if Service:HasRole(Player, role) then
			return true
		end
	end

	return false
end

return Service
