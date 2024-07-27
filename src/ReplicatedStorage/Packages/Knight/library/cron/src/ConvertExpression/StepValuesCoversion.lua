local stepValuePattern = "(.+)/(.+)$"

return function(expressions: { string })
	for i = 1, #expressions do
		local valuesString, baseDivider = expressions[i]:gmatch(stepValuePattern)()

		if valuesString and baseDivider then
			local divider = tonumber(baseDivider)
			if divider == nil then
				error(`[luau-cron] "{baseDivider}" is not a valid step divider`)
			end

			local values = valuesString:split(",")
			local stepValues = {}

			for j = 1, #values do
				local value = tonumber(values[j])

				if value % divider == 0 then
					table.insert(stepValues, value)
				end
			end

			expressions[i] = table.concat(stepValues, ",")
		end
	end

	return expressions
end