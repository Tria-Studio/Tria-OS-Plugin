-- if game:GetService("RunService"):IsStudio() then return end
--[[ 
	Leave this script parented to the EasyTP ModuleScript otherwise it may break. 
	Edit the script at your own risk of breaking it.
]]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ColorCorrection: ColorCorrectionEffect = Lighting:FindFirstChild("_qwertyuiopasdfghjklzxcvbnm")
ColorCorrection.Enabled = true
ColorCorrection.TintColor = script:GetAttribute("FlashColor")

local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(.075), {Brightness = .75, Saturation = -1})
Tween:Play()
Tween.Completed:Wait()

local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(script:GetAttribute("FlashDuration") or 0.75), {Brightness = 0, Saturation = -0})
Tween:Play()
Tween.Completed:Wait()

ColorCorrection.Enabled = false
script:Destroy()
