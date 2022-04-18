local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ColorCorrection: ColorCorrectionEffect = Lighting:FindFirstChild("_qwertyuiopasdfghjklzxcvbnm")



ColorCorrection.Enabled = true
ColorCorrection.TintColor = script:GetAttribute("TintColor")

local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(.075), {Brightness = .75, Saturation = -1})
Tween:Play()
Tween.Completed:Wait()

local Tween = TweenService:Create(ColorCorrection, TweenInfo.new(.5), {Brightness = 0, Saturation = -0})
Tween:Play()
Tween.Completed:Wait()

ColorCorrection.Enabled = false
script:Destroy()