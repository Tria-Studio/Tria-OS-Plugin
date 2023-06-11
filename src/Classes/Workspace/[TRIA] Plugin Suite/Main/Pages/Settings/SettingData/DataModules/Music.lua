local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local Data = {
	Directory = "Music",

	Dynamic = false,
	Items = {},
}

Data.Items = {

    {
		Text = "BGM",
		Type = "Number",

		Attribute = "Music",
		Fallback = 6366407687,

		Value = Value(""),
		Tooltip = {
			Text = "The AssetID of the music that plays in the background of your map.",
		},
	},

    {
		Text = "Music Volume",
		Type = "Number",

		Attribute = "Volume",
		Fallback = 0.5,

		Value = Value(""),
		Tooltip = {
			Text = "Volume of the music that plays in the background.",
		},
	},

    {
		Text = "Time Position",
		Type = "Number",

		Attribute = "TimePosition",
		Fallback = 0,

		Value = Value(""),
		Tooltip = {
			Text = "The time at which the BGM starts at when the round begins.",
		},
	},
	
}

return Data
