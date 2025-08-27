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
		Text = "Difficulty",
		Type = "Dropdown",
		DropdownArray = "Difficulty",

        ApplyType = "Attribute",
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
<font color ="rgb(255,255,255)"> 7 - Eternal </font>
]],
		},
	},

	{
		Text = "Thumbnail Image",
		Type = "Number",

        ApplyType = "Attribute",
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

        ApplyType = "Attribute",
		Attribute = "MaxTime",
		Fallback = 120,

		Value = Value(""),
		Tooltip = {
			Text = "How long the map should last. Any players after this time will be killed. Maximum value of 420 seconds (7 minutes).",
		},
	},

	{
		Text = "Map Name",
		Type = "String",

        ApplyType = "Attribute",
		Attribute = "Name",
		Fallback = "Map Kit",

		Value = Value(""),
		Tooltip = {
			Text = "The name of your map.",
		},
	},

    {
		Text = "Description",
		Type = "String",

        ApplyType = "Attribute",
		Attribute = "Description",
		Fallback = "",

		Value = Value(""),
		Tooltip = {
			Text = "Map descriptions show on the info page, and get filtered by Roblox. Max 250 chars.",
		},
	},
}

return Data
