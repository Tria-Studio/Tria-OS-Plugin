local Package = script.Parent.Parent.Parent

local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

return {
    {
        Text = "Mapkit Version",
        Type = "String",
        Modifiable = false,
        Value = Value("1"),
        LayoutOrder = 1
    },

    {
        Text = "Creator (s)",
        Type = "String",
        Modifiable = true,
        Value = Value("grif_0"),
        LayoutOrder = 2
    }
}