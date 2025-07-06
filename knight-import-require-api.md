# Knight Import/require API

## About

Knight has a custom require/import implementaiton in v1.0.0.

## Aliases

Aliases are paths you can define to instances such as `@` points to `ReplicatedStorage.Packages`.

### Default Aliases

* core
  * Knight core
* @
  * ReplicatedStorage.Packages
* @s
  * ServerStorage.ServerPackages for server, and ReplicatedStorage.Packages for client.
* packages
  * same as @
* shared&#x20;
  * Knight Shared
* objects
  * Knight Objects of Runtime Context

## Examples

```lua
local require = require(path.to.src)

local module = require("shared/module")
local somePackage = require("package/module")
local somePackage2 = require("@/module")
local external = require(ReplicatedStorage.SomeModule)
```

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local GuiController = {} :: KNIGHT_TYPES.KnightClass

function GuiController:init()
   self.ui = require(script.Components.Main)(self)
end

function GuiController:start()
   return self.ui
end

---------- MainComponent ----------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local require = require(require(Packages:WaitForChild("knight")).import)
local fusion = require("core/fusion")

return function(controller)
	local New, Children = fusion.New, fusion.Children;

	return New("Frame")({
		Name = "Frame",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
        Visible = state.enabled;

		[Children] = {
			New("TextLabel")({
				Name = "TextLabel",
				BackgroundColor3 = Color3.fromRGB(93, 34, 34),
				BackgroundTransparency = 0.15,
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				TextColor3 = Color3.new(1, 1, 1),
				TextStrokeTransparency = 0.2,
				TextWrapped = true,
				ZIndex = 1,
			}),

			New("ImageLabel")({
				Name = "ImageLabel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://11782559813",
				Position = UDim2.fromScale(0.5, 0.22),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(425, 425),
				ZIndex = 2,
			}),
		},
	})
end

```
