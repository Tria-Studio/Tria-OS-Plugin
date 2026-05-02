-- Copyright (C) 2026 TRIA
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
-- If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
