local PluginSoundManager = {}

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
local widget = plugin:CreateDockWidgetPluginGui("SoundPlayer", DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false, true,
	10, 10,
	10, 10
))
widget.Name = "PluginSoundManager"
widget.Title = "PluginSoundManager"

local currentlyPlaying
local currentTween = nil

function PluginSoundManager:PlaySound(sound: Sound)
	sound.Volume = 0
	sound.Parent = widget

	if currentTween then
		currentTween:Cancel()
	end
	currentTween = TweenService:Create(sound, TweenInfo.new(1, Enum.EasingStyle.Quad), {Volume = 1})
	currentTween:Play()
end

function PluginSoundManager:StopSound()
	if not currentlyPlaying then
		return
	end
	if currentTween then
		currentTween:Cancel()
	end
	currentTween = TweenService:Create(currentlyPlaying, TweenInfo.new(1, Enum.EasingStyle.Quad), {Volume = 0})
	currentTween:Play()
	currentTween.Completed:Connect(function()
		currentlyPlaying:Destroy()
	end)
	currentlyPlaying = nil
end

function PluginSoundManager:GetCurrentSound(): Sound?
	return currentlyPlaying
end

return PluginSoundManager