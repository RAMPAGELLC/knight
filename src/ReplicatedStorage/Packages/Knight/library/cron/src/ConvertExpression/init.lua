local convertMonthNames = require(script.MonthNameConversion)
local convertWeekDayNames = require(script.WeekDayNameConversion)
local convertAsterixesToRanges = require(script.AsterixToRangeConversion)
local convertRanges = require(script.RangeConversion)
local convertSteps = require(script.StepValuesCoversion)

local function cleanSpaces(str: string)
	return str:gsub("%s+", " ")
end

local function appendSecondExpression(expressions: { string })
	if #expressions == 5 then
		local clonedExpressions = table.clone(expressions)

		table.insert(clonedExpressions, 1, "0")

		return clonedExpressions
	end

	return expressions
end

return function(expression: string)
	local expressions = cleanSpaces(expression):lower():split(" ")
	expressions = appendSecondExpression(expressions)
	expressions[5] = convertMonthNames(expressions[5])
	expressions[6] = convertWeekDayNames(expressions[6])
	expressions = convertAsterixesToRanges(expressions)
	expressions = convertRanges(expressions)
	expressions = convertSteps(expressions)

	return table.concat(expressions, " ")
end