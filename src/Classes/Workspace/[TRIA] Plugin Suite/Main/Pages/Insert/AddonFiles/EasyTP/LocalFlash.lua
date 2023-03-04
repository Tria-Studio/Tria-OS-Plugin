-- if game:GetService("RunService"):IsStudio() then return end
--[[ 
	Leave this script parented to the EasyTP ModuleScript otherwise it may break. 
	Edit the script at your own risk of breaking it.
]]

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local colorCorrection = Lighting:FindFirstChild("_qwertyuiopasdfghjklzxcvbnm")
colorCorrection.Enabled = true
colorCorrection.TintColor = script:GetAttribute("FlashColor")

local tween = TweenService:Create(colorCorrection, TweenInfo.new(.075), {Brightness = .75, Saturation = -1})
tween:Play()
tween.Completed:Wait()

local tween = TweenService:Create(colorCorrection, TweenInfo.new(script:GetAttribute("FlashDuration") or 0.75), {Brightness = 0, Saturation = -0})
tween:Play()
tween.Completed:Wait()

colorCorrection.Enabled = false
script:Destroy()
