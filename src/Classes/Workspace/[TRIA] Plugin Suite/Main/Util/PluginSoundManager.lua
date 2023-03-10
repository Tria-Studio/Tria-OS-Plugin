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

function PluginSoundManager:QueueSound(soundId: number): Sound
	local newSound = Instance.new("Sound")
	newSound.SoundId = "rbxassetid://" .. soundId
	newSound.Looped = false
	newSound.Parent = widget

	return newSound
end

function PluginSoundManager:ClearAllSounds()
	for _, item in ipairs(widget:GetChildren()) do
		if item:IsA("Sound") then
			item:Destroy()
		end
	end
end

return PluginSoundManager