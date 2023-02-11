local Autocompleter = {}

local Suggester = require(script.Suggester)
local GlobalSettings = require(script.GlobalSettings)

function Autocompleter:toggle(newState: boolean)
	GlobalSettings.enabled = newState
	Suggester:disableCallback()
	if GlobalSettings.enabled then
		print("Starting")
		Suggester:registerCallback()
	end
end

Autocompleter:toggle(GlobalSettings.enabled)
return Autocompleter