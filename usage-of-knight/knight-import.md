# Knight Import

In version 0.0.4 we introduced a new way of calling other services.

## Example

```lua
local Import = Knight.Internal.Core.Import
local Class = Import("Knight/Server/Services/Foo")
Class.bar()

-- Even supports instances!
local Part = Import("Roblox/ReplicatedFirst/Part")
print(Part, Part.Transparency)
```

## Valid Paths

* Knight/Server/ -> Knight server
* Knight/Shared/ -> Knight Shared
* Knight/Client/ -> Knight Client
* Knight/Core/ -> Knight Core
* Roblox/ -> Roblox (game)
* Knight/Env/ -> Current Knight Runtime Enviornment (Basically Knight/Client / Knight/Server wrapper based on current RT)

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

* kpm -install package@version (Install a package)
* kpm -uninstall package@version (Uninstall a package)
* kpm -ping (Check if KPM server is online)
* kpm -help (List commands)
* kpm -v (KPM CLI version)

To publish a KPM package make a pull request and push to: [https://github.com/RAMPAGELLC/KnightPackageManager/tree/main](https://github.com/RAMPAGELLC/KnightPackageManager/tree/main)
