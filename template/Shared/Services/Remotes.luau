--[[
 (©) Copyright 2025 Meta Games LLC, all rights reserved.
 Written by Metatable (@vq9o), Epicness and contributors.
 License: MIT
 Repository: https://github.com/Metatable-Games/KnightRemotes
]]

local class = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("knightremotes")
if not class or not class:IsA("ModuleScript") then
    class = nil
    warn("[Knight]: Knight Networking is unavailable as it is not installed! Please install it from https://github.com/Metatable-Games/KnightRemotes.")
end

class = if class then require(class) else {}
class.Standalone = true
class:init();

return class