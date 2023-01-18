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
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Ref = Fusion.Ref
local Value = Fusion.Value

local currentEditing = Value(nil)

function BaseSettingButton(data)
    local backgroundColor = Value(Theme.MainBackground.Default:get())
    local mouseInside = Value(false)
    local Frame = Value()

    return New "Frame" {
        [Ref] = Frame,

        BackgroundColor3 = backgroundColor,
        BackgroundTransparency = 0,
        BorderColor3 = Theme.Border.Default,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        Name = data.Text or data.Name,
        Size = UDim2.new(1, 0, 0, 20),

        [OnEvent "MouseEnter"] = function()
            mouseInside:set(true)
            if not currentEditing:get() and Util.interfaceActive:get() then
                backgroundColor:set(Theme.CurrentMarker.Default:get())
            end
        end,
        [OnEvent "MouseLeave"] = function()
            mouseInside:set(false)
            if Frame:get() ~= currentEditing:get() then
                backgroundColor:set(Theme.MainBackground.Default:get()) 
            end
        end,

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.45, 1),
                FontFace = Font.new("SourceSansPro"),
                Text = data.Text,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextColor3 = if data.Modifiable:get() then Theme.SubText.Default else Theme.DimmedText.Default,
                TextXAlignment = Enum.TextXAlignment.Left,
            },

            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 20), nil),
                New "Frame" {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = Theme.Border.Default,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.45, 0),
                    Size = UDim2.new(0, 1, 1, 0)
                },
                New "ImageButton" {
                    Active = Util.interfaceActive,
                    AutoButtonColor = Util.interfaceActive,

                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Theme.MainBackground.Default,
                    BackgroundTransparency = 0,
                    BorderColor3 = Theme.Border.Default,
                    BorderMode = Enum.BorderMode.Inset,
                    BorderSizePixel = 1,
                    Position = UDim2.new(0, -2, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    Image = "rbxassetid://6034281900",
                    ImageColor3 = Theme.SubText.Default,
                }
            }
        }
    }, backgroundColor, mouseInside
end

function InputBox(data, baseButton)
    return function (props)
        return Hydrate(Components.TextBox {
            Active = if not data.Modifiable:get() then false else Util.interfaceActive,
            TextEditable = if not data.Modifiable:get() then false else Util.interfaceActive,

            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = Computed(function()
                return baseButton == currentEditing:get() and Util.interfaceActive:get() and 0 or 1
            end),
            BackgroundColor3 = Theme.InputFieldBackground.Default,
            BorderSizePixel = 1,
            FontFace = Font.new("SourceSansPro"),
            TextColor3 = if data.Modifiable:get() then Theme.SubText.Default else Theme.DimmedText.Default,
            TextXAlignment = Enum.TextXAlignment.Left,
    
            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8), nil)
            },
        })(props)
    end
end

function SettingTypes.String(data): Instance
    local inputBox = Value()
    local baseButton, backgroundColor, buttonInside = BaseSettingButton(data)

    return Hydrate(baseButton) {
        [Children] = InputBox(data, baseButton){
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            Text = data.Value,

            [Ref] = inputBox,

            [OnEvent "Focused"] = function()
                if data.Modifiable then
                    currentEditing:set(baseButton)
                    backgroundColor:set(Theme.CurrentMarker.Default:get())
                end
            end,
            [OnEvent "FocusLost"] = function()
                if not buttonInside:get() then
                    backgroundColor:set(Theme.MainBackground.Default:get())
                end
                currentEditing:set(nil)
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
    return Hydrate(BaseSettingButton(data)) {
        [Children] = New "TextButton" {
            Active = Util.interfaceActive,

            Size = UDim2.new(.55, 0, 1, 0),
            Position = UDim2.new(.45, 0, 0, 0),
            BackgroundTransparency = 1,

            [OnEvent "Activated"] = function()
                if data.Modifiable:get() then
                    data.Value:set(not data.Value:get(false))
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                end
            end,

            [Children] = New "ImageLabel" {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme.CheckedFieldBackground.Default,
                BackgroundTransparency = 0,
                BorderColor3 = Theme.CheckedFieldBorder.Default,
                BorderMode = Enum.BorderMode.Outline,
                BorderSizePixel = 1,

                Position = UDim2.new(0, 8, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                Image = Computed(function() 
                    return Util.Images.Checkbox[data.Value:get() == true and "Checked" or "Unchecked"]
                end),
                ImageColor3 = Theme.CheckedFieldIndicator.Default,
            }
        }
    }
end

function SettingTypes.Color(data)
    local inputBox = Value()
    local baseButton, backgroundColor, buttonInside = BaseSettingButton(data)

    return Hydrate(baseButton) {
        [Children] = {
            Components.TextButton {
                Active = Util.interfaceActive,
                AutoButtonColor = Util.interfaceActive,

                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = data.Value,
                BackgroundTransparency = 0,
                BorderColor3 = Theme.Border.Default,
                BorderMode = Enum.BorderMode.Outline,
                BorderSizePixel = 1,
                Name = "Color",
                Position = UDim2.new(0.45, 8, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),

                [OnEvent "Activated"] = function()
                    if not data.Modifiable:get() then
                        return
                    end
                    currentEditing:set(baseButton)
                    backgroundColor:set(Theme.CurrentMarker.Default:get())

                    local chosenColor = ColorWheel:GetColor()

                    if not buttonInside:get() then
                        backgroundColor:set(Theme.MainBackground.Default:get())
                    end
                    currentEditing:set(nil)
                   
                    if chosenColor == nil then
                        return
                    end
                    data.Value:set(chosenColor)
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                end
            },

            New "Frame" {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Theme.Border.Default,
                BackgroundTransparency = 0,
                BorderSizePixel = 0,
                Position = UDim2.new(0.45, 28, 0, 0),
                Size = UDim2.new(0, 1, 1, 0)
            },

            InputBox(data, baseButton){
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0.55, -28, 1, 0),
                Text = Computed(function()
                    return Util.colorToRGB(data.Value:get())
                end),
                TextEditable = data.Modifiable,

                [Ref] = inputBox,

                [OnEvent "Focused"] = function()
                    backgroundColor:set(Theme.CurrentMarker.Default:get())
                    currentEditing:set(baseButton)
                end,
                [OnEvent "FocusLost"] = function()
                    if not buttonInside:get() then
                        backgroundColor:set(Theme.MainBackground.Default:get())
                    end
                    currentEditing:set(nil)

                    if data.Modifiable:get() then
                        local inputBoxObject = inputBox:get()
                        local currentText = inputBoxObject.Text
                        local didParse, parsedColor = Util.parseColor3Text(currentText)
                        if not didParse then
                            inputBoxObject.Text = Util.colorToRGB(data.Value:get())
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
    local baseButton, backgroundColor, buttonInside = BaseSettingButton(data)
    local inputBox = Value()

    return Hydrate(baseButton) {
        [Children] = InputBox(data, baseButton){
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.55, 1),
            Text = data.Value,
            TextEditable = data.Modifiable,

            [Ref] = inputBox,

            [OnEvent "Focused"] = function()
                currentEditing:set(baseButton)
                backgroundColor:set(Theme.CurrentMarker.Default:get())
            end,
            [OnEvent "FocusLost"] = function()
                if not buttonInside:get() then
                    backgroundColor:set(Theme.MainBackground.Default:get())
                end
                currentEditing:set(nil)

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
