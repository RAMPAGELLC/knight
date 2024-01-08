local Knight = {}

function Knight:Init()
	local Import = Knight.Internal.Core.Import
	local Object = Import("Knight/Server/Services/ImportTest")
	print(Object)
end

return Knight
