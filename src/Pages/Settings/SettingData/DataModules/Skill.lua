-- Copyright (C) 2026 TRIA
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
-- If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

local Package = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Package.Packages.Fusion)

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
