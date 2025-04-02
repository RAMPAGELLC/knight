local months = {
	"january",
	"february",
	"march",
	"april",
	"may",
	"june",
	"july",
	"august",
	"september",
	"october",
	"november",
	"december",
}
local shortMonths = {
	"jan",
	"feb",
	"mar",
	"apr",
	"may",
	"jun",
	"jul",
	"aug",
	"sep",
	"oct",
	"nov",
	"dec",
}

local function convertMonthName(expression: string, items: { string })
	for index, item in ipairs(items) do
		expression = expression:gsub(item, index)
	end

	return expression
end

return function(monthExpression: string)
	monthExpression = convertMonthName(monthExpression, months)
	monthExpression = convertMonthName(monthExpression, shortMonths)

	return monthExpression
end