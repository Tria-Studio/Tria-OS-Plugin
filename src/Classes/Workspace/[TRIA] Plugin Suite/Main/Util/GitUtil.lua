local HttpService = game:GetService("HttpService")

local Util = require(script.Parent)

local GitUtil = {}

function GitUtil:Fetch(url: string): (boolean, any?, string?, string?)
	if Util.AudioPerms then
		Util.AudioPermsToggled:Wait()
	end
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

	if not fired then
		return false, nil, "JSONDecodeError", err
	end
	
	return true, result, nil, nil
end

return GitUtil
