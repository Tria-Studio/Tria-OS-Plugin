local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components )
local Util = require(Package.Util)
local TagUtils = require(Package.Util.TagUtils)
local TagData = require(script.Parent.tagData)
local Pages = require(Package.Resources.Components.Pages)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer
local Out = Fusion.Out
local OnEvent = Fusion.OnEvent

return function(name, data)
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
                    BackgroundColor3 = Theme.Button.Default,
                    Position = UDim2.fromOffset(-56, 0),
                    Size = UDim2.new(1, 56, 0, 25),
                    Font = Enum.Font.SourceSansBold,
                    Text = data.DisplayText,
                    TextColor3 = Theme.MainText.Default,
                    TextXAlignment = Enum.TextXAlignment.Left,

                    AutoButtonColor = Util.interfaceActive,
                    Active = Util.interfaceActive,

                    [OnEvent "Activated"] = function()
                        if #Util._Selection.selectedParts:get() > 0 then
                            local tagData = TagData.dataTypes.objectTags[name] or TagData.dataTypes.buttonTags[name]
                            if not tagData.IsTagApplicable then --// Buttons, ziplines, and airtanks cannot be assigned or removed
                                Util:ShowMessage("Cannot Set Tag", string.format("The following tag '%s' cannot be assigned or removed from other parts because these are more complex models.<br /><br /> See the Insert page to add these map components to your map.", name), nil, {
                                    Text = "Take me there",
                                    Callback = function()
                                        Pages:ChangePage("Insert")
                                    end
                                })
                                return
                            end
                            
                        end
                    end,

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
                    Image = Computed(function()
                        return if checkState:get() == Enum.TriStateBoolean.True
                            then Util.Images.Checkbox.Checked
                            elseif checkState:get() == Enum.TriStateBoolean.False
                            then Util.Images.Checkbox.Unchecked
                            else Util.Images.Checkbox.Unknown 
                    end),
                    ImageColor3 = Theme.CheckedFieldIndicator.Default,
                },
                New "ImageLabel" { --// Icon
                    Size = UDim2.fromOffset(20, 20),
                    Position = UDim2.fromOffset(-6, 2),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0),
                    Image = data.DisplayIcon,
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
                                                local TextXSize = textBounds:get() and textBounds:get().X + 12 or 0
                                                local Types = {}

                                                function Types.number()
                                                    
                                                end
                                                Types.string = Types.number

                                                function Types.boolean()
                                                    
                                                end

                                                function Types.color()
                                                    
                                                end

                                                function Types.dropdown()
                                                    
                                                end
                                                
                                                return Types[metadataType.data.dataType]()
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
