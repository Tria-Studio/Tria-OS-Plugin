local PluginSoundManager = {}

local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
local widget = plugin:CreateDockWidgetPluginGui("SoundPlayer", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false, true,
	10, 10,
	10, 10
))
widget.Name = "TRIA_soundManager"
widget.Title = "PluginSoundManager"

local soundFrame = Instance.new("Frame")
soundFrame.Parent = widget

function PluginSoundManager:CreateSound(): Sound
	local newSound = Instance.new("Sound")
	newSound.Looped = false
	newSound.Parent = soundFrame

	return newSound
end

return PluginSoundManager
