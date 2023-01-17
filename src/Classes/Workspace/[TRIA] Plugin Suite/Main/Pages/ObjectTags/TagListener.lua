local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components )
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(name, data)
    local tagSelected = Value(false)
    local tagEnabled = Value(false)

    return New "Frame" {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Dropdown.Default,
        LayoutOrder = data.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 4),
        Name = name,

        [Children] = New "Frame" {
            BackgroundColor3 = Theme.Button.Default,    
            Size = UDim2.new(1, 0, 0, 25),
            AutomaticSize = Enum.AutomaticSize.Y,

            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil),
                New "TextButton" { --// Button
                    BackgroundColor3 = Theme.Button.Default,
                    Position = UDim2.fromOffset(-56, 0),
                    Size = UDim2.new(1, 56, 0, 25),
                    Font = Enum.Font.SourceSansBold,
                    Text = data.DisplayText,
                    TextColor3 = Theme.MainText.Default,
                    TextXAlignment = Enum.TextXAlignment.Left,

                    AutoButtonColor = Computed(Util.buttonActiveFunc),
                    Active = Computed(Util.buttonActiveFunc),

                    [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil)
                },
                New "ImageLabel" { --// Checkbox
                    BackgroundTransparency = 0.25,
                    BackgroundColor3 = Theme.CheckedFieldBackground.Default,
                    BorderColor3 = Theme.CheckedFieldBorder.Default,
                    BorderSizePixel = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromOffset(-30, 2),
                    Size = UDim2.fromOffset(20, 20),
                    Image = "rbxassetid://6031094667",
                    ImageColor3 = Theme.CheckedFieldIndicator.Default,
                    ImageTransparency = Computed(function()
                        return tagEnabled:get() and 0 or 1
                    end)
                },
                New "ImageLabel" { --// Icon
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.fromOffset(-6, 2),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Image = data.DisplayIcon,
                },
                Computed(function()
                    if #data.metadata == 0 then
                        return
                    end

                    return New "Frame" { --// Metadata
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Theme.MainBackground.Default,
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 1,
                        BorderMode = Enum.BorderMode.Inset,
                        Position = UDim2.new(0, -56, 0, 24),
                        Size = UDim2.new(1, 56, 0, 10),
                        Visible = true,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            New "TextLabel" {
                                Text = "Metadata",
                                BackgroundColor3 = Theme.MainBackground.Default,
                                BorderColor3 = Theme.Border.Default,
                                BorderSizePixel = 1,
                                Size = UDim2.new(1, 0, 0, 22),
                                Font = Enum.Font.SourceSansSemibold,
                                TextColor3 = Theme.BrightText.Default,
                                TextSize = 16
                            },
                            New "Frame" {
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Size = UDim2.new(1, 0, 0, 24),
                                BackgroundTransparency = 1,
                                LayoutOrder = 2,

                                [Children] = ForValues(data.metadata, function(metadataType)
                                    return New "TextLabel" {
                                        BackgroundColor3 = Theme.ScrollBarBackground.Default,
                                        BorderColor3 = Theme.Border.Default,
                                        BorderSizePixel = 1,
                                        Size = UDim2.new(metadataType.isFullSize and 1 or .5, 0, 0, 22),
                                        Position = UDim2.new(metadataType.location % 2 == 1 and 0 or .5, 0, 0, (math.ceil(metadataType.location / 2) - 1) * 22),
                                        
                                        Text = metadataType.data.displayName .. ":",
                                        TextColor3 = Theme.MainText.Default,
                                        Font = Enum.Font.SourceSansSemibold,
                                        TextSize = 15,
                                        TextXAlignment = Enum.TextXAlignment.Left,

                                        [Children] = {
                                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8)),
                                            -- Components.TextBox({ --// i forgot that not only number types exist lol
                                            --     Size = metadataType.data.textBoxSize,
                                            --     AnchorPoint = Vector2.new(1, 0),
                                            --     Position = UDim2.new(1, -4, .5, 0),
                                            -- })
                                        }
                                    }
                                end, Fusion.cleanup)
                            }
                        }
                    }
                end, Fusion.cleanup)
            }
        }
    }
end
