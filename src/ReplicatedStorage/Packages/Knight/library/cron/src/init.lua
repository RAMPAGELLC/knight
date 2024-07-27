-- A cron-like scheduler in Luau. Logic taken from node-cron.
-- @Ulferno

local ScheduledTask = require(script.ScheduledTask)
local validate = require(script.Validation)

local Cron = {
	tasks = {},
}

-- Schedule a cron task
function Cron.schedule(...)
	local task = ScheduledTask.new(...)

	table.insert(Cron.tasks, task)

	return task
end

-- Validate a cron pattern without an error being thrown
function Cron.validate(expression: string)
	return pcall(validate, expression)
end

-- Returns currently scheduled tasks
function Cron.getTasks()
	return Cron.tasks
end

return Cron