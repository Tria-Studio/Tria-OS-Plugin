-- Copyright (C) 2026 TRIA
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
-- If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local SettingsData = {}

for _, module in ipairs(script.DataModules:GetChildren()) do
    SettingsData[module.Name] = require(module)
end

return SettingsData