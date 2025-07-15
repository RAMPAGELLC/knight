-- (©) Copyright 2025 Meta Games LLC, all rights reserved.
-- Written by vq9o

-- License: MIT
-- GitHub: https://github.com/RAMPAGELLC/RBLXPermissionParser

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local RolesAPI = require(script.Parent.Parent:WaitForChild("roles"):WaitForChild("src"))

local Parser = {}

export type PermissionTypeString = string
export type ParsedPermissions = { string }

local function split(str, delimiter)
	local result = {}

	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end

	return result
end

local function parsePermissions(permissions)
	local parsedPermissions = {}

	for _, permission in ipairs(permissions) do
		table.insert(parsedPermissions, split(permission, ":"))
	end

	return parsedPermissions
end

function Parser:Parse(Player: Player, Permissions: { PermissionTypeString }, RequireAll: boolean | nil): boolean
	if RequireAll == nil then
		RequireAll = false
	end

	local PermissionsPassed: number = 0
	local ParsedPermissions: ParsedPermissions = parsePermissions(Permissions)

	for _, perm in ipairs(ParsedPermissions) do
		if PermissionsPassed > 0 and not RequireAll then
			break
		end

		if perm[1] == "Role" and RolesAPI:HasRole(Player, perm[2]) then
			PermissionsPassed += 1
		end

		if perm[1] == "Group" and Player:GetRankInGroup(tonumber(perm[2])) >= (perm[3] ~= nil and tonumber(perm[3]) or 1) then
			PermissionsPassed += 1
		end

		if perm[1] == "Username" and Player.Name == tostring(perm[2]) then
			PermissionsPassed += 1
		end

		if perm[1] == "UserId" and Player.UserId == tonumber(perm[2]) then
			PermissionsPassed += 1
		end

		if perm[1] == "Team" and Player.Team ~= nil and Player.Team.Name == perm[2] then
			PermissionsPassed += 1
		end
	end

	return RequireAll and (PermissionsPassed >= ParsedPermissions) or PermissionsPassed >= 1
end

return function(...): boolean
	if RunService:IsServer() then
		return Parser:Parse(...)
	end

	return Parser:Parse(Players.LocalPlayer, ...)
end
