local SettingTypes = {}

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)

local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate

function BaseSettingButton(data)
    return Components.TextButton {
        BackgroundColor3 = Color3.fromRGB(46, 46, 46), -- Can't find out what this is.
        BackgroundTransparency = 0,
        BorderColor3 = Theme.Border.Default,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        LayoutOrder = data.LayoutOrder,
        Name = data.Text,
        Size = UDim2.new(1, 0, 0, 20),
        FontFace = Font.new("SourceSansPro"),
        Text = data.Text,
        TextColor3 = if data.Modifiable then Color3.fromRGB(170, 170, 170) else Color3.fromRGB(102, 102, 102),
        TextXAlignment = Enum.TextXAlignment.Left,

        [Children] = {
            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 20), nil),
            New "Frame" {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(34, 34, 34),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0.45, 0),
                Size = UDim2.new(0, 1, 1, 0)
            },
            New "ImageButton" {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Color3.fromRGB(46, 46, 46),
                BackgroundTransparency = 0,
                BorderColor3 = Color3.fromRGB(34, 34, 34),
                BorderMode = Enum.BorderMode.Inset,
                BorderSizePixel = 1,
                Position = UDim2.new(0, -2, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                Image = "http://www.roblox.com/asset/?id=6034281900",
                ImageColor3 = Color3.fromRGB(170, 170, 170)
            }
        }
    }
end

function SettingTypes.String(data): Instance
    return Hydrate(BaseSettingButton(data)) {
        [Children] = Components.TextBox {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 1,
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            FontFace = Font.new("SourceSansPro"),
            Text = data.Value,
            TextColor3 = if data.Modifiable then Color3.fromRGB(170, 170, 170) else Color3.fromRGB(102, 102, 102),
            TextXAlignment = Enum.TextXAlignment.Left,

            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8), nil)
            }
        }
    }
end

function SettingTypes.Checkbox()
    
end

return SettingTypes