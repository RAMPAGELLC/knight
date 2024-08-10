---
description: Knight Package functions
---

# Introduction to Knight

## @Knight:PrintVersion()

Prints current Knight version

## @Knight.Core.Log(Type, messages...)

## @Knight.Core.GetShared()

## @Knight.Core:GetStorage(IsShared; optional boolean, default: false)

## @Knight.Core:Init()



```lua
-- Required to init Knight on server & client.

local KnightInternal, Knight = require(game:GetService("ReplicatedStorage").Packages.Knight).Core.Init()
```
