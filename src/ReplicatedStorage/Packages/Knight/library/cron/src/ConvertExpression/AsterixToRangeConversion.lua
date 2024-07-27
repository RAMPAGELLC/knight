local function convertAsterix(expression: string, replacement: string)
	return expression:gsub("%*", replacement, 1)
end

return function(expressions: { string })
	expressions[1] = convertAsterix(expressions[1], "0-59")
	expressions[2] = convertAsterix(expressions[2], "0-59")
	expressions[3] = convertAsterix(expressions[3], "0-23")
	expressions[4] = convertAsterix(expressions[4], "1-31")
	expressions[5] = convertAsterix(expressions[5], "1-12")
	expressions[6] = convertAsterix(expressions[6], "0-6")

	return expressions
end