local RunService = game:GetService("RunService")

local Package = script.Parent.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)
local ViewObject = require(script.Parent.ViewObject)
local ColorWheel = require(Package.ColorWheel)


local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local ForValues = Fusion.ForValues
local OnEvent = Fusion.OnEvent

local viewObjects = {}

Util.MapChanged:Connect(function()
    if Util.mapModel:get() then
        return
    end

    for name, state in pairs(viewObjects) do
        local value = state.get and state:get() or state

        if not value.Name then
            for _, ViewObject in pairs(value) do
                ViewObject:Disable()
            end
        else
            value:Disable()
        end
    end
end)

local function GetColorButton(name, metadataName, data)
    if data and not data.SingleOption then
        return
    end
    local Controller = viewObjects[name].get and viewObjects[name]:get() or viewObjects[name]
    if metadataName then
        Controller = Controller[metadataName]
    end

    if Controller.Color:get() then
        return New "TextButton" {
            AutoButtonColor = Computed(function(): TremoloSoundEffect
                return Util.mapModel:get() and Util.hasSpecialFolder:get()
            end),
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(1, -6, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Controller.Color,
            BorderMode = Enum.BorderMode.Inset,
            BorderColor3 = Theme.Border.Default,
            BorderSizePixel = 2,
    
            [OnEvent "Activated"] = function()
                if Util.mapModel:get() and Util.hasSpecialFolder:get() then
                    local NewColor = ColorWheel:GetColor(Controller.Color:get()) or Controller.Color:get()
                    Controller:SetColor(NewColor)
                end
            end,

            [Children] = New "Frame" {
                Size = UDim2.new(0, 2, 0, 25),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(0, -5, 0.5, 0),
                BackgroundColor3 = Theme.Border.Default,
                Visible = not data
            }
        }
    end
end

return function(name: string, data: PublicTypes.Dictionary)
    local checkState
    if data.SingleOption then
        Controller = ViewObject.new(name, data, data.Color)
        viewObjects[name] = Controller
        checkState = Controller.checkState
    else
        if viewObjects[name] and viewObjects[name].get then
            for metadataName, viewObject in pairs(viewObjects[name]:get()) do --// destroy them all because THIS WAS THE SOLUTION SOHDSFJKFHDJKSHFSKJLFHSDLKJHFL
                viewObject:Destroy()
            end
        end
        viewObjects[name] = {}

        for _, metadata in pairs(data.ViewOptions.get and data.ViewOptions:get() or data.ViewOptions) do
            Controller = ViewObject.new(metadata.Name, metadata, metadata.Color)
            viewObjects[name][metadata.Name] = Controller
        end

        viewObjects[name] = Value(viewObjects[name])
        checkState = Value(false)


        task.delay(1, function()
            if RunService:IsStudio() and not RunService:IsRunning() then
                return
            end
            Util._DebugView.debugObjectsFolder.AncestryChanged:Connect(function()
                if not Util._DebugView.debugObjectsFolder.Parent then
                    checkState:set(false)
                end
            end)
            Util.MapChanged:Connect(function()
                checkState:set(false)
            end)
        end)

        -- update it here so i dont forget
    end

    local function GetState(Objects)
        for name, ViewObject in pairs(Objects) do
            if not ViewObject.Enabled then
                return false
            end
        end
        return true
    end

    return New "Frame" {
        Visible = name == "AddonView" and Computed(function(): boolean
            return Util._Addons.hasAddonsWithObjectTags:get() ~= false
        end) or true,
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

                [OnEvent "Activated"] = function()
                    if Util.isPluginFrozen() then
                        return
                    end

                    if data.SingleOption then
                        if viewObjects[name].Enabled then
                            if viewObjects[name].UsesAll then
                                Util._DebugView.viewsActiveUsingAll -= 1
                            end
                            viewObjects[name]:Disable()
                            Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get() - 1)
                        else
                            if name == "LowDetail" and not Util.mapModel:get():FindFirstChild("Detail") then
                                return
                            end
                            if viewObjects[name].UsesAll then
                                Util._DebugView.viewsActiveUsingAll += 1
                            end
                            Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get() + 1)
                            viewObjects[name]:Enable()
                        end
                    else
                        local ALlViewObjects = viewObjects[name]:get()
                        local CurrentState = GetState(ALlViewObjects)
                        local count = -1

                        for name, data in pairs(ALlViewObjects) do
                            count += 1
                            if CurrentState then
                                if data.UsesAll then
                                    Util._DebugView.viewsActiveUsingAll -= 1
                                end
                                data:Disable()
                                Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get(false) - 1)
                            else
                                data:Enable()
                                Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get(false) + 1)
                                task.wait()
                            end
                        end
                        checkState:set(not CurrentState)
                    end
                end,

                [Children] = {
                    Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil),
                    GetColorButton(name, nil, data),
                }
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
                        Text = Computed(function(): string
                            return #(data.ViewOptions.get and data.ViewOptions:get() or data.ViewOptions) > 0 and data.SubText or data.AltSubText or ""
                        end),
                        Visible = data.SubText == "All Variants" or #data.ViewOptions > 0,
                        BackgroundColor3 = Theme.MainBackground.Default,
                        BorderColor3 = Theme.Border.Default,
                        BorderSizePixel = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.SourceSansSemibold,
                        TextColor3 = Theme.BrightText.Default,
                        TextSize = 16
                    },

                    ForValues(not data.SingleOption and viewObjects[name] or {}, function(ViewObject: PublicTypes.Dictionary): Instance
                        local metadata = ViewObject.Data
                        local dataValue = ViewObject.checkState
                        local BackgroundColor = Value(Theme.ScrollBarBackground.Default:get(false))  

                        Util.ThemeChanged:Connect(function()
                            BackgroundColor:set(Theme.ScrollBarBackground.Default:get(false))
                        end)

                        return New "TextButton" {
                            BackgroundColor3 = BackgroundColor,
                            BorderColor3 = Theme.Border.Default,
                            BorderSizePixel = 1,
                            Size = UDim2.new(1, 0, 0, 22),
                            LayoutOrder = metadata.LayoutOrder + 1,
                            Text = typeof(metadata.Name) == "table" and metadata.Name or " " .. metadata.Name,
                            TextColor3 = Theme.MainText.Default,
                            Font = Enum.Font.SourceSansSemibold,
                            TextSize = 15,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Visible = name == "AddonView" and Computed(function(): boolean
                                return Util._Addons[metadata.Name == "_Teleporter" and "hasEasyTP" or metadata.Name == "_Waterjet" and "hasWaterjet"]:get() ~= false
                            end) or true,

                            [OnEvent "Activated"] = function()
                                if not Util.isPluginFrozen() then
                                    if ViewObject.Enabled then
                                        if ViewObject.UsesAll then
                                            Util._DebugView.viewsActiveUsingAll -= 1
                                        end
                                        ViewObject:Disable()
                                        Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get(false) - 1)
                                    else
                                        if ViewObject.UsesAll then
                                            Util._DebugView.viewsActiveUsingAll += 1
                                        end
                                        ViewObject:Enable()
                                        Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get(false) + 1)
                                    end
                                    for name, data in pairs(viewObjects[name]:get()) do
                                        if not data.Enabled then
                                            checkState:set(false)
                                            return
                                        end
                                    end 
                                    checkState:set(true)
                                end
                            end,

                            [OnEvent "MouseEnter"] = function()
                                if not Util.isPluginFrozen() then
                                    BackgroundColor:set(Theme.Mid.Default:get(false))
                                end
                            end,
                            [OnEvent "MouseLeave"] = function()
                                if not Util.isPluginFrozen() then
                                    BackgroundColor:set(Theme.ScrollBarBackground.Default:get(false))
                                end
                            end,
                            [OnEvent "MouseButton1Down"] = function()
                                if not Util.isPluginFrozen() then
                                    BackgroundColor:set(Theme.Light.Default:get(false))
                                end
                            end,
                            [OnEvent "MouseButton1Up"] = function()
                                if not Util.isPluginFrozen() then
                                    BackgroundColor:set(Theme.Mid.Default:get(false))
                                end
                            end,

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

                                GetColorButton(name, metadata.Name)
                            }
                        }
                    end, Fusion.cleanup),
                    Components.Spacer(data.SingleOption, #(data.ViewOptions.get and data.ViewOptions:get(false) or data.ViewOptions) + 2, 2, 1, Theme.ScrollBarBackground.Default),   
                }
            },
        }
    }
end
