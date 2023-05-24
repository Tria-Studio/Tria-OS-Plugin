local possibleBranches = {
	["Skills"] = {
		["ToggleSliding"] = {
			Name = "ToggleSliding",
			MaxParams = 1,
			Type = "Method",
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
			Type = "Method",
			Arguments = "GetSetting(settingName: string): any",
			Documentation = {
				value = "Retrieves any of the players ingame settings. Can be useful to try to tone down scripted effects with the players ingame Detail setting."
			},
			MaxParams = 19,
			Parameters = {"\"Cinematic Mode\"", "\"Refresh Maps\"", "\"Slide\"", "\"Swim Down\"", "\"Swim Up\"", "\"Toggle Perspective\"", "\"First Person Cursor\"", "\"Show Timer\"", "\"Spawn In Elevator\"", "\"Spinny Locators\"", "\"Lobby volume\"", "\"Music volume\"", "\"SFX volume\"", "\"Field Of View\"", "\"Ghost Players\"", "\"HUD Scale\"", "\"Level Of Detail\"", "\"Lobby Type\"", "\"Theme\""},
			ParameterDescriptions = {
				["\"Cinematic Mode\""] = {
					Description = "The KeyCode for the key to toggle Cinematic Mode.",
					Detail = "Enum.KeyCode",
				},
				["\"Refresh Maps\""] = {
					Description = "The KeyCode for the key to refresh the map list.",
					Detail = "Enum.KeyCode",
				},
				["\"Slide\""] = {
					Description = "The KeyCode for the key to use the slide feature.",
					Detail = "Enum.KeyCode",
				},
				["\"Swim Down\""] = {
					Description = "The KeyCode for the key to swim down inside a liquid.",
					Detail = "Enum.KeyCode",
				},
				["\"Swim Up\""] = {
					Description = "The KeyCode for the key to swim up inside a liquid.",
					Detail = "Enum.KeyCode",
				},
				["\"Toggle Perspective\""] = {
					Description = "The KeyCode for the key used to toggle from 1st to 3rd person, and vise-versa.",
					Detail = "Enum.KeyCode",
				},
				["\"First Person Cursor\""] = {
					Description = "Whether or not the player uses a different first person cursor.",
					Detail = "boolean",
				},
				["\"Show Timer\""] = {
					Description = "Whether or not the round timer shows in the bottom right corner.",
					Detail = "boolean",
				},
				["\"Spawn In Elevator\""] = {
					Description = "Whether or not the player spawns in the elevator when they respawn.",
					Detail = "boolean",
				},
				["\"Spinny Locators\""] = {
					Description = "Whether or not the button locators spin.",
					Detail = "boolean",
				},
				["\"Lobby volume\""] = {
					Description = "The volume from 0-2 of the lobby music.",
					Detail = "number",
				},
				["\"Music volume\""] = {
					Description = "The volume from 0-2 of all music.",
					Detail = "number",
				},
				["\"SFX volume\""] = {
					Description = "The volume from 0-2 of all sound effects.",
					Detail = "number",
				},
				["\"Field Of View\""] = {
					Description = "The field of view of the players camera.",
					Detail = "number",
				},
				["\"Ghost Players\""] = {
					Description = "Determines the behavior of ghosting players from none, near, friends, and all.",
					Detail = "string",
				},
				["\"HUD Scale\""] = {
					Description = "Determines the scale percent of the HUD.",
					Detail = "number",
				},
				["\"Level Of Detail\""] = {
					Description = "Determines the level of detail for the user.\n\nHigh: nothing changes\nMedium: Detail folder is deleted\nLow: Detail foler is deleted, all transparency set to 0, textures removed, smooth plastic, etc.",
					Detail = "string",
				},
				["\"Lobby Type\""] = {
					Description = "Determines the level of detail for the lobby.",
					Detail = "string",
				},
				["\"Theme\""] = {
					Description = "The current UI theme the user is using",
					Detail = "string",
				},
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
	Arguments = "GetFeature(featureName: string): MapLibFeature",
	MaxParams = 1,
	Parameters = {"\"Skills\"", "\"Settings\""},
	ParameterDescriptions = {
		["\"Skills\""] = {
			Description = "Interact with the skills (sliding, etc.) that players use during a round",
		},
		["\"Settings\""] = {
			Description = "Get local player settings (ex. level of detail)",
		},
	},
	Documentation = {
		value = [[Allows you to get a specific Feature from the MapLib  
		
Avaliable Features:
	"Skills", -- Interact with the skills (sliding, etc.) that players use during a round    
	"Settings", -- Get local player settings (ex. level of detail)  ]]
	},
}
