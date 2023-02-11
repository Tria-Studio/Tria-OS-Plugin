local Autocompleter = {}
Autocompleter.enabled = true
Autocompleter.allowedPhrases = {}
Autocompleter.removedPhrases = {}
Autocompleter.runOnlyInMapscript = false

local Suggester = require(script.Suggester)

function Autocompleter:toggle(newState: boolean)
	self.enabled = newState
	Suggester:disableCallback()
	if self.enabled then
		Suggester:registerCallback()
	end
end

Autocompleter:toggle(Autocompleter.enabled)
return Autocompleter