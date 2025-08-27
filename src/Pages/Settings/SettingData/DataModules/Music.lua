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

        ApplyType = "Property",
		Directory = "Music",
		Attribute = "SoundId",
        RbxAssetIdCheck = true,
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

        ApplyType = "Property",
		Directory = "Music",
		Attribute = "PlaybackSpeed",
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

        ApplyType = "Property",
		Directory = "Music",
		Attribute = "TimePosition",
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

        ApplyType = "Property",
		Directory = "Music",
		Attribute = "Volume",
		Fallback = 0.5,
		Default = 0.5,

		Value = Value(0.5),
		Tooltip = {
			Text = "How loud the audio should be.",
		},
	},

}

return Data
