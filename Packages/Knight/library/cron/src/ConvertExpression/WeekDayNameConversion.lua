local weekDays = {
	"sunday",
	"monday",
	"tuesday",
	"wednesday",
	"thursday",
	"friday",
	"saturday",
}
local shortWeekDays = {
	"sun",
	"mon",
	"tue",
	"wed",
	"thu",
	"fri",
	"sat",
}

local function convertWeekDayName(expression: string, items: { string })
	for index, item in ipairs(items) do
		expression = expression:gsub(item, index)
	end

	return expression
end

return function(weekDayExpression: string)
	weekDayExpression = weekDayExpression:gsub("7", "0")
	weekDayExpression = convertWeekDayName(weekDayExpression, weekDays)
	weekDayExpression = convertWeekDayName(weekDayExpression, shortWeekDays)

	return weekDayExpression
end