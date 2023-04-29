return {
	AutocompleteArgs= {"featureName"},
	Name = "GetFeature",
	Branches = function(params)
		
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
