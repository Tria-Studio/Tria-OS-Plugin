local Package = script.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local State = Fusion.State
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local OnChange = Fusion.OnChange

local SliderAbsPos = State(UDim2.new())
local SliderAbsSize = State(UDim2.new())
local WheelAbsPos = State(UDim2.new())
local WheelAbsSize = State(UDim2.new())

local circlePointerPos = State(UDim2.new(.5, 0, .5, 0))
local sliderPointerPos = State(UDim2.new(.5, 0, 0, 0))

local hexText = State("")

local mouseDownSlider = State(false)
local mouseDownWheel = State(false)
local visible = State(false)

local chosenColor = State(Color3.fromRGB(255, 255, 255))
local colorChosen = Util.Signal.new()

local ColorWheel = {}

local function UpdateColor()
    local H, S, V = chosenColor:get():ToHSV()
    local Angle = -(H * 360) - 90

    sliderPointerPos:set(UDim2.fromScale(.5, 1 - V))
    circlePointerPos:set(UDim2.fromScale(.5 + math.sin(math.rad(Angle)) * (S / 2), .5 + math.cos(math.rad(Angle)) * (S / 2)))
end

local function GetColorDisplay(data)
    local Text = State("")

    return New "Frame" {
        BackgroundTransparency = 1,
        LayoutOrder = data.LayoutOrder,

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.new(.5, 0, 1, 0),
                Font = Enum.Font.SourceSansSemibold,
                TextColor3 = Theme.SubText.Default,
                Text = string.format("%s:", data.Display),
            },

            New "TextBox" {
                BackgroundColor3 = Theme.InputFieldBackground.Default,
                BorderColor3 = Theme.Border.Default,
                BorderSizePixel = 1,
                Position = UDim2.new(.5, 0, 0, 0),
                Size = UDim2.new(.5, 0, 1, 0),
                TextColor3 = Theme.MainText.Default,
                Text = Computed(data.Computed),

                [OnChange "Text"] = function(newValue: string)
                    Text:set(newValue)
                end,

                [OnEvent "FocusLost"] = function()
                    local NewColor
                    local success = pcall(function()
                        if data.Display == "R" or data.Display == "G" or data.Display == "B" then
                            local textNumber = math.clamp(tonumber(Text:get()) or 0, 0, 255)

                            NewColor = Color3.fromRGB(
                                data.Display == "R" and textNumber or chosenColor:get().R * 255,
                                data.Display == "G" and textNumber or chosenColor:get().G * 255,
                                data.Display == "B" and textNumber or chosenColor:get().B * 255
                            )
                        else
                            local textNumber = math.clamp(tonumber(Text:get()) or 0, 0, 255) / 255
                            local H, S, V = chosenColor:get():ToHSV()

                            NewColor = Color3.fromHSV(
                                data.Display == "H" and textNumber or H,
                                data.Display == "S" and textNumber or S,
                                data.Display == "V" and textNumber or V
                            )
                        end
                    end)

                    NewColor = if success then NewColor else Color3.fromRGB(0, 0, 0)
                    chosenColor:set(NewColor)
                    UpdateColor()
                end
            }
        }
    }
end

local function UpdatePos(type)
    local H, S, V = chosenColor:get():ToHSV()
    local types = {}

    function types.Slider()
        local MousePos = SliderAbsPos:get() - Util.Widget:GetRelativeMousePosition()
        local SliderPos = math.clamp(-1 + ((MousePos.Y + SliderAbsSize:get().Y) / 2 / SliderAbsSize:get().Y + .5) * 2, 0, 1)

        V = if SliderPos > .985 then 1 elseif SliderPos < .015 then 0 else SliderPos
    end

    function types.Wheel()
        local MousePos = WheelAbsPos:get() + WheelAbsSize:get() / 2 - Util.Widget:GetRelativeMousePosition()
		local Angle = math.deg(math.atan2(MousePos.X, MousePos.Y))
		local Diameter = math.max(-MousePos.Magnitude / WheelAbsSize:get().Y, -.5)

        H = -((Angle + 90) / 360) + if -((Angle + 90) / 360) + .5 < 0 then 1.5 else .5
		S = -Diameter * 2
        circlePointerPos:set(UDim2.fromScale(
            .5 + math.sin(math.rad(Angle)) * Diameter, 
            .5 + math.cos(math.rad(Angle)) * Diameter
        ))
    end

    types[type]()
    chosenColor:set(Color3.fromHSV(H, S, V))
    UpdateColor()
end

