local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components )
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(name, data)
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
            }
        }
    }
end