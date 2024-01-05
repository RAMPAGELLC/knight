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

## KPM (Knight Package Manager)

In version 0.0.5 we added KPM for adding third-party knight modules. You can load a KPM module into your script with Import.

```lua
local Import = Knight.Core.Import
local Class = Import("KPM/foo@1.0") -- Specific version, or you can do @latest.
Class.bar()
```

To import / require a KPM package on game runtime you must use the RAMPAGE CLI and install the package first.

Knight CLI Commands for RAMPAGE CLI to interface with KPM:

* kpm install package@version (Install a package)
* kpm uninstall package@version (Uninstall a package)
* kpm ping (Check if KPM server is online)
* kpm knight -v (Check knight version)

To publish a KPM package message vq9o (@metatable 295744013406044162) on the RAMPAGE Interactive Discord, KPM is manual by a Administrator atm.
