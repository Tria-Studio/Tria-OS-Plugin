local GitUtil = {}

local HttpService = game:GetService("HttpService")

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

return GitUtil