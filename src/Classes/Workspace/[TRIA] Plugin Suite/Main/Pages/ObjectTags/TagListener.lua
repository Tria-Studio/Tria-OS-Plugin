local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components )
local Util = require(Package.Util)
local TagUtils = require(Package.Util.TagUtils)
local TagData = require(script.Parent.tagData)
local Pages = require(Package.Resources.Components.Pages)
local Colorwheel = require(Package.ColorWheel)
local Dropdown = require(Package.Util.Dropdown)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Out = Fusion.Out
local OnChange = Fusion.OnChange
local Ref = Fusion.Ref
local Spring = Fusion.Spring
local OnEvent = Fusion.OnEvent
 
return function(name: string, data: PublicTypes.propertiesTable): Instance
    local dataVisible = Value(false)
    local checkState = Value(Enum.TriStateBoolean.False)

    local metaDataVisible = Computed(function()
        Util._Selection.selectedUpdate:get() --// update it when a part changes idk lol
        local value = #Util._Selection.selectedParts:get() == 0 and Enum.TriStateBoolean.False or TagUtils:PartsHaveTag(Util._Selection.selectedParts:get(), name)
        checkState:set(#Util._Selection.selectedParts:get() > 0 and value or Enum.TriStateBoolean.False)
        return #Util._Selection.selectedParts:get() > 0 and value == Enum.TriStateBoolean.True
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

        [Children] = New "Frame" {
            BackgroundColor3 = Theme.Button.Default,    
            Size = UDim2.new(1, 0, 0, 25),
            AutomaticSize = Enum.AutomaticSize.Y,

            [Children] = {
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 56), nil),
                New "TextButton" { --// Button
                    AutoButtonColor = Computed(function()
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

                        if #Util._Selection.selectedParts:get() > 0 then
                            local tagData = TagData.dataTypes.objectTags[name] or TagData.dataTypes.buttonTags[name]
                            if not tagData.IsTagApplicable then --// Buttons, ziplines, and airtanks cannot be assigned or removed
                                Util:ShowMessage("Cannot Set Tag", string.format("The following tag '%s' cannot be assigned or removed from other parts because these are more complex models.<br /><br />See the Insert page to add these map components to your map.", name), {
                                    Text = "Show me",
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
                            
                            if partError and name ~= "Detail" then
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
                    Position = UDim2.new(1, -4, 0, 2)
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
                        Size = Computed(function()
                            return UDim2.new(1, 56, 0, dataVisible:get() and 10 or 0)
                        end),
                        Visible = dataVisible,

                        [OnChange "Visible"] = function(value)
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

                                [Children] = ForValues(data.metadata, function(metadataType)
                                    local textBounds = Value(Vector2.new())

                                    return New "TextLabel" {
                                        [Out "TextBounds"] = textBounds,

                                        BackgroundColor3 = Theme.ScrollBarBackground.Default,
                                        BorderColor3 = Theme.Border.Default,
                                        BorderSizePixel = 1,
                                        Size = UDim2.new(metadataType.isFullSize and 1 or 0.5, 0, 0, 22),
                                        Position = UDim2.new(metadataType.location % 2 == 1 and 0 or 0.5, 0, 0, (math.ceil(metadataType.location / 2) - 1) * 22),
                                        Text = metadataType.data.displayName .. ":",
                                        TextColor3 = Theme.MainText.Default,
                                        Font = Enum.Font.SourceSansSemibold,
                                        TextSize = 15,
                                        TextXAlignment = Enum.TextXAlignment.Left,

                                        [Children] = {
                                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8)),
                                            Computed(function()
                                                if not dataVisible:get() then
                                                    return
                                                end

                                                local dataValue = Value(TagUtils:GetSelectedMetadataValue(name, metadataType.data._referenceName) or "")
                                                if dataValue:get() == Enum.TriStateBoolean.False then
                                                    dataValue:set(false)
                                                end

                                                local textXBounds = textBounds:get() and textBounds:get().X + 8 or 0
                                                local types = {}

                                                local function updateData(value)
                                                    local stringTagValue = metadataType.data.dataType == "color"
                                                        and Util.parseTextColor3(dataValue:get())
                                                        or dataValue:get()

                                                    ChangeHistoryService:SetWaypoint(string.format("Changing metadata %s on %d part%s to %s", metadataType.data.displayName, #Util._Selection.selectedParts:get(), #Util._Selection.selectedParts:get() == 1 and "" or "s", tostring(stringTagValue)))
                                                    dataValue:set(value)
                                                    for _, selected: Instance in ipairs(Util._Selection.selectedParts:get()) do 
                                                        TagUtils:SetPartMetaData(selected, name, metadataType, value)
                                                    end
                                                    ChangeHistoryService:SetWaypoint(string.format("Set metadata %s on %d part%s to %s", metadataType.data.displayName, #Util._Selection.selectedParts:get(), #Util._Selection.selectedParts:get() == 1 and "" or "s", tostring(stringTagValue)))
                                                end

                                                function types.number(sizeSubtract: number?, extraChild: any?, textOverride: any?)
                                                    local Text = Value()
                                                    local Childs = extraChild or {}
                                                    table.insert(Childs, Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4)))

                                                    return Components.TextBox {
                                                        Size = UDim2.new(1, -textXBounds - 6 - (sizeSubtract or 0), 1, -6),
                                                        AnchorPoint = Vector2.new(0, .5),
                                                        Position = UDim2.new(0, textXBounds + (sizeSubtract or 0), .5, 0),
                                                        TextXAlignment = Enum.TextXAlignment.Left,
                                                        Text = textOverride or dataValue,

                                                        [Ref] = Text,
                                                        [OnEvent "FocusLost"] = function()
                                                            local isTextColor, color = Util.parseColor3Text(Text:get().Text)
                                                            local newText = if metadataType.data.dataType == "number"
                                                                then tonumber(Text:get().Text) and tonumber(Text:get().Text) or 0
                                                                elseif isTextColor then Text:get().Text
                                                                else Text:get().Text

                                                            if color ~= dataVisible:get() or metadataType.data.dataType ~= "color" then
                                                                Text:get().Text = newText
                                                                updateData(if metadataType.data.dataType == "color" then color else newText)
                                                            end
                                                        end,
                                                        
                                                        [Children] = Childs,
                                                    }
                                                end
                                                types.string = types.number

                                                function types.boolean()
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

                                                function types.color()
                                                    return types.number(22, {Components.TextButton {
                                                        AnchorPoint = Vector2.new(1, .5),
                                                        Position = UDim2.new(0, -4, .5, 0),
                                                        Size = UDim2.fromOffset(16, 16),
                                                        BackgroundColor3 = Computed(function()
                                                            return (dataValue:get() == "" or not dataValue:get()) and Color3.new() or dataValue:get()
                                                        end),

                                                        [OnEvent "Activated"] = function()
                                                            updateData(Colorwheel:GetColor() or dataValue:get())
                                                        end
                                                    }}, Computed(function()
                                                            return dataValue:get() == "" and "" or Util.parseTextColor3(dataValue:get())
                                                    end))
                                                end

                                                function types.dropdown() --// LiquidType, Difficulty, Locator Image, Zipline Material
                                                    local dropdownVisible = Value(false)
                                                    local arrowButton = Value()

                                                    return types.number(22, {Components.ImageButton {
                                                        AnchorPoint = Vector2.new(1, 0),
                                                        Position = UDim2.fromOffset(-8, -1),
                                                        Size = UDim2.fromOffset(18, 18),
                                        
                                                        [Ref] = arrowButton,
                                                        [Children] = {
                                                            Components.Constraints.UIAspectRatio(1),
                                                            New "ImageLabel" {
                                                                Size = UDim2.fromScale(1, 1),
                                                                BackgroundTransparency = 1,
                                                                ImageColor3 = Theme.MainText.Default,
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
                                                                local newData = Dropdown:GetValue(metadataType.data.dropdownType, arrowButton:get())
                                                                if newData then
                                                                    updateData(newData)
                                                                end
                                                                dropdownVisible:set(false)
                                                            else
                                                                Dropdown:Cancel()
                                                            end

                                                        end
                                                    }}, Computed(function()
                                                        return dataValue:get()
                                                    end))
                                                end

                                                return types[metadataType.data.dataType]()
                                            end, Fusion.cleanup)
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
