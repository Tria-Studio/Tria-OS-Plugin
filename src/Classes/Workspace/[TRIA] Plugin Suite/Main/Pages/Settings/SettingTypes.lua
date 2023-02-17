local SettingTypes = {}

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)
local Util = require(Package.Util)
local ColorWheel = require(Package.Colorwheel)
local Dropdown = require(Package.Util.Dropdown)

local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local Observer = Fusion.Observer
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Ref = Fusion.Ref
local Value = Fusion.Value
local Spring = Fusion.Spring

local currentEditing = Value(nil)

local function isCurrentSettingModifiable(data)
    local isErrored = data.Errored:get()
    return (not isErrored and Util.interfaceActive:get())
end

local function getSettingTextColor(data)
    local isErrored = data.Errored:get()
    return (isErrored and Theme.ErrorText.Default:get()) or Theme.SubText.Default:get()
end

local function canEditSetting(data)
    local isErrored = data.Errored:get()
    return (not isErrored)
end

function BaseSettingButton(data)
    local backgroundColor = Value(Theme.MainBackground.Default:get(false))
    local mouseInside = Value(false)
    local settingFrame = Value()

    return New "Frame" {
        [Ref] = settingFrame,

        BackgroundColor3 = Computed(function()
            local baseColor = backgroundColor:get()
            return Util.dropdownActive:get() and settingFrame:get().BackgroundColor3 or baseColor
        end),
        BackgroundTransparency = 0,
        BorderColor3 = Theme.Border.Default,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        Name = data.Text or data.Name,
        Size = UDim2.new(1, 0, 0, 20),

        [OnEvent "MouseEnter"] = function()
            mouseInside:set(true)
            if not currentEditing:get(false) and Util.interfaceActive:get(false) then
                backgroundColor:set(Theme.CurrentMarker.Default:get(false))
            end
        end,
        [OnEvent "MouseLeave"] = function()
            mouseInside:set(false)
            if settingFrame:get(false) ~= currentEditing:get(false) then
                backgroundColor:set(Theme.MainBackground.Default:get(false)) 
            end
        end,

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.45, 1),
                FontFace = Font.new("SourceSansPro"),
                Text = data.Text,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextColor3 = Computed(function()
                    return getSettingTextColor(data)
                end),
                TextXAlignment = Enum.TextXAlignment.Left,
            },

            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 20), nil),
                New "Frame" {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundColor3 = Theme.Border.Default,
                    BackgroundTransparency = 0,
                    Position = UDim2.fromScale(0.45, 0),
                    Size = UDim2.new(0, 1, 1, 0)
                },
                Components.TooltipImage {
                    Header = data.Text or data.Name,
                    Tooltip = if data.Tooltip then data.Tooltip.Text else "",
                    Position = UDim2.new(0, -2, 0, 0)
                }
            }
        }
    }, backgroundColor, mouseInside
end

