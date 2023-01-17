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
    return New "Frame" {
        BackgroundColor3 = Color3.fromRGB(46, 46, 46), -- Can't find out what this is.
        BackgroundTransparency = 0,
        BorderColor3 = Theme.Border.Default,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        Name = data.Text or data.Name,
        Size = UDim2.new(1, 0, 0, 20),
        
        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.45, 1),
                FontFace = Font.new("SourceSansPro"),
                Text = data.Text,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextColor3 = if data.Modifiable:get() then Color3.fromRGB(170, 170, 170) else Color3.fromRGB(102, 102, 102),
                TextXAlignment = Enum.TextXAlignment.Left,
            },

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
                    Active = Computed(Util.buttonActiveFunc),
                    AutoButtonColor = Computed(Util.buttonActiveFunc),

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
    }
end

function InputBox(data)
    return function (props)
        return Hydrate(Components.TextBox {
            Active = Computed(Util.buttonActiveFunc),
            TextEditable = Computed(Util.buttonActiveFunc),

            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 1,
            FontFace = Font.new("SourceSansPro"),
            TextColor3 = if data.Modifiable:get() then Color3.fromRGB(170, 170, 170) else Color3.fromRGB(102, 102, 102),
            TextXAlignment = Enum.TextXAlignment.Left,
    
            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8), nil)
            },
        })(props)
    end
end

function SettingTypes.String(data): Instance
    local inputBox = Value()
    return Hydrate(BaseSettingButton(data)) {
        [Children] = InputBox(data){
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            Text = data.Value,
            TextEditable = data.Modifiable,

            [Ref] = inputBox,
            [OnEvent "FocusLost"] = function()
                if data.Modifiable:get() then
                    local inputBoxObject = inputBox:get()
                    local currentText = inputBoxObject.Text

                    data.Value:set(currentText)
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
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
            Active = Computed(Util.buttonActiveFunc),
            AutoButtonColor = Computed(Util.buttonActiveFunc),

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
                if data.Modifiable:get() then
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
                Active = Computed(Util.buttonActiveFunc),
                AutoButtonColor = Computed(Util.buttonActiveFunc),

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
                    if not data.Modifiable:get() then
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
                Position = UDim2.new(0.45, 28, 0, 0),
                Size = UDim2.new(0, 1, 1, 0)
            },

            InputBox(data){
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0.55, -28, 1, 0),
                Text = Computed(function()
                    return Util.colorToRGB(data.Value:get())
                end),
                TextEditable = data.Modifiable,

                [Ref] = inputBox,
                [OnEvent "FocusLost"] = function()
                    if data.Modifiable:get() then
                        local inputBoxObject = inputBox:get()
                        local currentText = inputBoxObject.Text
                        local didParse, parsedColor = Util.parseColor3Text(currentText)
                        if not didParse then
                            inputBoxObject.Text = data.Value:get()
                        else
                            data.Value:set(parsedColor)
                            inputBoxObject.Text = Util.colorToRGB(parsedColor)
                            Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                        end
                    end
                end
            }
        }
    }
end

function SettingTypes.Time(data)
    local inputBox = Value()
    return Hydrate(BaseSettingButton(data)) {
        [Children] = InputBox(data){
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            Text = data.Value,
            TextEditable = data.Modifiable,

            [Ref] = inputBox,
            [OnEvent "FocusLost"] = function()
                if data.Modifiable:get() then
                    local inputBoxObject = inputBox:get()
                    local currentText = inputBoxObject.Text

                    local didParse, parsedTime = Util.parseTimeString(currentText)
                    if not didParse then
                        inputBoxObject.Text = data.Value:get()
                    else
                        data.Value:set(parsedTime)
                        inputBoxObject.Text = parsedTime
                        Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                    end
                end
            end
        }
    }
end

SettingTypes.Number = SettingTypes.String

return SettingTypes
