local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local Data = {
	Directory = "Materials",

	Dynamic = false,
	Items = {},
}

Data.Items = {
    {
		Text = "Use2022Materials",
		Type = "Checkbox",
		Attribute = "Use2022Materials",
		Directory = "Materials",
        ApplyType = "Attribute",
        
        Fallback = false,
		Value = Value(false),
		Tooltip = {
			Text = [[Using Material Variants, TRIA.os does the best it can to replicate the appearance of the new materials.
            
NOTE: Due to engine limitations, Corroded Metal and Glass still use the old textures, aswell as a slight discoloration between the new materials and the emulated new materials. This is due to the way Roblox calculates these Material Variants.]] 
		},
	},
}

return Data
