# Knight Import

In version 0.0.4 we introduced a new way of calling other services.

## Example

```lua
local Import = Knight.Core.Import
local Class = Import("Knight/Server/Services/Foo")
Class.bar()
```

## Valid Paths

* Knight/Server/ -> Knight server
* Knight/Shared/ -> Knight Shared
* Knight/Client/ -> Knight Client
* Knight/Core/ -> Knight Core

## Errors

Ensure you have proper paths otherwise erorrs will throw.
