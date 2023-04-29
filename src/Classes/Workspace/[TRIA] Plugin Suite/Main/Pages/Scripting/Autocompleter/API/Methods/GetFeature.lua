return {
	AutocompleteArgs= {"featureName"},
	Name = "GetFeature",
	Branches = function(params)
		local features = {
			["Skills"] = {"ToggleSliding"},
		}
		if params and #params > 0 then
			return features[params[1]]
		end
		return nil
	end,
	Parameters = {"Skills", "Settings"},
	Documentation = {
		value = "Allows you to get a specific Feature from the MapLib"
	},
	CodeSample = [[
AVALIABLE_FEATURES = {
	"Skills", -- Interact with the skills (sliding, etc.) that the map uses  
	"Settings", -- Get local player settings (ex. level of detail)  
}  ]],
}
