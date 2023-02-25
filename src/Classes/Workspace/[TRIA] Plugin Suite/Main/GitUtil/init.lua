local GitUtil = {}

local HttpService = game:GetService("HttpService")
local REFRESH_SECONDS = 60

function GitUtil:Fetch(url: string): (boolean, any?, string?, string?)
	local result
	local fired, err = pcall(function()
		result = HttpService:GetAsync(url)
	end)

	if not fired then
		local httpDisabled = err:find("permission denied")
		return false, nil, httpDisabled and "HTTPDisabled" or "HTTPError", err
	end
	
	fired, err = pcall(function()
		result = HttpService:JSONDecode(result)
	end)

	if not success then
		return false, nil, "JSONDecodeError", err
	end
	
	return true, result, nil, nil
end

function GitUtil:GetNextRefreshTime(): number
	local currentDate = os.date("!*t")
	local current = os.time({
		year = currentDate.year,
		month = currentDate.month,
		day = currentDate.day,
		hour = currentDate.hour,
		min = currentDate.min,
	})

	return os.time(os.date("!*t", current + REFRESH_SECONDS))
end

function GitUtil:GetTimeUntilNextRefresh(): number
	return os.difftime(self:GetNextRefreshTime(), os.time())
end

return GitUtil