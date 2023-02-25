local GitUtil = {}

local HttpService = game:GetService("HttpService")
local REFRESH_HOURS = 12

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
	local date = os.date("!*t")
	return os.time({
		year = date.year,
		month = date.month,
		day = date.day,
		hour = math.ceil((date.hour + 1) / REFRESH_HOURS) * REFRESH_HOURS,
	})
end

function GitUtil:GetTimeUntilNextRefresh(): number
	return os.difftime(self:GetNextRefreshTime(), os.time())
end

return GitUtil