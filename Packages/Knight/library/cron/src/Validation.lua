local convertExpression = require(script.Parent.ConvertExpression)

local validationPatterns = { "^%d+$", "^%*$", "^%*/(%d+)$" }

-- Tests if a string matches an expression pattern
function matchesPattern(expression: string)
	for _, pattern in ipairs(validationPatterns) do
		-- Test the expression against the pattern, if it matches then pass the test
		if expression:match(pattern) then
			return true
		end
	end

	-- If no tests have passed, fail the entire test
	return false
end

-- Tests a single expression (e.g. minute or hour)
function isValidExpression(expression: string, min: number, max: number)
	-- Split options up, tests them individually
	local options = expression:split(",")

	for _, option in ipairs(options) do
		-- Convert option to number.
		local optionAsNumber = tonumber(option)
		if optionAsNumber ~= nil then
			--  If the option is a valid number then, check if it is within the provided bounds:
			if optionAsNumber < min or optionAsNumber > max then
				return false
			end

			-- And also that it is an integer:
			if optionAsNumber ~= math.floor(optionAsNumber) then
				return false
			end
		end

		-- Test if the expression matches the expression patterns
		if not matchesPattern(option) then
			return false
		end
	end

	-- If no tests have failed, pass the entire test
	return true
end

-- Individual tests
function isInvalidSecond(expression: string)
	return not isValidExpression(expression, 0, 59)
end

function isInvalidMinute(expression: string)
	return not isValidExpression(expression, 0, 59)
end

function isInvalidHour(expression: string)
	return not isValidExpression(expression, 0, 23)
end

function isInvalidDayOfMonth(expression: string)
	return not isValidExpression(expression, 1, 31)
end

function isInvalidMonth(expression: string)
	return not isValidExpression(expression, 1, 12)
end

function isInvalidWeekDay(expression: string)
	return not isValidExpression(expression, 0, 7)
end

-- Validation for fields
function validateFields(patterns: { string }, executeablePatterns: { string })
	if isInvalidSecond(executeablePatterns[1]) then
		print(executeablePatterns[1])
		error(`[luau-cron] {patterns[1]} is an invalid expression for second`)
	end

	if isInvalidMinute(executeablePatterns[2]) then
		error(`[luau-cron] {patterns[2]} is an invalid expression for minute`)
	end

	if isInvalidHour(executeablePatterns[3]) then
		error(`[luau-cron] {patterns[3]} is an invalid expression for hour`)
	end

	if isInvalidDayOfMonth(executeablePatterns[4]) then
		error(`[luau-cron] {patterns[4]} is an invalid expression for day of month`)
	end

	if isInvalidMonth(executeablePatterns[5]) then
		error(`[luau-cron] {patterns[5]} is an invalid expression for month`)
	end

	if isInvalidWeekDay(executeablePatterns[6]) then
		error(`[luau-cron] {patterns[6]} is an invalid expression for week day`)
	end
end

-- Main validation
function validate(expression: string)
	if typeof(expression) ~= "string" then
		error("[luau-cron] expression must be a string")
	end

	local patterns = expression:split(" ")
	local executeablePatterns = convertExpression(expression):split(" ")

	if #patterns == 5 then
		table.insert(patterns, 1, "0")
	end

	validateFields(patterns, executeablePatterns)
end

return validate