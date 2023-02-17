local Package = script.Parent.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Value = Fusion.Value

local Settings = {}
Settings.enabled = true

Settings.runsIn = {
	MapScript = true,
	LocalMapScript = true,
	EffectScript = true
}

Settings.runsInAnyScript = Value(true)

return Settings