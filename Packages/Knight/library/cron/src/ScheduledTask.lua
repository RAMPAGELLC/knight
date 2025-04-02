local HttpService = game:GetService("HttpService")

type TaskOptions = {
	scheduled: boolean?,
	autorecover: boolean?,
}

local MatchDelay = 1

local validatePattern = require(script.Parent.Validation)
local convertExpression = require(script.Parent.ConvertExpression)

local DEFUALT_OPTIONS: TaskOptions = {
	scheduled = true,
	autorecover = true,
}
DEFUALT_OPTIONS.__index = DEFUALT_OPTIONS

local ScheduledTask = {}
ScheduledTask.__index = ScheduledTask

function ScheduledTask.new(expression: string, callback: () -> any, options: TaskOptions)
	local self = setmetatable({}, ScheduledTask)

	validatePattern(expression)

	self.options = setmetatable(options or {}, DEFUALT_OPTIONS)
	self.options.name = self.options.name or HttpService:GenerateGUID(false)

	self.rawPattern = expression
	self.pattern = convertExpression(expression)

	self.callback = callback

	if self.options.scheduled ~= false then
		self:start()
	end

	return self
end

function ScheduledTask:start()
	self.options.scheduled = true

	local lastCheck = os.clock()
	local lastExecution = os.time()

	local function matchTime()
		local elapsedTime = os.clock() - lastCheck
		local missedExecutions = math.floor(elapsedTime)

		for i = missedExecutions, 1, -1 do
			local executionTime = os.time() - i

			if
				lastExecution < executionTime
				and (i == 0 or self.options.autorecover)
				and self:_shouldRun(executionTime)
			then
				task.spawn(xpcall, self.callback, function(err)
					warn(
						`[luau-cron] error while running callback for "{self.options.name}" ({self.rawPattern}): {err}\n`,
						debug.traceback()
					)
				end)

				lastExecution = executionTime
			end
		end

		lastCheck = os.clock()
		self.thread = task.delay(MatchDelay, matchTime)
	end

	matchTime()
end

function ScheduledTask:stop()
	self.options.scheduled = false

	if self.thread then
		task.cancel(self.thread)
	end
	self.thread = nil
end

function ScheduledTask:_shouldRunPattern(pattern: string, value: number)
	if pattern:match(",") then
		local patterns = pattern:split(",")

		for _, individualPattern in ipairs(patterns) do
			if individualPattern == tostring(value) then
				return true
			end
		end

		return false
	end

	return pattern == tostring(value)
end

function ScheduledTask:_shouldRun(executionTime: number)
	local expressions = self.pattern:split(" ")

	local date = os.date("!*t", executionTime)

	local runOnSecond = self:_shouldRunPattern(expressions[1], date.sec)
	local runOnMinute = self:_shouldRunPattern(expressions[2], date.min)
	local runOnHour = self:_shouldRunPattern(expressions[3], date.hour)
	local runOnDay = self:_shouldRunPattern(expressions[4], date.day)
	local runOnMonth = self:_shouldRunPattern(expressions[5], date.month)
	local runOnWeekDay = self:_shouldRunPattern(expressions[6], date.wday - 1)

	return runOnSecond and runOnMinute and runOnHour and runOnDay and runOnMonth and runOnWeekDay
end

return ScheduledTask