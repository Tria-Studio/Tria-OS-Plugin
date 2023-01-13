local Fusion = require(script.Parent.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Parent.Resources.Components )
local Util = require(script.Parent.Parent.Parent.Util)

local New = Fusion.New
local Children = Fusion.Children
local State = Fusion.State
local Computed = Fusion.Computed



return function(name, data)
    local tagEnabled = State(false)

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
                    Position = UDim2.new(0, -56, 0, 0),
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
                    BackgroundTransparency = .25,
                    BackgroundColor3 = Theme.CheckedFieldBackground.Default,
                    BorderColor3 = Theme.CheckedFieldBorder.Default,
                    BorderSizePixel = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(0, -30, 0, 2),
                    Size = UDim2.new(0, 20, 0, 20),
                    Image = "rbxassetid://6031094667",
                    ImageColor3 = Theme.CheckedFieldIndicator.Default,
                    ImageTransparency = Computed(function()
                        return tagEnabled:get() and 0 or 1
                    end)
                },
                New "ImageLabel" { --// Icon
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, -6, 0, 2),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Image = data.DisplayIcon,
                },
            }
        }
    }
end
