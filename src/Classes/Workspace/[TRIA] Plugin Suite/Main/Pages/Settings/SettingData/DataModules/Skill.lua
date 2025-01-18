local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local Data = {
	Directory = "Skill",

	Dynamic = false,
	Items = {},
}

Data.Items = {
	{ 
		Text = "Allow Sliding",
		Type = "Checkbox",

        ApplyType = "Attribute",
		Directory = "Skill",
		Attribute = "AllowSliding",
		Fallback = true,

		Value = Value(false),
		Tooltip = {
			Text = "Determines whether or not players are allowed to slide in the map",
		},
	},

	{
		Text = "Linear Sliding",
		Type = "Checkbox",

        ApplyType = "Attribute",
		Directory = "Skill",
		Attribute = "LinearSliding",
		Fallback = false,

		Value = Value(false),
		Tooltip = {
			Text = [[Determines the type of sliding which is used in the map.
<b>Linear: </b>Sliding speed is constant throughout the duration of the slide.
<b>Non-linear: </b>Sliding speed is based on two combined tweens which both speedup and slowdown the player.]],
		},
	},

	{ 
		Text = "Allow Air Dive",
		Type = "Checkbox",

        ApplyType = "Attribute",
		Directory = "Skill",
		Attribute = "AllowAirDive",
		Fallback = true,

		Value = Value(false),
		Tooltip = {
			Text = "Determines whether or not players are allowed to air dive in the map",
		},
	},
}

return Data
