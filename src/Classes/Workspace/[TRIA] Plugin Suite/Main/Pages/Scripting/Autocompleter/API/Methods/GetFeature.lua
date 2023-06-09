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
			MaxParams = 1,
			Parameters = {"\"Cinematic Mode\"", "\"Refresh Maps\"", "\"Slide\"", "\"Swim Down\"", "\"Swim Up\"", "\"Toggle Perspective\"", "\"First Person Cursor\"", "\"Show Timer\"", "\"Spawn In Elevator\"", "\"Spinny Locators\"", "\"Lobby volume\"", "\"Music volume\"", "\"SFX volume\"", "\"Field Of View\"", "\"Ghost Players\"", "\"HUD Scale\"", "\"Level Of Detail\"", "\"Lobby Type\"", "\"Theme\""},
			ParameterDescriptions = {
				["\"Cinematic Mode\""] = {
					Description = "The KeyCode for the key to toggle Cinematic Mode.",
					Detail = "Enum.KeyCode",
				},
				["\"Freecam\""] = {
					Description = "The KeyCode for toggling Freecam.",
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
				["\"Air FX\""] = {
					Description = "Adds extra effects to visualize air loss during rounds.",
					Detail = "boolean",
				},
				["\"Auto Spectate\""] = {
					Description = "Whether the user will automatically spectate someone upon death.",
					Detail = "boolean",
				},
				["\"Debug Mode\""] = {
					Description = "Whether the user is in debug mode.",
					Detail = "boolean",
				},
				["\"First Person Cursor\""] = {
					Description = "Whether or not the player uses a different first person cursor.",
					Detail = "boolean",
				},
				["\"Show Spectators\""] = {
					Description = "Whether the spectator count shows in the bottom right corner.",
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
	},

	["PlayerUI"] = {
		["LoadUI"] = {
			Name = "LoadUI",
			Type = "Method",
			Arguments = "LoadUI(gui: ScreenGUi): ()",
			Documentation = {
				value = "Loads a GUI for that round, and gets cleaned up at the end of the round."
			},
			CodeSample = [[
	local ScreenGui = Instance.new("ScreenGui")  
	ScreenGui.Name = "MapGui"  
	local Frame = Instance.new("Frame")  
	Frame.Parent = ScreenGui  
	
	MapLib:GetFeature("PlayerUI"):LoadUI(ScreenGui)	 
			]]
		},
	},

	["Players"] = {
		["GetPlayers"] = {
			Name = "GetPlayers",
			Type = "Method",
			Arguments = "GetSetting(): { Player }",
			Documentation = {
				value = "Retrieves a list of all players ingame."
			},
			CodeSample = [[
	local PlayersInRound = MapLib:GetFeature("Players"):GetPlayers()  

	for i, Player in pairs(PlayersInRound) do  
		print(Player.Name .. " is in the round!")  
	end  ]]
		},

		["GetPlayersInRadius"] = {
			Name = "GetPlayersInRadius",
			Type = "Method",
			Arguments = "GetPlayersInRadius(position: Vector3, radius: number): { Player }",
			Documentation = {
				value = "Retrieves a list of all players ingame that are within a certain radius from a specified point."
			},
			CodeSample = [[
	local PlayersAtStart = MapLib:GetFeature("Players"):GetPlayersInRadius(MapLib.Map.Special.Spawn.Position, 20)  

	for i, Player in pairs(PlayersAtStart) do  
		print(Player.Name .. " is still at the start!")  
	end  ]]
		}
	},

	["Teleport"] = {
		["Teleport"] = {
			Name = "Teleport",
			Type = "Method",
			Arguments = "Teleport(player: Player, position: CFrame | Vector3, faceFront: boolean?): ()",
			Documentation = {
				value = "Teleports the given player to the specified position."
			},
			CodeSample = [[
	local Players = MapLib:GetPlayers()

	-- Teleport all players still in round to (100, 50, 50)
	for i, Player in pairs(Players) do
		MapLib:GetFeature("Teleport"):Teleport(Player, Vector3.new(100, 50, 50), true)
	end
			]]
		},
	},
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

			["Players"] = {
				["GetPlayers"] = possibleBranches.Players.GetPlayers,
				["GetPlayersInRadius"] = possibleBranches.Players.GetPlayersInRadius,
			},

			["PlayerUI"] = {
				["LoadUI"] = possibleBranches.PlayerUI.LoadUI
			},

			["Teleport"] = {
				["Teleport"] = possibleBranches.Teleport.Teleport
			},
		}
		
		if params then
			return features[params[1]]
		end
		return nil
	end,
	Arguments = "GetFeature(featureName: string): MapLibFeature",
	MaxParams = 1,
	Parameters = {"\"Skills\"", "\"Settings\"", "\"Players\"", "\"PlayerUI\"", "\"Teleport\""},
	ParameterDescriptions = {
		["\"Skills\""] = {
			Description = "Interact with the skills (sliding, etc.) that players use during a round",
		},
		["\"Settings\""] = {
			Description = "Get local player settings (ex. level of detail)",
		},
		["\"Players\""] = {
			Description = "Get information about the players currently in round.",
		},
		["\"PlayerUI\""] = {
			Description = "Handles loading ScreenGui's during a round.",
		},
		["\"Teleport\""] = {
			Description = "Teleport players through the MapLib.",
		},
	},
	Documentation = {
		value = [[Allows you to retrieve additional features from the MapLib for more advanced functions.  ]]
	},
}
