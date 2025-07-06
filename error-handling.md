# Error Handling

## About

In knight error handling is handled by the framework with some basic logging. You can hook into this through the `OnError` event to log them externally to a API like [Sentry](https://sentry.io/welcome/).

#### We recommend using [sentry-roblox by devSparkle](https://devsparkle.me/sentry-roblox/) and integrating it with Knight.

## Examples

```etlua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local require = require(require(Packages:WaitForChild("knight")).import)
local errorHandler = require("core/class/ErrorHandler")

(errorHandler.OnError :: BindableEvent).Event:Connect(function(errorPayload: {
    runType: string;
    isShared: boolean;
    child: Instance;
    trace: string;
    message: string;
    timestamp: number;
})
    -- Your custom error handling here
end)
```
