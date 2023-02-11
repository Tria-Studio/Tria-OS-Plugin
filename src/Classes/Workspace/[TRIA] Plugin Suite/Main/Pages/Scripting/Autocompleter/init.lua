local Autocompleter = {}

local Suggester = require(script.Suggester)
local GlobalSettings = require(script.GlobalSettings)

function Autocompleter:toggle(newState: boolean)
	GlobalSettings.enabled = newState
	Suggester:disableCallback()
	if GlobalSettings.enabled then
		Suggester:registerCallback()
	end
end

Autocompleter:toggle(Autocompleter.enabled)
return Autocompleter