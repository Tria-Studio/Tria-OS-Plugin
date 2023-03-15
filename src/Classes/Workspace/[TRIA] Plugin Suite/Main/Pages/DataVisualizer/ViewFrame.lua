local Package = script.Parent.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local ForValues = Fusion.ForValues


return function(name: string, data: PublicTypes.Dictionary)
    local checkState = Value(false)

    return New "Frame" {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.ScrollBarBackground.Default,
        LayoutOrder = data.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 4),
        Name = name,

        [Children] = {
            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil),
            New "TextButton" { --// Button
                AutoButtonColor = Computed(function(): boolean
                    local interfaceActive = Util.interfaceActive:get()
                    return if Util.dropdownActive:get() then false else interfaceActive
                end),
                Active = Util.interfaceActive,
                BackgroundColor3 = Theme.Button.Default,
                Position = UDim2.fromOffset(-56, 0),
                Size = UDim2.new(1, 56, 0, 25),
                Font = Enum.Font.SourceSansBold,
                Text = data.DisplayText,
                TextColor3 = Theme.MainText.Default,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil)
            },
            Components.Checkbox(20, UDim2.fromOffset(-30, 2), Vector2.new(1, 0), checkState),
            New "ImageLabel" { --// Icon
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.fromOffset(-6, 2),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Image = data.DisplayIcon,
            },
            Components.TooltipImage {
                Header = if data.Tooltip.Text == "" then nil else data.Tooltip.Header,
                Tooltip = if data.Tooltip.Text == "" then nil else data.Tooltip.Text,
                Position = UDim2.new(1, -4, 0, 4)
            },
            New "Frame" {
                Position = UDim2.new(0, -56, 0, 25),
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 56, 0, 0),
                BackgroundTransparency = 1,
                LayoutOrder = 2,

                [Children] = {
                    Components.Constraints.UIListLayout(),
                    Components.Spacer(data.SingleOption, 0, 2, 1, Theme.ScrollBarBackground.Default),
                    New "TextLabel" {
                        Text = data.SubText,
                        Visible = #data.ViewOptions > 0,
                        BackgroundColor3 = Theme.MainBackground.Default,
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.SourceSansSemibold,
                        TextColor3 = Theme.BrightText.Default,
                        TextSize = 16
                    },
                    ForValues(data.ViewOptions, function(metadata: PublicTypes.Dictionary): Instance
                        local dataValue = Value(false)
                        return New "TextButton" {
                            BackgroundColor3 = Theme.ScrollBarBackground.Default,
                            BorderColor3 = Theme.Border.Default,
                            BorderSizePixel = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                            LayoutOrder = metadata.LayoutOrder + 1,
                            Text = " " .. metadata.Name,
                            TextColor3 = Theme.MainText.Default,
                            Font = Enum.Font.SourceSansSemibold,
                            TextSize = 15,
                            TextXAlignment = Enum.TextXAlignment.Left,

                            [Children] = {
                                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 44)),
                                Components.Checkbox(18, UDim2.fromOffset(-24, 2), Vector2.new(1, 0), dataValue),
                                New "ImageLabel" { --// Icon
                                    Size = UDim2.fromOffset(18, 18),
                                    Position = UDim2.fromOffset(-2, 2),
                                    BackgroundTransparency = 1,
                                    AnchorPoint = Vector2.new(1, 0),
                                    Image = metadata.DisplayIcon,
                                    ImageColor3 = Theme.MainText.Default
                                },
                            }
                        }
                    end),
                    Components.Spacer(data.SingleOption, #data.ViewOptions + 2, 2, 1, Theme.ScrollBarBackground.Default),   
                }
            }
        }
    }
end
