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
		Text = "Sound ID",
		Type = "String",

		Directory = "Music",
		Property = "SoundId",
		Fallback = "",
		Default = "",

		Value = Value(""),
		Tooltip = {
			Text = "The Asset ID of your desired BGM.",
		},
	},

    {
		Text = "Playback Speed",
		Type = "Number",

		Directory = "Music",
		Property = "PlaybackSpeed",
		Fallback = 1,
		Default = 1,

		Value = Value(1),
		Tooltip = {
			Text = "How fast the sound should play.",
		},
	},

    {
		Text = "Time Position",
		Type = "Number",

		Directory = "Music",
		Property = "TimePosition",
		Fallback = 0,
		Default = 0,

		Value = Value(0),
		Tooltip = {
			Text = "What timestamp the music should start at",
		},
	},

    {
		Text = "Volume",
		Type = "Number",

		Directory = "Music",
		Property = "Volume",
		Fallback = 0.5,
		Default = 0.5,

		Value = Value(0.5),
		Tooltip = {
			Text = "How loud the audio should be.",
		},
	},

}

-- TODO: ITS NOT CODED TO WORK WITH PROPERTIES INSTEAD OF ATTRIBUTES YET
Data.Items = {}

return Data
