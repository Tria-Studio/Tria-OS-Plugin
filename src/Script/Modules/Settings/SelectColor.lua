local RunService = game:GetService("RunService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Maid = require(script.Parent.Parent.Other.Maid)
local Signal = require(script.Parent.Parent.Other.Signal)
local UtilModule = require(script.Parent.Parent.UtilFuncs)
local SelectMap = require(script.Parent.Parent.SelectMap)

local UI = UtilModule.UI
local ColorFrame = UI.ColorWheel.Main

local module = {}



function module.GetColorFromString(Color)
	local Text = Color
	local Mult = 1
	local String = false

	Text = string.gsub(Text, " ", "")
	if string.find(Text, "Color3%.%a%a%a%(", 1) then
		Text = string.gsub(Text, 'Color3%.%a%a%a%(', "")
		Mult = 255
	elseif string.find(Text, "Color3.%a%a%a%a%a%a%a%(", 1) then
		Text = string.gsub(Text, 'Color3%.%a%a%a%a%a%a%a%(', "")
	end
	Text = string.gsub(Text, "%)", "")

	local Texts = string.split(Text, ",")
	for _, Thing in pairs(Texts) do
		if not tonumber(Thing) then
			return String and "255, 255, 255" or Color3.new(255, 255, 255)
		end
	end
	return #Texts == 3 and String and string.format("%s, %s, %s", Texts[1], Texts[2], Texts[3]) or Color3.fromRGB(math.min(Texts[1] * Mult, 255), math.min(Texts[2] * Mult, 255), math.min(Texts[3] * Mult, 255)) or Color3.new(255, 255, 255)
end

function module.SelectColor(Frame)
	if not UtilModule.Map then return end
	local Maid = Maid.new()

	local function GetColor(String, Color: string?)
		local Text = Color or Frame.TextBox.Text
		local Mult = 1

		Text = string.gsub(Text, " ", "")
		if string.find(Text, "Color3%.%a%a%a%(", 1) then
			Text = string.gsub(Text, 'Color3%.%a%a%a%(', "")
			Mult = 255
		elseif string.find(Text, "Color3.%a%a%a%a%a%a%a%(", 1) then
			Text = string.gsub(Text, 'Color3%.%a%a%a%a%a%a%a%(', "")
		end
		Text = string.gsub(Text, "%)", "")

		local Texts = string.split(Text, ",")
		for _, Thing in pairs(Texts) do
			if not tonumber(Thing) then
				return String and "255, 255, 255" or Color3.new(255, 255, 255)
			end
		end
		return #Texts == 3 and String and string.format("%s, %s, %s", Texts[1], Texts[2], Texts[3]) or Color3.fromRGB(math.min(Texts[1] * Mult, 255), math.min(Texts[2] * Mult, 255), math.min(Texts[3] * Mult, 255)) or Color3.new(255, 255, 255)
	end

	for _, Button in pairs(UI.Frames.Settings:GetDescendants()) do
		if Button:IsA("TextBox") then
			Button.TextEditable = false
		end
	end

	local CurrentColor = GetColor()
	local SelectedColor = CurrentColor
	local H, S, V = Color3.toHSV(CurrentColor)
	local Angle = -(H * 360) - 90
	ColorFrame.Slider.Pointer.Position = UDim2.new(.5, 0, 1 - V, 0)
	ColorFrame.Wheel.ImageColor3 = Color3.new(V, V, V)
	ColorFrame.Wheel.Pointer.Position = UDim2.new(.5 + math.sin(math.rad(Angle)) * (S / 2), 0, .5 + math.cos(math.rad(Angle)) * (S / 2), 0)
	ColorFrame.Selected.Text = GetColor(true)
	ColorFrame.Selected.TextColor3 = CurrentColor
	ColorFrame.Parent.Visible = true

	local function Close()
		ColorFrame.Parent.Visible = false
		for _, Button in pairs(UI.Frames.Settings:GetDescendants()) do
			if Button:IsA("TextBox") then
				Button.TextEditable = true
			end
		end
	end

	Maid:GiveTask(
		ColorFrame.Exit.MouseButton1Click:Connect(function()
			Close()
			Maid:DoCleaning()
		end))

	Maid:GiveTask(
		ColorFrame.Confirm.MouseButton1Click:Connect(function()
			Close()

			ChangeHistoryService:SetWaypoint("Setting color")
			local Text = string.format("%s, %s, %s", tostring(math.floor(SelectedColor.R * 255 + .5)), tostring(math.floor(SelectedColor.G * 255 + .5)), tostring(math.floor(SelectedColor.B * 255 + .5)))
			Frame.TextBox.Text = Text
			Frame.TextBox.TextColor3 = SelectedColor
			UtilModule.Map.Settings:FindFirstChild(Frame.Parent.Name, true):SetAttribute(Frame.Name, SelectedColor)
			ChangeHistoryService:SetWaypoint("Set color")
			Maid:DoCleaning()
		end))

	Maid:GiveTask(
		ColorFrame.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
			if not ColorFrame.Parent.Visible then
				Maid:DoCleaning()
			end
		end))

	for _, Button in pairs(UI.Frames.Settings:GetDescendants()) do
		if Button.Name == "SelectColor" then
			Button.MouseButton1Click:Connect(function()
				Close()
				Maid:DoCleaning()
			end)
		end
	end
	local function UpdateColor(ignore)
		local Angle = -(H * 360) - 90
		ColorFrame.Slider.Pointer.Position = UDim2.new(.5, 0, 1 - V, 0)
		ColorFrame.Wheel.ImageColor3 = Color3.new(V, V, V)
		ColorFrame.Wheel.Pointer.Position = UDim2.new(.5 + math.sin(math.rad(Angle)) * (S / 2), 0, .5 + math.cos(math.rad(Angle)) * (S / 2), 0)
		ColorFrame.Parent.Visible = true
		script:SetAttribute("_Color", Color3.fromHSV(H, S, V))
		RunService.Heartbeat:Wait()
		local ColorNew = script:GetAttribute("_Color")
		SelectedColor = Color3.fromRGB(math.floor(ColorNew.R * 255 + .5), math.floor(ColorNew.G * 255 + .5), math.floor(ColorNew.B * 255 + .5))
		ColorFrame.Selected.Text = GetColor(true, string.format("%s, %s, %s", tostring(math.floor(ColorNew.R * 255 + .5)), tostring(math.floor(ColorNew.G * 255 + .5)), tostring(math.floor(ColorNew.B * 255 + .5)) ))
		ColorFrame.Selected.TextColor3 = SelectedColor
	end

	local MouseDown = false
	local function UpdateSliderPos()
		local LocalPos = ColorFrame.Slider.AbsolutePosition - UtilModule.Widget:GetRelativeMousePosition()
		local SliderPos = -1 + ((LocalPos.Y + ColorFrame.Slider.AbsoluteSize.Y) / 2 / ColorFrame.Slider.AbsoluteSize.Y + .5) * 2
		ColorFrame.Slider.Pointer.Position = UDim2.new(.5, 0, 1 - SliderPos, 0)
		ColorFrame.Wheel.ImageColor3 = Color3.new(SliderPos, SliderPos, SliderPos)
		V = SliderPos
		UpdateColor()
	end

	local function UpdateWheelPos()
		local LocalPos = ColorFrame.Wheel.AbsolutePosition + ColorFrame.Wheel.AbsoluteSize / 2 - UtilModule.Widget:GetRelativeMousePosition()
		local Angle = math.deg(math.atan2(LocalPos.X, LocalPos.Y))
		local Diameter = math.max(-LocalPos.Magnitude / ColorFrame.Wheel.AbsoluteSize.Y, -.5)

		if -((Angle + 90) / 360) + .5 < 0 then
			H = -((Angle + 90) / 360) + 1.5
		else
			H = -((Angle + 90) / 360) + .5
		end
		S = -Diameter * 2
		ColorFrame.Wheel.Pointer.Position = UDim2.new(.5 + math.sin(math.rad(Angle)) * Diameter, 0, .5 + math.cos(math.rad(Angle)) * Diameter, 0)
		UpdateColor(true)
	end

	Maid:GiveTask(
		ColorFrame.Slider.Button.MouseButton1Down:Connect(function()
			MouseDown = true
			UpdateSliderPos()
		end)
	)
	Maid:GiveTask(
		ColorFrame.Slider.Button.MouseLeave:Connect(function()
			MouseDown = false
		end)
	)
	Maid:GiveTask(
		ColorFrame.Slider.Button.MouseButton1Up:Connect(function()
			MouseDown = false
		end)
	)
	Maid:GiveTask(
		ColorFrame.Slider.Button.MouseMoved:Connect(function()
			if MouseDown then
				UpdateSliderPos()
			end
		end)
	)


	Maid:GiveTask(
		ColorFrame.Wheel.Button.MouseLeave:Connect(function()
			MouseDown = false
		end)
	)
	Maid:GiveTask(
		ColorFrame.Wheel.Button.MouseButton1Up:Connect(function()
			MouseDown = false
		end)
	)
	Maid:GiveTask(
		ColorFrame.Wheel.Button.MouseButton1Down:Connect(function()
			MouseDown = true
			UpdateWheelPos()
		end)
	)
	Maid:GiveTask(
		ColorFrame.Wheel.Button.MouseMoved:Connect(function()
			if MouseDown then
				UpdateWheelPos()
			end
		end)
	)
end

return module
