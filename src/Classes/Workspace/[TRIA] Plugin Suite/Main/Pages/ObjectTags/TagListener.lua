local ChangeHistoryService = game:GetService("ChangeHistoryService")
local TextService = game:GetService("TextService")

local Package = script.Parent.Parent.Parent
local Resources = Package.Resources
local UtilModule = Package.Util

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Pages = require(Resources.Components.Pages)

local Util = require(UtilModule)
local TagUtils = require(UtilModule.TagUtils)
local Dropdown = require(UtilModule.Dropdown)
local DropdownComponents = require(UtilModule.Dropdown.DropdownComponents)

local Colorwheel = require(Package.ColorWheel)
local PublicTypes = require(Package.PublicTypes)

local TagData = require(script.Parent.TagData)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Out = Fusion.Out
local OnChange = Fusion.OnChange
local Ref = Fusion.Ref
local OnEvent = Fusion.OnEvent

return function(name: string, data: PublicTypes.Dictionary): Instance
    local dataVisible = Value(false)
    local checkState = Value(Enum.TriStateBoolean.False)

    local metaDataVisible = Computed(function(): boolean
        Util._Selection.selectedUpdate:get()
        local selectedParts = Util._Selection.selectedParts:get()
        local active = Util.objectTagsActive:get()

        if not active or not Util._Addons.hasAddonsWithObjectTags:get() and (name == "_Teleporter" or name == "_Waterjet") then
            return
        end

        local value = #selectedParts == 0 and Enum.TriStateBoolean.False or TagUtils:PartsHaveTag(selectedParts, name)
        checkState:set(#selectedParts > 0 and value or Enum.TriStateBoolean.False)
        return #selectedParts > 0 and value == Enum.TriStateBoolean.True
    end)

    Observer(metaDataVisible):onChange(function()
        dataVisible:set(metaDataVisible:get())
    end)

    return New "Frame" {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Dropdown.Default,
        LayoutOrder = data.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 4),
        Name = name,
        Visible = if name == "_Waterjet" then Util._Addons.hasWaterjet else true,

        [Children] = New "Frame" {
            BackgroundColor3 = Theme.Button.Default,    
            Size = UDim2.new(1, 0, 0, 25),
            AutomaticSize = Enum.AutomaticSize.Y,

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
                        local partError = false

                        if #Util._Selection.selectedParts:get(false) > 0 then
                            local tagData = TagData.dataTypes.objectTags[name] or TagData.dataTypes.buttonTags[name] or TagData.dataTypes.addonTags[name]
                            if not tagData.IsTagApplicable then --// Buttons, ziplines, and airtanks cannot be assigned or removed
                                Util:ShowMessage("Cannot Set Tag", string.format("The following tag '%s' cannot be assigned or removed from other parts because these are more complex models.<br /><br />See the Insert page to add these map components to your map.", name), {
                                    Text = "Take me there",
                                    Callback = function()
                                        Pages:ChangePage("Insert")
                                    end
                                })
                                return
                            end

                            local currentlySelected = Util._Selection.selectedParts:get()
                            local newState = not dataVisible:get()

                            ChangeHistoryService:SetWaypoint(string.format("Changing tag %s on %d part%s to %s", name, #currentlySelected, #currentlySelected == 1 and "" or "s", tostring(newState)))
                            for _, instance in ipairs(Util._Selection.selectedParts:get()) do
                                if data.OnlyBaseParts and not instance:IsA("BasePart") then
                                    partError = true
                                    continue
                                end
                                TagUtils:SetPartTag(instance, newState and name, not newState and name)
                            end
                            ChangeHistoryService:SetWaypoint(string.format("Set tag %s on %d part%s to %s", name, #currentlySelected, #currentlySelected == 1 and "" or "s", tostring(newState)))
                            if partError and name ~= "_Detail" then
                                Util.debugWarn(string.format("Only BaseParts, Models, Folders, & Attachments can have the tag '%s'. Selected parts which were not a BasePart were ignored.", name))
                                Util:ShowMessage("Cannot Set Tag", string.format("Only <b>BaseParts</b>, <b>Models</b>, <b>Folders</b>, & <b>Attachments</b> can have the tag <b>'%s'</b>.<br /><br />Selected parts which were not a BasePart were ignored.", name))
                            end
                        end
                    end,

                    [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil)
                },
                Components.Checkbox(20, UDim2.fromOffset(-30, 2), Vector2.new(1, 0), checkState), --// Checkbox
                New "ImageLabel" { --// Icon
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.fromOffset(-6, 2),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Image = data.DisplayIcon,
                },
                Components.TooltipImage {
                    Header = data.Tooltip.Header,
                    Tooltip = data.Tooltip.Text,
                    Position = UDim2.new(1, -4, 0, 4)
                },
                (function(): Instance?
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
                        Size = Computed(function(): UDim2
                            return UDim2.new(1, 56, 0, dataVisible:get() and 10 or 0)
                        end),
                        Visible = dataVisible,

                        [OnChange "Visible"] = function(value: boolean)
                            if not value then
                                Dropdown:Cancel()
                            end
                        end,
                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            New "TextLabel" {
                                Text = "Metadata",
                                Visible = dataVisible,
                                BackgroundColor3 = Theme.MainBackground.Default,
                                BorderColor3 = Theme.Border.Default,
                                BorderSizePixel = 1,
                                BorderMode = Enum.BorderMode.Inset,
                                Size = UDim2.new(1, 0, 0, 22),
                                Font = Enum.Font.SourceSansSemibold,
                                TextColor3 = Theme.BrightText.Default,
                                TextSize = 16
                            },
                            New "Frame" {
                                Visible = dataVisible,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Size = UDim2.new(1, 0, 0, 24),
                                BackgroundTransparency = 1,
                                LayoutOrder = 2,

                                [Children] = ForValues(data.metadata, function(metadataType: PublicTypes.Dictionary): Instance
                                    local frameSize = Value(Vector2.new())

                                    return New "TextLabel" {
                                        [Out "AbsoluteSize"] = frameSize,

                                        BackgroundColor3 = Theme.ScrollBarBackground.Default,
                                        BorderColor3 = Theme.Border.Default,
                                        BorderSizePixel = 1,
                                        Visible = Computed(function(): boolean
                                            TagUtils.OnlyShowUpdate:get()
                                            for _, part: Instance in pairs(metadataType.data._onlyShow and Util._Selection.selectedParts:get() or {}) do
                                                for _, data in pairs(metadataType.data._onlyShow) do
                                                    if part:GetAttribute(data.Attribute) ~= data.Value then
                                                        return false
                                                    end
                                                end
                                            end
                                            return true
                                        end),
                                        Size = UDim2.new(metadataType.isFullSize and 1 or 0.5, 0, 0, 22),
                                        Position = UDim2.new(metadataType.location % 2 == 1 and 0 or 0.5, 0, 0, (math.ceil(metadataType.location / 2) - 1) * 22),
                                        Text = metadataType.data.displayName and metadataType.data.displayName .. ":",
                                        TextColor3 = Theme.MainText.Default,
                                        Font = Enum.Font.SourceSansSemibold,
                                        TextSize = 15,
                                        TextXAlignment = Enum.TextXAlignment.Left,

                                        [Children] = {
                                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8)),
                                            (function(): Instance
                                                local value, notExists
                                                local dataValue

                                                local function UpdateValue()
                                                    value, notExists = TagUtils:GetSelectedMetadataValue(name, metadataType.data._referenceName)
                                                    value = value or ""
                                                    
                                                    if dataValue then
                                                        dataValue:set(metadataType.data.dataType == "color" and notExists and "" or value)
                                                    else
                                                        dataValue = Value(metadataType.data.dataType == "color" and notExists and "" or value)
                                                    end
                                                    
                                                    if dataValue:get(false) == Enum.TriStateBoolean.False then
                                                        dataValue:set(false)
                                                    end
                                                end
                                                UpdateValue()
                                                TagUtils.OnTagAdded(name):Connect(function()
                                                    task.wait()
                                                    UpdateValue()
                                                end)

                                                local textSize = TextService:GetTextSize(metadataType.data.displayName or "", 15, Enum.Font.SourceSansSemibold, frameSize:get())
                                                local textXBounds = textSize and textSize.X + 8 or 0
                                                local types = {}

                                                local function updateData(value: any)
                                                    local stringTagValue = metadataType.data.dataType == "color"
                                                        and Util.parseTextColor3(dataValue:get())
                                                        or dataValue:get()

                                                    ChangeHistoryService:SetWaypoint(string.format("Changing metadata %s on %d part%s to %s", metadataType.data.displayName, #Util._Selection.selectedParts:get(false), #Util._Selection.selectedParts:get(false) == 1 and "" or "s", tostring(stringTagValue)))
                                                    dataValue:set(value)
                                                    for _, selected: Instance in ipairs(Util._Selection.selectedParts:get()) do 
                                                        TagUtils:SetPartMetaData(selected, name, metadataType, value)
                                                    end
                                                    ChangeHistoryService:SetWaypoint(string.format("Set metadata %s on %d part%s to %s", metadataType.data.displayName, #Util._Selection.selectedParts:get(false), #Util._Selection.selectedParts:get(false) == 1 and "" or "s", tostring(stringTagValue)))
                                                end

                                                function types.number(sizeSubtract: number?, extraChild: any?, textOverride: any?, isColor: boolean?): Instance
                                                    local textValue = Value()
                                                    local children = extraChild or {}
                                                    table.insert(children, Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4)))

                                                    return Components.TextBox {
                                                        Size = UDim2.new(1, -textXBounds - 6 - (sizeSubtract or 0), 1, -6),
                                                        AnchorPoint = Vector2.new(0, 0.5),
                                                        Position = UDim2.new(0, textXBounds + (sizeSubtract or 0), 0.5, 0),
                                                        TextXAlignment = Enum.TextXAlignment.Left,
                                                        Text = Computed(function()
                                                            return textOverride and textOverride:get() or tostring(dataValue:get())
                                                        end),

                                                        [Ref] = textValue,
                                                        [OnEvent "FocusLost"] = function()
                                                            local currentTextbox = textValue:get(false)
                                                            local isTextColor, color = Util.parseColor3Text(currentTextbox.Text)
                                                            
                                                            local newText = if metadataType.data.dataType == "number"
                                                                then tonumber(currentTextbox.Text) and tonumber(currentTextbox.Text) or 0
                                                                elseif isTextColor then currentTextbox.Text
                                                                else currentTextbox.Text

                                                            if color ~= dataVisible:get(false) or metadataType.data.dataType ~= "color" then
                                                                currentTextbox.Text = newText
                                                                updateData(if metadataType.data.dataType == "color" then color else newText)
                                                            end
                                                        end,
                                                        
                                                        [Children] = children,
                                                    }
                                                end
                                                types.string = types.number

                                                function types.boolean(): Instance
                                                    return New "TextButton" {
                                                        Size = UDim2.new(1, -textXBounds, 1, 0),
                                                        Position = UDim2.fromOffset(textXBounds, 0),
                                                        BackgroundTransparency = 1,

                                                        [OnEvent "Activated"] = function()
                                                            updateData(not dataValue:get())
                                                        end,

                                                        [Children] = Components.Checkbox(18, UDim2.fromOffset(4, 2), nil, dataValue)
                                                    }
                                                end

                                                function types.color(): Instance
                                                    return types.number(22, {Components.TextButton {
                                                        AnchorPoint = Vector2.new(1, 0.5),
                                                        Position = UDim2.new(0, -8, 0.5, 0),
                                                        Size = UDim2.fromOffset(16, 16),
                                                        BackgroundColor3 = Computed(function(): Color3
                                                            return (dataValue:get() == "" or not dataValue:get()) and Color3.new() or dataValue:get()
                                                        end),

                                                        [OnEvent "Activated"] = function()
                                                            updateData(Colorwheel:GetColor(dataValue:get()) or dataValue:get())
                                                        end
                                                    }}, Computed(function(): string
                                                            return dataValue:get() == "" and "" or Util.parseTextColor3(dataValue:get())
                                                    end), true)
                                                end

                                                function types.dropdown(): Instance
                                                    return types.number(22, {
                                                        DropdownComponents.DropdownButton {
                                                            Position = UDim2.fromOffset(-8, -1),
                                                            Size = UDim2.fromOffset(18, 18),
                                                            Options = metadataType.data.dropdownType,
                                                            OnToggle = function(newData: any)
                                                                updateData(newData)
                                                            end
                                                        }
                                                    }, dataValue)
                                                end

                                                function types.button(): Instance
                                                    return New "TextButton" {
                                                        Size = UDim2.new(1, 3, 1, -6),
                                                        Position = UDim2.fromOffset(-6, 2),
                                                        BackgroundColor3 = Theme.Button.Pressed,
                                                        BorderColor3 = Theme.Border.Default,
                                                        BorderSizePixel = 3,
                                                        AutoButtonColor = true,
                                                        Text = metadataType.data.dataName,
                                                        TextColor3 = Theme.MainText.Default,
                                                        Font = Enum.Font.SourceSansSemibold,
                                                        TextSize = 15,

                                                        [OnEvent "Activated"] = metadataType.data.callback
                                                    }
                                                end

                                                local value = types[metadataType.data.dataType]()
                                                return value
                                            end)()
                                        }
                                    }
                                end, Fusion.cleanup)
                            }
                        }
                    }
                end)()
            }
        }
    }
end
