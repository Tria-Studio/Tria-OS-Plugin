local possibleBranches = {
	["Skills"] = {
		["ToggleSliding"] = {
			Name = "ToggleSliding",
			MaxParams = 1,
			Arguments = "ToggleSliding(isActive: boolean): ()",
			Documentation = {
				value = "Toggles the sliding skill mid round."
			},
			CodeSample = [[
	MapLib:GetFeature("Skills"):ToggleSliding(true)	
			]]
		},
	},

	["Settings"] = {
		["GetSetting"] = {
			Name = "GetSetting",
			MaxParams = 0,
			Arguments = "GetSetting(settingName: string): any",
			Documentation = {
				value = "Retrieves any of the players ingame settings. Can be useful to try to tone down scripted effects with the players ingame Detail setting."
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
		
		if params then
			return features[params[1]]
		end
		return nil
	end,
	Arguments = "GetFeature(featureName: string): Feature",
	MaxParams = 1,
	Parameters = {"\"Skills\"", "\"Settings\""},
	ParameterDescriptions = {
		["\"Skills\""] = "Interact with the skills (sliding, etc.) that players use during a round",
		["\"Settings\""] = "Get local player settings (ex. level of detail)"
	},
	Documentation = {
		value = [[Allows you to get a specific Feature from the MapLib  
		
Avaliable Features:
	"Skills", -- Interact with the skills (sliding, etc.) that players use during a round    
	"Settings", -- Get local player settings (ex. level of detail)  ]]
	},
}
