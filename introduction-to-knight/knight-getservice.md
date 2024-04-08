# Knight:GetService()

## About

In 0.0.7 we introduced GetService, a alternative to Knight Import. Utilize Import or GetService is a method to avoid high-memory usage from the cyclic indexing, which causes high memory usage depending on size.

## Usage

```lua
local Knight = {}

function Knight.Start()
	local Foo = Knight:GetService("Foo")
	Foo.bar();
end

return Knight;
```
