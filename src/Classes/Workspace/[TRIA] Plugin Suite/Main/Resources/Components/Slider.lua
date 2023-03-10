local Package = script.Parent.Parent.Parent
local Resources = Package.Resources

local PublicTypes = require(Package.PublicTypes)
local Constraints = require(script.Parent.Constraints)
local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Ref = Fusion.Ref
local Out = Fusion.Out

return function (data: PublicTypes.Dictionary, holder: Instance): {Instance}
    local absolutePosition = Value(Vector2.zero)
    local absoluteSize = Value(Vector2.zero)
    local sliderButton = Value()

    local text = Value("")

    local min = data.Min
    local max = data.Max

    local sliderPosition = Computed(function()
        return UDim2.fromScale((data.Value:get() - min:get()) / (max:get() - min:get()), 0.5)
    end)

    local backFrameSize = Computed(function()
        return UDim2.fromScale(data.Value:get() / max:get(), 0.8)
    end)

    local function updateSliderValue(mousePos: Vector2)
        local percent = 1 - math.clamp(-1 + ((mousePos.X + absoluteSize:get(false).X) / 2 / absoluteSize:get(false).X + 0.5) * 2, 0, 1)
    
        data.Value:set(math.clamp(
            Util.round(Util.lerp(min:get(false), max:get(false), percent), data.Increment), 
            min:get(false), 
            max:get(false)
        ))

        if data.OnChange then
            data.OnChange(data.Value:get(false))
        end
    end

    local sliderFrame = New "ImageButton" {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = data.Position,
        Size = data.Size,
        BackgroundColor3 = Theme.Mid.Default,
        ImageTransparency = 1,
        Visible = if data.Visible then data.Visible else true,

        [Out "AbsolutePosition"] = absolutePosition,
        [Out "AbsoluteSize"] = absoluteSize,

        [OnEvent "MouseButton1Down"] = function()
            local mousePos = absolutePosition:get(false) - Util.Widget:GetRelativeMousePosition()
            Util._Slider.isUsingSlider:set(true)
            updateSliderValue(mousePos)
            Util._Slider.isUsingSlider:set(false)
        end,

        [OnEvent "MouseMoved"] = function()
            if Util._Slider.isUsingSlider:get(false) and Util._Slider.currentSlider:get(false) == sliderButton:get(false) then
                local mousePos = absolutePosition:get(false) - Util.Widget:GetRelativeMousePosition()
                updateSliderValue(mousePos)
            end
        end,

        [Children] = {
            New "ImageButton" {
                ImageTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Theme.DimmedText.Default,
                Position = sliderPosition,

                Size = UDim2.fromScale(1.75, 1.75),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ZIndex = 2,
                AutoButtonColor = true,

                [Ref] = sliderButton,

                [Children] = {
                    Constraints.UICorner(1, 0),
                    Constraints.UIStroke(1, Theme.Border.Default, Enum.ApplyStrokeMode.Border),
                    New "ImageButton" {
                        Size = UDim2.new(100, 0, 100, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        BackgroundTransparency = 1,

                        Visible = Util._Slider.isUsingSlider,

                        [OnEvent "MouseButton1Up"] = function()
                            Util._Slider.isUsingSlider:set(false)
                            Util._Slider.currentSlider:set(nil)
                        end,

                        [OnEvent "MouseMoved"] = function()
                            if Util._Slider.isUsingSlider:get(false) and Util._Slider.currentSlider:get(false) == sliderButton:get(false) then
                                local mousePos = absolutePosition:get(false) - Util.Widget:GetRelativeMousePosition()
                                updateSliderValue(mousePos)
                            end
                        end,
                    }
                },

                [OnEvent "MouseButton1Up"] = function()
                    Util._Slider.isUsingSlider:set(false)
                    Util._Slider.currentSlider:set(nil)
                end,

                [OnEvent "MouseButton1Down"] = function()
                    Util._Slider.isUsingSlider:set(true)
                    Util._Slider.currentSlider:set(sliderButton:get(false))
                end
            },

            New "Frame" {
                BackgroundColor3 = Theme.MainButton.Default,
                Size = backFrameSize,

                [Children] = Constraints.UICorner(0, 8)
            },

            Constraints.UICorner(0, 8)
        },
    }

    return sliderFrame
end
