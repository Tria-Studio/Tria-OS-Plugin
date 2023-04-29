local possibleBranches = {
	["ToggleSliding"] = {
		Name = "ToggleSliding",
		Parameters = {"true", "false"},
		Documentation = {
			value = "Toggles sliding"
		},
		CodeSample = [[
MapLib:GetFeature("Skills"):ToggleSliding(true)	
		]]
	}
}

return {
	AutocompleteArgs = {"featureName"},
	Name = "GetFeature",
	PossibleBranches = possibleBranches,
	Branches = function(params)
		local features = {
			["Skills"] = {
				["ToggleSliding"] = possibleBranches.ToggleSliding
			},
		}
		
		if params and #params > 0 then
			return features[params[1]]
		end
		return nil
	end,
	Parameters = {"\"Skills\"", "\"Settings\""},
	Documentation = {
		value = "Allows you to get a specific Feature from the MapLib"
	},
	CodeSample = [[
AVALIABLE_FEATURES = {
	"Skills", -- Interact with the skills (sliding, etc.) that the map uses  
	"Settings", -- Get local player settings (ex. level of detail)  
}  ]],
}
