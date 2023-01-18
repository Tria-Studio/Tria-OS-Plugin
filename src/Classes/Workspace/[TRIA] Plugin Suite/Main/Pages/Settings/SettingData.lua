local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

return {
    {
        Text = "Mapkit Version",
        Type = "String",
        Modifiable = Value(false),

        Directory = "Main",
        Attribute = "_KitVersion",
        Fallback = 0,

        Value = Value(""),
        Tooltip = {
            Text = "The current map kit version you are on. This <b>should not</b> be edited."
        }
    },

    {
        Text = "Creator (s)",
        Type = "String",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "Creator",
        Fallback = "TRIA",
        Value = Value(""),
        Tooltip = {
            Text = "The name(s) of the creators of the map."
        }
    },

    {
        Text = "Difficulty",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "Difficulty",
        Fallback = 6,

        Value = Value(""),
        Tooltip = {
            Text = [[
                <font color = "rgb(175,175,175)">Map difficulties determine show how hard the map is:</font>
                <font color ="rgb(255,255,255)">  0 - Unrated </font>
                <font color ="rgb(0,255,0)"> 1 - Easy </font>
                <font color ="rgb(255,255,0)"> 2 - Normal </font>
                <font color ="rgb(255,0,0)"> 3 - Hard </font>
                <font color ="rgb(180,0,180)"> 4 - Insane </font>
                <font color ="rgb(255,155,0)"> 5 - Extreme </font>
                <font color ="rgb(255,0,255)"> 6 - Divine </font>
                <font color ="rgb(175,0,0)"> [Other] - Unknown (cannot be published to the map list) </font>
            ]]
        }
    },

    {
        Text = "Thumbnail Image",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "Image",
        Fallback = 10672852399,

        Value = Value(""),
        Tooltip = {
            Text = "The image that will display in the map list + lobby"
        }
    },

    {
        Text = "Max Time",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "MaxTime",
        Fallback = 120,

        Value = Value(""),
        Tooltip = {
            Text = "How long the map should last. Any players after this time will be killed. Maximum value of 420 seconds (7 minutes)"
        }
    },

    {
        Text = "Background Music",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "Music",
        Fallback = 6366407687,

        Value = Value(""),
        Tooltip = {
            Text = "The AssetID of the music that plays in the background of your map."
        }
    },

    {
        Text = "BGM Volume",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "MusicVolume",
        Fallback = 0.5,

        Value = Value(""),
        Tooltip = {
            Text = "Volume of the music that plays in the background."
        }
    },

    {
        Text = "Map Name",
        Type = "String",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "Name",
        Fallback = "Map Kit",

        Value = Value(""),
        Tooltip = {
            Text = "The name of your map."
        }
    },

    {
        Text = "Default Oxygen",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Main",
        Attribute = "DefaultOxygen",
        Fallback = "100",

        Value = Value(""),
        Tooltip = {
            Text = "The total amount of oxygen you can have without an air tank."
        }
    },

    {
        Text = "Allow Sliding",
        Type = "Checkbox",
        Modifiable = Value(true),

        Directory = "Skills",
        Attribute = "AllowSliding",
        Fallback = true,

        Value = Value(false),
        Tooltip = {
            Text = "Determines whether or not players are allowed to slide in the map"
        }
    },

    {
        Text = "Linear Sliding",
        Type = "Checkbox",
        Modifiable = Value(true),

        Directory = "Skills",
        Attribute = "LinearSliding",
        Fallback = false,

        Value = Value(false)
    },

    {
        Text = "Ambient",
        Type = "Color",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "Ambient",
        Fallback = Util.colorToRGB(Color3.fromRGB(118, 118, 118)),

        Value = Value(Color3.new()),
        Tooltip = {
            Text = "The ambient of the map."
        }
    },

    {
        Text = "Brightness",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "Brightness",
        Fallback = 2,

        Value = Value(2),
        Tooltip = {
            Text = "How bright the map is."
        }
    },

    {
        Text = "Time of Day",
        Type = "Time",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "TimeOfDay",
        Fallback = "12:00:00",

        Value = Value("12:00:00"),
        Tooltip = {
            Text = "The time of day during the map."
        }
    },

    {
        Text = "ColorShift - Bottom",
        Type = "Color",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "ColorShift_Bottom",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new()),
        Tooltip = {
            Text = "The hue represented in light reflected in the opposite surfaces to those facing the sun or moon."
        }
    },

    {
        Text = "ColorShift - Top",
        Type = "Color",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "ColorShift_Top",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new()),
        Tooltip = {
            Text = "The hue represented in light reflected from surfaces facing the sun or moon."
        }
    },

    {
        Text = "EnvironmentDiffuseScale",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "EnvironmentDiffuseScale",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "EnvironmentSpecularScale",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "EnvironmentSpecularScale",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "Fog Color",
        Type = "Color",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "FogColor",
        Fallback = Util.colorToRGB(Color3.fromRGB()),

        Value = Value(Color3.new()),
        Tooltip = {
            Text = "The color of the fog."
        }
    },

    {
        Text = "Fog Start",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "FogStart",
        Fallback = 0,

        Value = Value(0),
        Tooltip = {
            Text = "The distance from the camera in which the fog will begin to show."
        }
    },

    {
        Text = "Fog End",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "FogEnd",
        Fallback = 0,

        Value = Value(0),
        Tooltip = {
            Text = "The distance from the camera where the fog will be completely opaque."
        }
    },

    {
        Text = "GeographicLatitude",
        Type = "Number",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "GeographicLatitude",
        Fallback = 0,

        Value = Value(0)
    },

    {
        Text = "Global Shadows",
        Type = "Checkbox",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "GlobalShadows",
        Fallback = false,

        Value = Value(false)
    },

    {
        Text = "Outdoor Ambient",
        Type = "Color",
        Modifiable = Value(true),

        Directory = "Lighting",
        Attribute = "OutdoorAmbient",
        Fallback = Util.colorToRGB(Color3.fromRGB(70, 70, 70)),

        Value = Value(Color3.new())
    },
}
