local SettingTypes = {}

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)
local Util = require(Package.Util)
local ColorWheel = require(Package.Colorwheel)

local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local OnChange = Fusion.OnChange
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Ref = Fusion.Ref
local Value = Fusion.Value

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

function InputBox(data)
    return function (props)
        return Hydrate(Components.TextBox {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 1,
            FontFace = Font.new("SourceSansPro"),
            TextColor3 = if data.Modifiable then Color3.fromRGB(170, 170, 170) else Color3.fromRGB(102, 102, 102),
            TextXAlignment = Enum.TextXAlignment.Left,
    
            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8), nil)
            },
        })(props)
    end
end

function parseColor3Text(str: string): string
    local multiplier = 1

    str = string.gsub(str, " ", "")
    if string.find(str, "Color3%.%a%a%a%(", 1) then
        str = string.gsub(str, 'Color3%.%a%a%a%(', "")
        multiplier = 255
    elseif string.find(str, "Color3.%a%a%a%a%a%a%a%(", 1) then
        str = string.gsub(str, 'Color3%.%a%a%a%a%a%a%a%(', "")
    end
    str = string.gsub(str, "%)", "")

    local split = string.split(str, ",")
    for _, v in pairs(split) do
        if not tonumber(v) then
            return false, nil
        end
    end

    if #split < 3 then
        return false, nil
    end

    local r, g, b = 
        math.min(math.floor(split[1] * multiplier + 0.5), 255), 
        math.min(math.floor(split[2] * multiplier + 0.5), 255), 
        math.min(math.floor(split[3] * multiplier + 0.5), 255)

    local newColor = Color3.fromRGB(r, g, b)
    return true, newColor
end

function SettingTypes.String(data): Instance
    local inputBox
    return Hydrate(BaseSettingButton(data)) {
        [Children] = InputBox(data){
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            Text = data.Value,

            [Ref] = inputBox,
            [OnEvent "FocusLost"] = function()
                print(inputBox)
                local inputBoxObject = inputBox:get()
                if data.Modifiable then
                    local newText = inputBoxObject.Text
                    data.Value:set(newText)
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                else
                    inputBoxObject.Text = data.Value:get(false)
                end
            end
        }
    }
end

function SettingTypes.Checkbox(data)
    local images = {
        checked = "http://www.roblox.com/asset/?id=6031094667",
        unchecked = "http://www.roblox.com/asset/?id=6031068420"
    }

    return Hydrate(BaseSettingButton(data)) {
        [Children] = Components.ImageButton {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(34, 34, 34),
            BorderMode = Enum.BorderMode.Outline,
            BorderSizePixel = 1,

            Position = UDim2.new(0.45, 8, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            Image = Computed(function()
                return images[data.Value:get() == true and "checked" or "unchecked"]
            end),
            ImageColor3 = Computed(function()
                return data.Value:get() == true and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end),

            [OnEvent "Activated"] = function()
                if data.Modifiable then
                    data.Value:set(not data.Value:get(false))
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                end
            end
        }
    }
end

function SettingTypes.Color(data)
    local inputBox = Value()

    return Hydrate(BaseSettingButton(data)) {
        [Children] = {
            Components.TextButton {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = data.Value,
                BackgroundTransparency = 0,
                BorderColor3 = Color3.fromRGB(34, 34, 34),
                BorderMode = Enum.BorderMode.Outline,
                BorderSizePixel = 1,
                Name = "Color",
                Position = UDim2.new(0.45, 8, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),

                [OnEvent "Activated"] = function()
                    if not data.Modifiable then
                        return
                    end

                    local chosenColor = ColorWheel:GetColor()
                    if chosenColor == nil then
                        return
                    end

                    data.Value:set(chosenColor)
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                end
            },

            New "Frame" {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(34, 34, 34),
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = UDim2.new(0.45, 24, 0, 0),
                Size = UDim2.new(0, 1, 1, 0)
            },

            InputBox(data){
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0.55, -28, 1, 0),
                Text = Computed(function()
                    return Util.colorToRGB(data.Value:get())
                end),

                [Ref] = inputBox,
                [OnEvent "FocusLost"] = function()
                    if data.Modifiable then
                        local inputBoxObject = inputBox:get()
                        local currentText = inputBoxObject.Text
                        local didParse, parsedColor = parseColor3Text(currentText)
                        if not didParse then
                            inputBoxObject.Text = data.Value:get()
                        else
                            data.Value:set(parsedColor)
                            inputBoxObject.Text = Util.colorToRGB(parsedColor)
                            Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                        end
                    else
                        inputBoxObject.Text = data.Value:get()
                    end
                end
            }
        }
    }
end

function SettingTypes.Time()
    
end

return SettingTypes