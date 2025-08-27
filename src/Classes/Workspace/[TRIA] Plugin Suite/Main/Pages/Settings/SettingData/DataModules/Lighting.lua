local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local Data = {
	Directory = "Lighting",

	Dynamic = false,
	Items = {},
}

Data.Items = {
	{
		Text = "Ambient",
		Type = "Color",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "Ambient",
		Fallback = Util.colorToRGB(Color3.fromRGB(118, 118, 118)),
		Default = Color3.fromRGB(118, 118, 118),

		Value = Value(Color3.new()),
		Tooltip = {
			Text = "The ambient of the map.",
		},
	},

	{
		Text = "Brightness",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "Brightness",
		Fallback = 2,

		Value = Value(2),
		Tooltip = {
			Text = "How bright the map is.",
		},
	},

	{
		Text = "Time of Day",
		Type = "Time",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "TimeOfDay",
		Fallback = "12:00:00",

		Value = Value("12:00:00"),
		Tooltip = {
			Text = "The time of day during the map. Not to be confused with ClockTime.",
		},
	},

	{
		Text = "ColorShift_Bottom",
		Type = "Color",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "ColorShift_Bottom",
		Fallback = Util.colorToRGB(Color3.fromRGB(0, 0, 0)),
		Default = Color3.new(),

		Value = Value(Color3.new()),
		Tooltip = {
			Text = "The hue represented in light reflected in the opposite surfaces to those facing the sun or moon.",
		},
	},

	{
		Text = "ColorShift_Top",
		Type = "Color",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "ColorShift_Top",
		Fallback = Util.colorToRGB(Color3.fromRGB(0, 0, 0)),
		Default = Color3.new(),

		Value = Value(Color3.new()),
		Tooltip = {
			Text = "The hue represented in light reflected from surfaces facing the sun or moon.",
		},
	},

	{
		Text = "EnvironmentDiffuseScale",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "EnvironmentDiffuseScale",
		Fallback = 0,

		Value = Value(0),
		Tooltip = {
			Text = "A value 0 - 1 on how much the environment should blend with the sky.",
		},
	},

	{
		Text = "EnvironmentSpecularScale",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "EnvironmentSpecularScale",
		Fallback = 0,

		Value = Value(0),
		Tooltip = {
			Text = "A value 0 - 1 on how much the environment should reflect the sky.",
		},
	},

	{
		Text = "Fog Color",
		Type = "Color",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "FogColor",
		Fallback = Util.colorToRGB(Color3.fromRGB(0, 0, 0)),
		Default = Color3.new(),

		Value = Value(Color3.new()),
		Tooltip = {
			Text = "The color of the fog.",
		},
	},

	{
		Text = "Fog Start",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "FogStart",
		Fallback = 0,

		Value = Value(0),
		Tooltip = {
			Text = "The distance from the camera in which the fog will begin to show.",
		},
	},

	{
		Text = "Fog End",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "FogEnd",
		Fallback = 0,

		Value = Value(0),
		Tooltip = {
			Text = "The distance from the camera where the fog will be completely opaque.",
		},
	},

	{
		Text = "GeographicLatitude",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "GeographicLatitude",
		Fallback = 0,

		Value = Value(0),
	},

	{
		Text = "Global Shadows",
		Type = "Checkbox",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "GlobalShadows",
		Fallback = false,

		Value = Value(false),
		Tooltip = {
			Text = "Whether or not the sun will cast shadows.",
		},
	},

    {
		Text = "Shadow Softness",
		Type = "Number",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "ShadowSoftness",
		Fallback = 0.5,

		Value = Value(0.5),
		Tooltip = {
			Text = "How sharp the edges of all sun shadows will appear.",
		},
	},

	{
		Text = "Outdoor Ambient",
		Type = "Color",

        ApplyType = "Attribute",
		Directory = "Lighting",
		Attribute = "OutdoorAmbient",
		Fallback = Util.colorToRGB(Color3.fromRGB(70, 70, 70)),
		Default = Color3.fromRGB(70, 70, 70),

		Value = Value(Color3.new()),
		Tooltip = {
			Text = "The ambient in any setting which has sunlight.",
		},
	},
}

return Data
