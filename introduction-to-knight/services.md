---
description: >-
  Services are module scripts that serve a specific purpose. For example a
  experience may have a service for GameUI, Points, etc.
---

# Services

### Creating a service <a href="#creating-a-service" id="creating-a-service"></a>

You can create a service by creating a new ModuleScript under one of Knights Services folders. Learn how to find knight service folders [Folders explanation](https://app.gitbook.com/s/ZVYkqtpa3etiCJsYeGLR/\~/changes/YBDQiMUocThlJ09JRJ9Z/knight/folders-explanation).

### Template <a href="#template" id="template"></a>

Each service is structured with this template.

```lua
local Knight = {
	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Example Service example"
	},
	CanStart = true,
	CanUpdate = true,
}

function Knight.Init()
	warn("Example Service inited!")
end

function Knight.Start()
	warn("Example Service Started!")
end

function Knight.Update(DeltaFrame)
	warn("Example Service called for new frame!")
end

return Knight
```

### Default Functions <a href="#default-functions" id="default-functions"></a>

```lua
function Knight.Init() -- optional. Called on init
end
```

```lua
function Knight.Start() -- optional. Called on start
end
```

```lua
function Knight.Update(deltaTime) -- optional. Called on every frame.
end
```

### Init <a href="#init" id="init"></a>

<pre class="language-lua"><code class="lang-lua"><strong>local Knight = {
</strong>	ServiceName = script.Name,
	ServiceData = {
		Author = "vq9o",
		Description = "Example Service example"
	}
}

function Knight.Init()
	-- Client services only.
	print(Knight.Player.Name) -- Prints LocalPlayer name
	
	-- All services can access this.
	Knight.Shared -- indexs shared, you can access everything in it.
	Knight. -- indexs your current runtype (client or server)
	Knight.Knight -- returns knight internal functions
	
	-- Example you can call another function bar from service foo without need of using
	-- Roblox's require().
	Knight.Services.foo.bar()
end

return Knight
</code></pre>

## Config

Within Knight you have abilities to define Config for additional modification to a service.

CanStart & CanUpdate variable allow execution of the .Update() and .Start(). Useful if your using a third-party module and you need to disable Knight from calling its default start function like CameraShaker.

Config is not required and will default to true.

## Priority Startup

Folders named as "Database" will have first priority to init, then folders named "Priority" will init. Useful to load core game backend first.