function InputBox(data, baseButton)
    return function (props)
        return Hydrate(Components.TextBox {
            Active = Computed(function()
                return isCurrentSettingModifiable(data)
            end),
            TextEditable = Computed(function()
                return isCurrentSettingModifiable(data)
            end),

            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = Computed(function()
                return baseButton == currentEditing:get() and Util.interfaceActive:get() and 0 or 1
            end),
            BackgroundColor3 = Theme.InputFieldBackground.Default,
            BorderSizePixel = 1,
            FontFace = Font.new("SourceSansPro"),
            TextColor3 = Computed(function()
                return getSettingTextColor(data)
            end),
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
                if canEditSetting(data) then
                    currentEditing:set(baseButton)
                    backgroundColor:set(Theme.CurrentMarker.Default:get(false))
                end
            end,
            [OnEvent "FocusLost"] = function()
                if not buttonInside:get(false) then
                    backgroundColor:set(Theme.MainBackground.Default:get(false))
                end
                currentEditing:set(nil)
                if canEditSetting(data) then
                    local inputBoxObject = inputBox:get(false)
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

            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundTransparency = 1,

            [OnEvent "Activated"] = function()
                if canEditSetting(data) then
                    data.Value:set(not data.Value:get(false))
                    Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                end
            end,

            [Children] = Components.Checkbox(14, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5), data.Value)
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
                Position = UDim2.new(0.45, 8, 0.5, 0),
                Size = UDim2.fromOffset(12, 12),

                [OnEvent "Activated"] = function()
                    if not canEditSetting(data) then
                        return
                    end
                    currentEditing:set(baseButton)
                    backgroundColor:set(Theme.CurrentMarker.Default:get(false))

                    local chosenColor = ColorWheel:GetColor()

                    if not buttonInside:get(false) then
                        backgroundColor:set(Theme.MainBackground.Default:get(false))
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
                Position = UDim2.new(0.45, 28, 0, 0),
                Size = UDim2.new(0, 1, 1, 0)
            },

            InputBox(data, baseButton){
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0.55, -28, 1, 0),
                Text = Computed(function()
                    return Util.colorToRGB(data.Value:get())
                end),
                TextEditable = Computed(function()
                    return canEditSetting(data)
                end),

                [Ref] = inputBox,

                [OnEvent "Focused"] = function()
                    backgroundColor:set(Theme.CurrentMarker.Default:get(false))
                    currentEditing:set(baseButton)
                end,
                [OnEvent "FocusLost"] = function()
                    if not buttonInside:get(false) then
                        backgroundColor:set(Theme.MainBackground.Default:get(false))
                    end
                    currentEditing:set(nil)

                    if canEditSetting(data) then
                        local inputBoxObject = inputBox:get(false)
                        local currentText = inputBoxObject.Text
                        local didParse, parsedColor = Util.parseColor3Text(currentText)
                        if not didParse then
                            inputBoxObject.Text = Util.colorToRGB(data.Value:get(false))
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
            TextEditable = Computed(function()
                return canEditSetting(data)
            end),

            [Ref] = inputBox,

            [OnEvent "Focused"] = function()
                currentEditing:set(baseButton)
                backgroundColor:set(Theme.CurrentMarker.Default:get(false))
            end,
            [OnEvent "FocusLost"] = function()
                if not buttonInside:get(false) then
                    backgroundColor:set(Theme.MainBackground.Default:get(false))
                end
                currentEditing:set(nil)

                if canEditSetting(data) then
                    local inputBoxObject = inputBox:get(false)
                    local currentText = inputBoxObject.Text

                    local didParse, parsedTime = Util.parseTimeString(currentText)
                    if not didParse then
                        inputBoxObject.Text = data.Value:get(false)
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

function SettingTypes.Dropdown(data)
    local arrowButton = Value()
    local dropdownVisible = Value(false)

    local baseButton, backgroundColor, buttonInside = BaseSettingButton(data)
    local inputBox = Value()

    return Hydrate(baseButton) {
        [Children] = {
            Components.TextButton {
                Active = Util.interfaceActive,
                Size = UDim2.new(0.55, 0, 1, 0),
                Position = UDim2.new(0.45, -2, 0, 0),
                BackgroundTransparency = 1,
    
                [Children] = Components.ImageButton {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromOffset(24, 1),
                    Size = UDim2.fromOffset(16, 16),
    
                    [Ref] = arrowButton,
    
                    [Children] = {
                        Components.Constraints.UIAspectRatio(1),
                        New "ImageLabel" {
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://6031094687",
                            Rotation = Spring(Computed(function()
                                return dropdownVisible:get() and 0 or 180
                            end), 20),
                            ZIndex = 8,
                        }
                    },
    
                    [OnEvent "Activated"] = function()
                        if not dropdownVisible:get() then
                            dropdownVisible:set(true)
                            local newData = Dropdown:GetValue(data.DropdownArray, arrowButton:get())
                            if newData then
                                data.Value:set(string.format("%s", newData))
                                Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                            end
                            dropdownVisible:set(false)
                        else
                            Dropdown:Cancel()
                        end
                    end
                }
            },

            Components.TextBox {
                Active = Computed(function()
                    return isCurrentSettingModifiable(data)
                end),
    
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 1,
                FontFace = Font.new("SourceSansPro"),
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0.575, -28, 1, 0),
                Text = data.Value,
                TextColor3 = Computed(function()
                    return getSettingTextColor(data)
                end),
                TextEditable = Computed(function()
                    return canEditSetting(data)
                end),
                TextXAlignment = Enum.TextXAlignment.Left,
        
                [Ref] = inputBox,

                [OnEvent "Focused"] = function()
                    currentEditing:set(baseButton)
                    backgroundColor:set(Theme.CurrentMarker.Default:get(false))
                end,

                [OnEvent "FocusLost"] = function()
                    if not buttonInside:get(false) then
                        backgroundColor:set(Theme.MainBackground.Default:get(false))
                    end
                    currentEditing:set(nil)
    
                    if canEditSetting(data) then
                        local inputBoxObject = inputBox:get(false)
                        local currentText = inputBoxObject.Text

                        data.Value:set(currentText)
                        Util.updateMapSetting(data.Directory, data.Attribute, data.Value:get(false))
                    end
                end,

                [Children] = {
                    Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8), nil)
                },
            }
        }
    }
end

SettingTypes.Number = SettingTypes.String

return SettingTypes
