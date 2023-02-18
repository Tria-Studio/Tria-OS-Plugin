local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local Data = {
	Directory = "Main",

	Dynamic = false,
	Items = {},
}

Data.Items = {
	{
		Text = "Creator (s)",
		Type = "String",

		Attribute = "Creator",
		Fallback = "TRIA",
		Value = Value(""),
		Tooltip = {
			Text = "The name(s) of the creators of the map.",
		},
	},

	{
		Text = "Difficulty",
		Type = "Dropdown",
		DropdownArray = "Difficulty",

		Attribute = "Difficulty",
		Fallback = 6,

		Value = Value(""),
		Tooltip = {
			Text = [[<font color = "rgb(175,175,175)">Map difficulties determine how hard the map is:</font>
<font color ="rgb(255,255,255)"> 0 - Unrated </font>
<font color ="rgb(0,255,0)"> 1 - Easy </font>
<font color ="rgb(255,255,0)"> 2 - Normal </font>
<font color ="rgb(255,0,0)"> 3 - Hard </font>
<font color ="rgb(180,0,180)"> 4 - Insane </font>
<font color ="rgb(255,155,0)"> 5 - Extreme </font>
<font color ="rgb(255,0,255)"> 6 - Divine </font>

Unknown difficulties cannot be published and are not officially supported.
]],
		},
	},

	{
		Text = "Thumbnail Image",
		Type = "Number",

		Attribute = "Image",
		Fallback = 10672852399,

		Value = Value(""),
		Tooltip = {
			Text = "The image of your map that displays in the lift + in the maplist.\nFor minimal compression, thumbnails should be 16:9.",
		},
	},

	{
		Text = "Max Time",
		Type = "Number",

		Attribute = "MaxTime",
		Fallback = 120,

		Value = Value(""),
		Tooltip = {
			Text = "How long the map should last. Any players after this time will be killed. Maximum value of 420 seconds (7 minutes)",
		},
	},

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
		Text = "BGM Volume",
		Type = "Number",

		Attribute = "MusicVolume",
		Fallback = 0.5,

		Value = Value(""),
		Tooltip = {
			Text = "Volume of the music that plays in the background.",
		},
	},

	{
		Text = "Map Name",
		Type = "String",

		Attribute = "Name",
		Fallback = "Map Kit",

		Value = Value(""),
		Tooltip = {
			Text = "The name of your map.",
		},
	},

	{
		Text = "Default Oxygen",
		Type = "Number",

		Attribute = "DefaultOxygen",
		Fallback = "100",

		Value = Value(""),
		Tooltip = {
			Text = "The total amount of oxygen you can have without an air tank.",
		},
	},
}

return Data
