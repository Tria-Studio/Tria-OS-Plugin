local possibleBranches = {
	["Skills"] = {
		["ToggleSliding"] = {
			Name = "ToggleSliding",
			Parameters = {"true", "false"},
			Documentation = {
				value = "Toggles sliding"
			},
			CodeSample = [[
	MapLib:GetFeature("Skills"):ToggleSliding(true)	
			]]
		},
	},

	["Settings"] = {
		["GetSetting"] = {
			Name = "GetSetting",
			Parameters = {},
			Documentation = {
				value = "Retrieves a setting"
			},
			CodeSample = [[
	MapLib:GetFeature("Settings"):GetSetting("FOV")	
			]]
		}
	}
}

local possibleBranchArray = {}
for _, v in pairs(possibleBranches) do
	for k, d in pairs(v) do
		possibleBranchArray[k] = d
	end
end

return {
	AutocompleteArgs = {"featureName"},
	Name = "GetFeature",
	PossibleBranches = possibleBranchArray,
	Branches = function(params)
		local features = {
			["Skills"] = {
				["ToggleSliding"] = possibleBranches.Skills.ToggleSliding
			},

			["Settings"] = {
				["GetSetting"] = possibleBranches.Settings.GetSetting
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