function ColorWheel:GetUI()
    return New "Frame" {
        BackgroundTransparency = .75,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, -76),
        Position = UDim2.new(0, 0, 0, 52),
        Visible = visible,
    
        [Children] = {
            New "ImageLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 0, 152),
                Position = UDim2.new(.5, 0, .5, 0),
                AnchorPoint = Vector2.new(.5, .5),
                Image = "rbxassetid://8697780388",
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = .5,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(200, 200, 300, 300),
                SliceScale = 0.075,

                [Children] = {
                    Components.Constraints.UIAspectRatio(.77, Enum.AspectType.ScaleWithParentSize),
                    Components.Constraints.UISizeConstraint(Vector2.new(169, 169), Vector2.new(280, 280))
                }
            },
            New "Frame" {
                BackgroundColor3 = Theme.ColorPickerFrame.Default,
                BorderColor3 = Theme.Border.Default,
                BorderSizePixel = 1,
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.new(.5, 0, .5, 0),
                Size = UDim2.new(1, -36, 0, 128),

                [Children] = {
                    Components.Constraints.UIAspectRatio(.75, Enum.AspectType.ScaleWithParentSize),
                    Components.Constraints.UISizeConstraint(Vector2.new(169, 169), Vector2.new(256, 256)),
                    New "ImageLabel" { --// Wheel
                        AnchorPoint = Vector2.new(.5, .5),
                        Position = UDim2.new(0.4, 0, 0.395, 0),
                        Size = UDim2.new(0.7, 0, 0.6, 0),
                        Image = "rbxassetid://6916730280",
                        BackgroundColor3 = Theme.Border.Default,
                        ImageColor3 = Computed(function()
                            if not chosenColor:get() then
                                return Color3.new(1, 1, 1)
                            end

                            local _, _, V = chosenColor:get():ToHSV()
                            return Color3.new(V, V, V)
                        end),

                        [OnChange "AbsolutePosition"] = function(newValue)
                            WheelAbsPos:set(newValue)
                        end,
                        [OnChange "AbsoluteSize"] = function(newValue)
                            WheelAbsSize:set(newValue)
                        end,

                        [Children] = {
                            Components.Constraints.UIAspectRatio(1),
                            Components.Constraints.UICorner(.5, 0),
                            Components.Constraints.UIStroke(2.5, Theme.Border.Default),
                            New "Frame" {
                                BackgroundColor3 = Color3.fromRGB(255, 230, 40),
                                BorderColor3 = Color3.fromRGB(179, 162, 28),
                                BorderSizePixel = 2,
                                Position = circlePointerPos,
                                AnchorPoint = Vector2.new(.5, .5),
                                Size = UDim2.new(0.03, 0, 0.03, 0)
                            },
                            New "TextButton" {
                                Text = "",
                                Size = UDim2.new(3, 0, 2.05, 0),
                                Position = UDim2.new(-1, 0, -1, 0),
                                BackgroundTransparency = 1,
                                ZIndex = 2,

                                [OnEvent "MouseMoved"] = function()
                                    if mouseDownWheel:get() then
                                        UpdatePos("Wheel")
                                    end
                                end,

                                [OnEvent "MouseButton1Up"] = function()
                                    mouseDownWheel:set(false)
                                end,

                                [OnEvent "MouseButton1Down"] = function()
                                    local MousePos = Util.Widget:GetRelativeMousePosition() - WheelAbsPos:get()
                                    local CenterPos = WheelAbsSize:get() / 2

                                    if (MousePos - CenterPos).Magnitude < WheelAbsSize:get().X / 2 then
                                        mouseDownWheel:set(true)
                                        UpdatePos("Wheel")
                                    end
                                end,

                                [OnEvent "MouseLeave"] = function()
                                    mouseDownWheel:set(false)
                                end,
                            }
                        }
                    },
                    Components.MiniTopbar({ --// Top bar
                        Text = "Select Color",
                        Callback = function()
                            chosenColor:set(nil)
                            colorChosen:Fire()
                        end,
                    }),
                    New "Frame" { --// Slider
                        AnchorPoint = Vector2.new(0, .5),
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 2,
                        Position = UDim2.new(0.84, 0, 0.398, 0),
                        Size = UDim2.new(0.063, 0, 0.531, 0),

                        [OnChange "AbsolutePosition"] = function(newValue)
                            SliderAbsPos:set(newValue)
                        end,
                        [OnChange "AbsoluteSize"] = function(newValue)
                            SliderAbsSize:set(newValue)
                        end,

                        [Children] = {
                            Components.Constraints.UIGradient(ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1, 1, 1)), nil, 270),
                            New "Frame" {
                                BackgroundColor3 = Color3.fromRGB(255, 230, 40),
                                BorderColor3 = Color3.fromRGB(179, 162, 28),
                                BorderSizePixel = 2,
                                BorderMode = Enum.BorderMode.Inset,
                                AnchorPoint = Vector2.new(.5, .5),
                                Size = UDim2.new(1, 0, .03, 0),
                                Position = sliderPointerPos,
                            },
                            
                            New "TextButton" {
                                Text = "",
                                Position = UDim2.new(-1, 0, -.07, 0),
                                Size = UDim2.new(3, 0, 1.13, 0),
                                BackgroundTransparency = 1,
                                ZIndex = 2,

                                [OnEvent "MouseMoved"] = function()
                                    if mouseDownSlider:get() then
                                        UpdatePos("Slider")
                                    end
                                end,

                                [OnEvent "MouseButton1Up"] = function()
                                    mouseDownSlider:set(false)
                                end,

                                [OnEvent "MouseButton1Down"] = function()
                                    local MousePos = SliderAbsPos:get() - Util.Widget:GetRelativeMousePosition()
                                    if MousePos.X * -1 > 0 and MousePos.X * -1 < SliderAbsSize:get().Y and MousePos.Y * -1 > 0 and MousePos.Y * -1 < SliderAbsSize:get().Y then
                                        mouseDownSlider:set(true)
                                        UpdatePos("Slider")
                                    end
                                end,

                                [OnEvent "MouseLeave"] = function()
                                    mouseDownSlider:set(false)
                                end,
                            }
                        }
                    },
                    New "Frame" { --// Color Display
                        BackgroundColor3 = chosenColor,
                        BorderSizePixel = 1,
                        BorderColor3 = Theme.Border.Default,
                        Size = UDim2.new(0.256, 0, 0.192, 0),
                        Position = UDim2.new(0.05, 0, 0.698, 0),
                    },
                    New "Frame" { --// Values
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.339, 0, 0.698, 0),
                        Size = UDim2.new(0.641, 0, 0.192, 0),
                        ZIndex = 2,

                        [Children] = {
                            Components.Constraints.UIGridLayout(UDim2.new(0.475, 0, 0.25, 0), UDim2.new(0, 6, 0, 6), Enum.FillDirection.Vertical),
                            GetColorDisplay({
                                LayoutOrder = 1,
                                Display = "R",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    return math.floor(chosenColor:get().R * 255 + .5)
                                end
                            }),
                            GetColorDisplay({
                                LayoutOrder = 2,
                                Display = "G",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    return math.floor(chosenColor:get().G * 255 + .5)
                                end
                            }),
                            GetColorDisplay({
                                LayoutOrder = 3,
                                Display = "B",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    return math.floor(chosenColor:get().B * 255 + .5)
                                end
                            }),
                            GetColorDisplay({
                                LayoutOrder = 4,
                                Display = "H",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    local H, _, _ = chosenColor:get():ToHSV()
                                    return math.floor(H * 255 + .5)
                                end
                            }),
                            GetColorDisplay({
                                LayoutOrder = 5,
                                Display = "S",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    local _, S, _ = chosenColor:get():ToHSV()
                                    return math.floor(S * 255 + .5)
                                end
                            }),
                            GetColorDisplay({
                                LayoutOrder = 6,
                                Display = "V",
                                Computed = function()
                                    if not chosenColor:get() then
                                        return ""
                                    end

                                    local _, _, V = chosenColor:get():ToHSV()
                                    return math.floor(V * 255 + .5)
                                end
                            }),
                        }
                    },
                   Components.TwoOptions({ --// Two buttons
                        Text = "Confirm",
                        Callback = function()
                            colorChosen:Fire()
                        end
                    }, {
                        Text = "Cancel",
                        Callback = function()
                            chosenColor:set(nil)
                            colorChosen:Fire()
                        end
                    }),
                    New "TextBox" { --// Hex input
                        BackgroundColor3 = Theme.InputFieldBackground.Default,
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 1,
                        Position = UDim2.new(.05, 0, .92, 0),
                        Size = UDim2.new(.26, 0, .06, 0),
                        TextColor3 = Theme.MainText.Default,
                        PlaceholderColor3 = Theme.DimmedText.Default,
                        PlaceholderText = "Hex",
                        ZIndex = 2,
                        Text = Computed(function()
                            if not chosenColor:get() then
                                return ""
                            end

                            local Color = chosenColor:get()
                            return string.format("#%s", Color:ToHex())
                        end),

                        [OnChange "Text"] = function(newValue: string)
                            hexText:set(newValue)
                        end,
                        [OnEvent "FocusLost"] = function()
                            local NewColor
                            local success = pcall(function()
                                NewColor = Color3.fromHex(hexText:get())
                            end)

                            NewColor = if success then NewColor else Color3.fromRGB(0, 0, 0)
                            chosenColor:set(NewColor)
                            UpdateColor()
                        end
                    },
                }
            }
        }
    }
end

function ColorWheel:GetColor()
    local Maid = Util.Maid.new()
    Util._Topbar.FreezeFrame:set(true)
    Util.buttonsActive:set(false)
    visible:set(true)

    colorChosen:Wait()
    local Color = chosenColor:get()
   
    Util.buttonsActive:set(true)
    Util._Topbar.FreezeFrame:set(false)
    visible:set(false)
    chosenColor:set(Color3.new(1, 1, 1))
    circlePointerPos:set(UDim2.new(.5, 0, .5, 0))
    sliderPointerPos:set(UDim2.new(.5, 0, 0, 0))
    Maid:DoCleaning()

    return Color
end

return ColorWheel
