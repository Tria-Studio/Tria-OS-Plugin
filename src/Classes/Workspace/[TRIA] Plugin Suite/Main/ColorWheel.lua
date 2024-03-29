local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Components = require(Resources.Components)
local Theme = require(Resources.Themes)

local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out
local ForPairs = Fusion.ForPairs

local sliderData = {
    Position = Value(UDim2.new()),
    Size = Value(UDim2.new())
}

local wheelData = {
    Position = Value(UDim2.new()),
    Size = Value(UDim2.new())
}

local positions = {
    circle = Value(UDim2.fromScale(0.5, 0.5)),
    slider = Value(UDim2.fromScale(0.5, 0)) 
}

local hexText = Value("")

local mouseDownSlider = Value(false)
local mouseDownWheel = Value(false)
local visible = Value(false)

local chosenColor = Value(Color3.fromRGB(255, 255, 255))
local colorChosen = Util.Signal.new()

local ColorWheel = {}

local function updateColor()
    local currentColor = chosenColor:get(false)
    local H, S, V = currentColor:ToHSV()
    local angle = -(H * 360) - 90

    positions.slider:set(UDim2.fromScale(0.5, 1 - V))
    positions.circle:set(UDim2.fromScale(
        0.5 + math.sin(math.rad(angle)) * (S / 2), 
        0.5 + math.cos(math.rad(angle)) * (S / 2))
    )
end

local function getColorDisplay(data: {Display: string, LayoutOrder: number, Computed: () -> ()}): Instance
    local textValue = Value("")

    return New "Frame" {
        BackgroundTransparency = 1,
        Name = data.Display,
        LayoutOrder = data.LayoutOrder,

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.5, 1),
                Font = Enum.Font.SourceSansSemibold,
                TextColor3 = Theme.SubText.Default,
                Text = string.format("%s:", data.Display),
            },

            Components.TextBox {
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromScale(0.5, 1),
                Text = Computed(data.Computed),

                [Out "Text"] = textValue,

                [OnEvent "FocusLost"] = function()
                    local newColor
                    local success = pcall(function()
                        local currentColor = chosenColor:get(false)
                        if data.Display == "R" or data.Display == "G" or data.Display == "B" then
                            local textNumber = math.clamp(tonumber(textValue:get(false)) or 0, 0, 255)
                            newColor = Color3.fromRGB(
                                data.Display == "R" and textNumber or currentColor.R * 255,
                                data.Display == "G" and textNumber or currentColor.G * 255,
                                data.Display == "B" and textNumber or currentColor.B * 255
                            )
                        else
                            local textNumber = math.clamp(tonumber(textValue:get(false)) or 0, 0, 255) / 255
                            local H, S, V = currentColor:ToHSV()
                            newColor = Color3.fromHSV(
                                data.Display == "H" and textNumber or H,
                                data.Display == "S" and textNumber or S,
                                data.Display == "V" and textNumber or V
                            )
                        end
                    end)

                    newColor = if success then newColor else Color3.fromRGB(0, 0, 0)
                    chosenColor:set(newColor)
                    updateColor()
                end
            }
        }
    }
end

local function updatePos(type: string)
    local currentColor = chosenColor:get(false)
    local H, S, V = currentColor:ToHSV()
    local types = {}

    local relativeMousePos = Util.Widget:GetRelativeMousePosition()

    function types.Slider()
        local mousePos = sliderData.Position:get(false) - relativeMousePos
        local sliderPos = math.clamp(-1 + ((mousePos.Y + sliderData.Size:get(false).Y) / 2 / sliderData.Size:get(false).Y + 0.5) * 2, 0, 1)

        V = if sliderPos > 0.985 then 1 elseif sliderPos < 0.015 then 0 else sliderPos
    end

    function types.Wheel()
        local mousePos = wheelData.Position:get(false) + wheelData.Size:get(false) / 2 - relativeMousePos
		local angle = math.deg(math.atan2(mousePos.X, mousePos.Y))
		local diameter = math.max(-mousePos.Magnitude / wheelData.Size:get(false).Y, -0.5)

        H = -((angle + 90) / 360) + if -((angle + 90) / 360) + 0.5 < 0 then 1.5 else 0.5
		S = -diameter * 2

        positions.circle:set(UDim2.fromScale(
            0.5 + math.sin(math.rad(angle)) * diameter, 
            0.5 + math.cos(math.rad(angle)) * diameter
        ))
    end

    types[type]()
    chosenColor:set(Color3.fromHSV(H, S, V))
    updateColor()
end

