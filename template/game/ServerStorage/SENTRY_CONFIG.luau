
local SENTRY_PROJECT = "your_project_id"
local SENTRY_ORG = "o123456" -- from your DSN

return {
	SENTRY_KEY = "your_public_key",
	SENTRY_URL = string.format("https://%s.ingest.sentry.io/api/%s/store/", SENTRY_ORG, SENTRY_PROJECT),
}
