---
description: Knight Remotes, a roblox networking solution.
---

# Remotes

## Register

```lua
Knight.Shared.Services.Remotes:Register(string: Remote Name, string: RemoteClass (RemoteEvent, RemoteFunction), function: callback)
-- returns connection from shared services.
```

## Unregister

```lua
Knight.Shared.Services.Remotes:Unregister(string: Remote Name)
-- returns boolean on success or not
```

## Connect

```lua
Knight.Shared.Services.Remotes:Connect(string: RemoteName, function: callback)
```

## Fire

```lua
Knight.Shared.Services.Remotes:Fire(string: RemoteName, ...)
```

## FireAll

```lua
Knight.Shared.Services.Remotes:FireAll(string: RemoteName, ...)
```
