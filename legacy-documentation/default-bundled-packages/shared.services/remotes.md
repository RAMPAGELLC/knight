---
description: Knight Remotes, an Roblox networking solution.
---

# Remotes

## Functions

API Version: 1.0.1\
Source: [https://github.com/RAMPAGELLC/knightremotes/tree/main](https://github.com/RAMPAGELLC/knightremotes/tree/main)

### Register

```lua
Remotes:Register(RemoteName: string, RemoteClass: string, Callback: any) -> void
```

### Unregister

```lua
Remotes:Unregister(string: Remote Name) -> void
```

### Connect

```lua
Remotes:Connect(RemoteName: string, callback: () -> void | nil | boolean) -> void
```

### Fire

```lua
Remotes:Fire(RemoteName: string, ...) -> void
```

### FireAll

```lua
Remotes:FireAll(RemoteName: string, ...) -> void
```

### FireAllNearby

```lua
Remotes:FireAllNearby(RemoteName: string, position: Vector3, maxDistance: number | boolean, ...) -> void
```
