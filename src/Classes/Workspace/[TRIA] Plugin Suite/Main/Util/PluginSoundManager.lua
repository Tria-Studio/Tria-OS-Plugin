local PluginSoundManager = {}

local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
local widget = plugin:CreateDockWidgetPluginGui("SoundPlayer", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false, true,
	10, 10,
	10, 10
))
widget.Name = "PluginSoundManager"
widget.Title = "PluginSoundManager"

function PluginSoundManager:CreateSound(): Sound
	local newSound = Instance.new("Sound")
	newSound.Looped = false
	newSound.Parent = widget

	return newSound
end

return PluginSoundManager