function ColorWheel:GetUI(): Instance
    return New "Frame" {
        BackgroundTransparency = 0.75,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 0, 1, -76),
        Position = UDim2.fromOffset(0, 52),
        Visible = visible,
        Name = "ColorWheel",
    
        [Children] = {
            New "ImageLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -12, 0, 152),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Image = "rbxassetid://8697780388",
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(200, 200, 300, 300),
                SliceScale = 0.075,

                [Children] = {
                    Components.Constraints.UIAspectRatio(0.77, Enum.AspectType.ScaleWithParentSize),
                    Components.Constraints.UISizeConstraint(Vector2.new(169, 169), Vector2.new(280, 280))
                }
            },
            New "Frame" {
                BackgroundColor3 = Theme.ColorPickerFrame.Default,
                BorderColor3 = Theme.Border.Default,
                BorderSizePixel = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -36, 0, 128),

                [Children] = {
                    Components.Constraints.UIAspectRatio(0.75, Enum.AspectType.ScaleWithParentSize),
                    Components.Constraints.UISizeConstraint(Vector2.new(169, 169), Vector2.new(256, 256)),
                    New "ImageLabel" { --// Wheel
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.4, 0.395),
                        Size = UDim2.fromScale(0.7, 0.6),
                        Image = "rbxassetid://6916730280",
                        BackgroundColor3 = Theme.Border.Default,
                        ImageColor3 = Computed(function(): Color3
                            if not chosenColor:get() then
                                return Color3.new(1, 1, 1)
                            end
                            local _, _, V = chosenColor:get():ToHSV()
                            return Color3.new(V, V, V)
                        end),

                        [Out "AbsolutePosition"] = wheelData.Position,
                        [Out "AbsoluteSize"] = wheelData.Size,

                        [Children] = {
                            Components.Constraints.UIAspectRatio(1),
                            Components.Constraints.UICorner(0.5, 0),
                            Components.Constraints.UIStroke(2.5, Theme.Border.Default),
                            New "Frame" {
                                BackgroundColor3 = Color3.fromRGB(255, 230, 40),
                                BorderColor3 = Color3.fromRGB(179, 162, 28),
                                BorderSizePixel = 2,
                                Position = positions.circle,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Size = UDim2.fromScale(0.03, 0.03)
                            },
                            New "TextButton" {
                                Size = UDim2.fromScale(3, 2.05),
                                Position = UDim2.fromScale(-1, -1),
                                BackgroundTransparency = 1,
                                ZIndex = 9,

                                [OnEvent "MouseMoved"] = function()
                                    if mouseDownWheel:get(false) then
                                        updatePos("Wheel")
                                    end
                                end,

                                [OnEvent "MouseButton1Up"] = function()
                                    mouseDownWheel:set(false)
                                end,

                                [OnEvent "MouseButton1Down"] = function()
                                    local relativeMousePos = Util.Widget:GetRelativeMousePosition()
                                    local mousePos = relativeMousePos - wheelData.Position:get(false)
                                    local centerPos = wheelData.Size:get(false) / 2

                                    if (mousePos - centerPos).Magnitude < wheelData.Size:get(false).X / 2 then
                                        mouseDownWheel:set(true)
                                        updatePos("Wheel")
                                    end
                                end,

                                [OnEvent "MouseLeave"] = function()
                                    mouseDownWheel:set(false)
                                end,
                            }
                        }
                    },
                    Components.MiniTopbar { --// Top bar
                        Text = "Select Color",
                        ZIndex = 10,
                        Callback = function()
                            chosenColor:set(nil)
                            colorChosen:Fire()
                        end,
                    },
                    New "Frame" { --// Slider
                        AnchorPoint = Vector2.new(0, 0.5),
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 2,
                        Position = UDim2.fromScale(0.84, 0.398),
                        Size = UDim2.fromScale(0.063, 0.531),

                        [Out "AbsolutePosition"] = sliderData.Position,
                        [Out "AbsoluteSize"] = sliderData.Size,

                        [Children] = {
                            Components.Constraints.UIGradient(Computed(function(): ColorSequence
                                local H, S, V = (chosenColor:get() or Color3.new()):ToHSV()
                                return ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(H, S, 1))
                            end), nil, 270),
                            New "Frame" {
                                BackgroundColor3 = Color3.fromRGB(255, 230, 40),
                                BorderColor3 = Color3.fromRGB(179, 162, 28),
                                BorderSizePixel = 2,
                                BorderMode = Enum.BorderMode.Inset,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Size = UDim2.fromScale(1, 0.03),
                                Position = positions.slider,
                            },
                            
                            New "TextButton" {
                                Position = UDim2.fromScale(-1, -0.07),
                                Size = UDim2.fromScale(3, 1.13),
                                BackgroundTransparency = 1,
                                ZIndex = 9,

                                [OnEvent "MouseMoved"] = function()
                                    if mouseDownSlider:get(false) then
                                        updatePos("Slider")
                                    end
                                end,

                                [OnEvent "MouseButton1Up"] = function()
                                    mouseDownSlider:set(false)
                                end,

                                [OnEvent "MouseButton1Down"] = function()
                                    local relativeMousePos = Util.Widget:GetRelativeMousePosition()
                                    local mousePos = sliderData.Position:get(false) - relativeMousePos
                                    if mousePos.X * -1 > 0 and mousePos.X * -1 < sliderData.Size:get(false).Y and mousePos.Y * -1 > 0 and mousePos.Y * -1 < sliderData.Size:get(false).Y then
                                        mouseDownSlider:set(true)
                                        updatePos("Slider")
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
                        Size = UDim2.fromScale(0.256, 0.192),
                        Position = UDim2.fromScale(0.05, 0.698),
                    },
                    New "Frame" { --// Values
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.339, 0.698),
                        Size = UDim2.fromScale(0.641, 0.192),
                        ZIndex = 9,

                        [Children] = {
                            Components.Constraints.UIGridLayout(UDim2.fromScale(0.475, 0.25), UDim2.fromOffset(6, 6), Enum.FillDirection.Vertical),
                            ForPairs({"R", "G", "B"}, function(index: number, value: string): (number, Instance)
                                return index, getColorDisplay {
                                    LayoutOrder = value == "R" and 1 or value == "G" and 2 or 3,
                                    Display = value,
                                    Computed = function()
                                        if not chosenColor:get() then
                                            return ""
                                        end
                                        return math.floor(chosenColor:get()[value] * 255 + 0.5)
                                    end
                                }
                            end, Fusion.cleanup),
                            ForPairs({"H", "S", "V"}, function(index: number, value: string): (number, Instance)
                                return index, getColorDisplay {
                                    LayoutOrder = value == "H" and 4 or value == "S" and 5 or 6,
                                    Display = value,
                                    Computed = function()
                                        if not chosenColor:get() then
                                            return ""
                                        end
                                        return math.floor(({chosenColor:get():ToHSV()})[index] * 255 + 0.5)
                                    end
                                }
                            end, Fusion.cleanup)
                        }
                    },

                   Hydrate(Components.TwoOptions({ --// Two buttons
                        Text = "Confirm",
                        Callback = function()
                            colorChosen:Fire()
                        end,
                        BackgroundColor3 = Theme.Button.Selected
                    }, {
                        Text = "Cancel",
                        Callback = function()
                            chosenColor:set(nil)
                            colorChosen:Fire()
                        end,
                        BackgroundColor3 = Theme.Button.Default
                    })) {
                        AnchorPoint = Vector2.new(0, 1)
                    },

                    Components.TextBox { --// Hex input
                        Position = UDim2.fromScale(0.05, 0.92),
                        Size = UDim2.fromScale(0.26, 0.06),
                        TextColor3 = Theme.MainText.Default,
                        PlaceholderText = "Hex",
                        ZIndex = 9,
                        Text = Computed(function(): string
                            if not chosenColor:get() then
                                return ""
                            end
                            return string.format("#%s", chosenColor:get():ToHex())
                        end),

                        [Out "Text"] = hexText,
                        [OnEvent "FocusLost"] = function()
                            local newColor
                            local success = pcall(function()
                                newColor = Color3.fromHex(hexText:get(false))
                            end)

                            newColor = if success then newColor else Color3.fromRGB(0, 0, 0)
                            chosenColor:set(newColor)
                            updateColor()
                        end
                    },
                }
            }
        }
    }
end

function ColorWheel:GetColor(startingColor: Color3?): Color3
    local Maid = Util.Maid.new()
    Util._showArrows:set(false)
    Util._Topbar.FreezeFrame:set(true)
    Util:ToggleInterface(false)
    visible:set(true)
    chosenColor:set(startingColor)
    updateColor()
    colorChosen:Wait()

    local newColor = chosenColor:get(false)
    
    Util:ToggleInterface(true)
    Util._Topbar.FreezeFrame:set(false)
    visible:set(false)
    chosenColor:set(Color3.new(1, 1, 1))
    positions.circle:set(UDim2.fromScale(0.5, 0.5))
    positions.slider:set(UDim2.fromScale(0.5, 0))
    Util._showArrows:set(true)
    Maid:DoCleaning()

    return newColor
end

return ColorWheel
