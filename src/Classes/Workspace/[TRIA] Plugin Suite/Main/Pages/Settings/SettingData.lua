local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value

return {
    {
        Text = "Mapkit Version",
        Type = "String",
        Modifiable = false,

        Directory = "Main",
        Attribute = "_KitVersion",
        Fallback = 0,

        Value = Value("")
    },

    {
        Text = "Creator (s)",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "Creator",
        Fallback = "TRIA",

        Value = Value("")
    },

    {
        Text = "Difficulty",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "Difficulty",
        Fallback = "6",

        Value = Value("")
    },

    {
        Text = "Thumbnail Image",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "MapImage",
        Fallback = "10672852399",

        Value = Value("")
    },

    {
        Text = "Max Time",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "MaxTime",
        Fallback = "120",

        Value = Value("")
    },

    {
        Text = "Background Music",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "Music",
        Fallback = "6366407687",

        Value = Value("")
    },

    {
        Text = "BGM Volume",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "MusicVolume",
        Fallback = "0.5",

        Value = Value("")
    },

    {
        Text = "Map Name",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "Name",
        Fallback = "Map Kit",

        Value = Value("")
    },

    {
        Text = "Allow Sliding",
        Type = "Checkbox",
        Modifiable = true,

        Directory = "Skills",
        Attribute = "AllowSliding",
        Fallback = true,

        Value = Value("")
    },

    {
        Text = "Linear Sliding",
        Type = "Checkbox",
        Modifiable = true,

        Directory = "Skills",
        Attribute = "LinearSliding",
        Fallback = false,

        Value = Value("")
    },

    {
        Text = "Default Oxygen",
        Type = "String",
        Modifiable = true,

        Directory = "Main",
        Attribute = "DefaultOxygen",
        Fallback = "100",

        Value = Value("")
    },
}