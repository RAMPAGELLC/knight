## ✨ Changes Overview
```diff
+ Source code has been reorganized and modularized for better maintainability.
+ Major internal updates to Knight Core with new deprecations.
+ Client framework now **yield** until the server framework has fully loaded (Loaded, inited, and started.)
+ General optimization improvements across core systems.
- Deprecated and fully removed `REPORT_FUNC`.
- `Knight.util` has been deprecated and will be removed in a future update.
```

---

# 📦 Accessing the New `Knight.util`
To access the new `Knight.util` module:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local require = require(require(Packages:WaitForChild("knight")).import)
local Util = require("core/class/Util")
```

---

# 🚫 `REPORT_FUNC` Removal - Workaround
Since `REPORT_FUNC` has been fully removed, you can now connect to the new custom error signal:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local require = require(require(Packages:WaitForChild("knight")).import)
local errorHandler = require("core/class/ErrorHandler")

(errorHandler.OnError :: BindableEvent).Event:Connect(function(scriptName: string, runType: string, errorNTrace: string)
    -- Your custom error handling here
end)
```

---

# ⚡ `KnightCore.Core` Deprecation
When initializing Knight, **you must now use**:

```lua
require(game:GetService("ReplicatedStorage").Packages.knight):Init()
```

Instead of the old way:

```lua
require(game:GetService("ReplicatedStorage").Packages.knight).Core.Init()
```

---

# 🛠️ New Service Setup Example
## ⚠️ Important Change for `require`
You must now update your custom `require` usage like this:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

-- Old (❌ Deprecated):
local require = require(Packages:WaitForChild("knight")).require

-- New (✅ Current):
local require = require(require(Packages:WaitForChild("knight")).import)

```

---

## Example Service
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))
local require = require(require(Packages:WaitForChild("knight")).import)

local ClientPointsService = {} :: KNIGHT_TYPES.KnightClass

function ClientPointsService:Start()
    warn("ClientPointsService has started!")
    task.wait(1)
    warn("Got local points:", ClientPointsService.Server.PointService:GetLocalPoints())
    warn("Import test - GetService()", self:GetService("TestClientService"):foo())
    warn("Require test", require("TestClientService"):bar())
end

function ClientPointsService:Init()
    warn("ClientPointsService has inited!")
    warn("Starting error logger test 3000")
    
    local b = false
    assert(b == true, "expected b to be true")

    task.delay(0.25, function()
        warn("Starting error logger test 2")
        local b = false
        assert(b == true, "expected b to be true")
    end)
    
    warn(self)
end

return ClientPointsService

--------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KNIGHT_TYPES = require(ReplicatedStorage:WaitForChild("KNIGHT_TYPES"))

local TestClientService = {} :: KNIGHT_TYPES.KnightClass

function TestClientService:foo()
	warn("TestClientService has imported!")

    return self;
end

function TestClientService:bar()
    return "Hi mom from custom-require!";
end

return TestClientService
```