local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

return {
    {
        Text = "Creator (s)",
        Type = "String",

        Directory = "Main",
        Attribute = "Creator",
        Fallback = "TRIA",

        Value = Value("")
    },

    {
        Text = "Difficulty",
        Type = "Number",

        Directory = "Main",
        Attribute = "Difficulty",
        Fallback = 6,

        Value = Value("")
    },

    {
        Text = "Thumbnail Image",
        Type = "Number",

        Directory = "Main",
        Attribute = "Image",
        Fallback = 10672852399,

        Value = Value("")
    },

    {
        Text = "Max Time",
        Type = "Number",

        Directory = "Main",
        Attribute = "MaxTime",
        Fallback = 120,

        Value = Value("")
    },

    {
        Text = "Background Music",
        Type = "Number",

        Directory = "Main",
        Attribute = "Music",
        Fallback = 6366407687,

        Value = Value("")
    },

    {
        Text = "BGM Volume",
        Type = "Number",

        Directory = "Main",
        Attribute = "MusicVolume",
        Fallback = 0.5,

        Value = Value("")
    },

    {
        Text = "Map Name",
        Type = "String",

        Directory = "Main",
        Attribute = "Name",
        Fallback = "Map Kit",

        Value = Value("")
    },

    {
        Text = "Default Oxygen",
        Type = "Number",

        Directory = "Main",
        Attribute = "DefaultOxygen",
        Fallback = "100",

        Value = Value("")
    },

    {
        Text = "Allow Sliding",
        Type = "Checkbox",

        Directory = "Skills",
        Attribute = "AllowSliding",
        Fallback = true,

        Value = Value(false)
    },

    {
        Text = "Linear Sliding",
        Type = "Checkbox",

        Directory = "Skills",
        Attribute = "LinearSliding",
        Fallback = false,

        Value = Value(false)
    },

    {
        Text = "Ambient",
        Type = "Color",

        Directory = "Lighting",
        Attribute = "Ambient",
        Fallback = Util.colorToRGB(Color3.fromRGB(118, 118, 118)),

        Value = Value(Color3.new())
    },

    {
        Text = "Brightness",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "Brightness",
        Fallback = 2,

        Value = Value(2)
    },

    {
        Text = "Time of Day",
        Type = "Time",

        Directory = "Lighting",
        Attribute = "TimeOfDay",
        Fallback = "12:00:00",

        Value = Value("12:00:00")
    },

    {
        Text = "ColorShift - Bottom",
        Type = "Color",

        Directory = "Lighting",
        Attribute = "ColorShift_Bottom",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new())
    },

    {
        Text = "ColorShift - Top",
        Type = "Color",

        Directory = "Lighting",
        Attribute = "ColorShift_Top",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new())
    },

    {
        Text = "EnvironmentDiffuseScale",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "EnvironmentDiffuseScale",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "EnvironmentSpecularScale",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "EnvironmentSpecularScale",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "Fog Color",
        Type = "Color",

        Directory = "Lighting",
        Attribute = "FogColor",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new())
    },

    {
        Text = "Fog Start",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "FogStart",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "Fog End",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "FogEnd",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "GeographicLatitude",
        Type = "Number",

        Directory = "Lighting",
        Attribute = "GeographicLatitude",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "Global Shadows",
        Type = "Checkbox",

        Directory = "Lighting",
        Attribute = "GlobalShadows",
        Fallback = false,

        Value = Value(false)
    },

    {
        Text = "Outdoor Ambient",
        Type = "Color",

        Directory = "Lighting",
        Attribute = "OutdoorAmbient",
        Fallback = Util.colorToRGB(Color3.fromRGB(70, 70, 70)),

        Value = Value(Color3.new())
    },
}
