local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Value = Fusion.Value

local SettingsData = {}

for _, module in ipairs(script.DataModules:GetChildren()) do
    SettingsData[module.Name] = require(module)
end

return SettingsData