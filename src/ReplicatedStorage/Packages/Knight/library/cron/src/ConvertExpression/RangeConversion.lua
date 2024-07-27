local rangePattern = "((%d+)-(%d+))"

local function convertRange(expression: string)
	repeat
		local match, from, to = expression:gmatch(rangePattern)()

		if not match then
			break
		end

		local numbers = {}
		local last = tonumber(to)
		local first = tonumber(from)

		if first > last then
			last = tonumber(from)
			first = tonumber(to)
		end

		for i = first, last do
			table.insert(numbers, i)
		end

		expression = expression:gsub(match:gsub("%-", "%%-"), table.concat(numbers, ","), 1)

	until not expression:gmatch(rangePattern)()

	return expression
end

return function(expressions: { string })
	for i = 1, #expressions do
		expressions[i] = convertRange(expressions[i])
	end

	return expressions
end