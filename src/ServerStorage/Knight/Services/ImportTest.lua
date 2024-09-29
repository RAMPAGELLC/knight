local Knight = {}

function Knight:Init()
	local Import = Knight.Internal.Core.Import
	local Object = Import("Knight/Server/Services/ImportTest")
	
	warn("Imported service object:", Object)
	warn("Local 'cron' library:", Knight.cron)
end

return Knight