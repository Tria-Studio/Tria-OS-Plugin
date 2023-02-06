local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)
local Util = require(Package.Util)
local DropdownData = require(script.DropdownData)
local Pages = require(Package.Resources.Components.Pages)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

local Maid = Util.Maid.new()
local DataChosen = Util.Signal.new()

local value

local Dropdown = {}


function Dropdown:Cancel()
    value = nil
    DataChosen:Fire()
end

function Dropdown:GetValue(dataArray, uiParent)
    local dropdownData, sortOrder = DropdownData[dataArray]()
    local UiSize = #dropdownData * 20
    local localYPos = uiParent.AbsolutePosition.Y + uiParent.AbsoluteSize.Y / 2
    local frameOnTop = Util.Widget.AbsoluteSize.Y - localYPos < math.min(UiSize, 240)
    local textTruncated = Value(Enum.TextTruncate.None)


    Maid:GiveTask(Pages.pageChanged:Connect(function()
        if Util.dropdownActive:get() then
            Dropdown:Cancel()
        end
    end))

    Maid:GiveTask(
        New "TextButton" {
            ZIndex = 7,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -76),
            Position = UDim2.new(0, 0, 0, 52),
            Parent = uiParent:FindFirstAncestor("TRIA.os Plugin"),

            [OnEvent "Activated"] = function()
                Dropdown:Cancel()
            end
        }
    )
    Maid:GiveTask(
        Components.ScrollingFrame {
            Parent = uiParent,
            Size = UDim2.fromOffset(120 + (UiSize > 240 and 12 or 0), math.min(UiSize, 240)),
            Position = UDim2.fromScale(0, frameOnTop and 0 or 1),
            AnchorPoint = Vector2.new(0, frameOnTop and 1 or 0),
            BackgroundColor3 = Theme.Border.Default,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = UiSize > 240 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BorderColor3 = Theme.Border.Default,
            BorderSizePixel = 2,
            ZIndex = 8,

            [Children] = {
                Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1), nil, sortOrder),
                ForValues(dropdownData, function(data)
                    if data.Image then
                        textTruncated:set(Enum.TextTruncate.AtEnd)
                    end
                    return Components.TextButton {
                        Text = data.Name,
                        Name = data.Name,
                        TextColor3 = data.TextColor or Theme.MainText.Default,
                        BackgroundColor3 = Theme.Dropdown.Default,
                        BorderSizePixel = 0,
                        Font = Enum.Font.SourceSansSemibold,
                        TextTruncate = textTruncated,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 16,
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 8,

                        [OnEvent "Activated"] = function()
                            value = data.Value
                            DataChosen:Fire()
                        end,
                        
                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 2), UDim.new(0, 22)),
                            New "ImageLabel" {
                                Position = UDim2.new(1, 2, 0, 0),
                                Size = UDim2.fromOffset(20, 20),
                                BackgroundTransparency = 1,
                                Image = data.Image or "",
                                ImageColor3 = Theme.BrightText.Default,
                            }
                        }
                    }     
                end, Fusion.Cleanup)
            }
        }
    )

    local ZIndex = uiParent.ZIndex
    uiParent.ZIndex = 8
    Util.dropdownActive:set(true)
    DataChosen:Wait()
    Maid:DoCleaning()
    Util.dropdownActive:set(false)
    uiParent.ZIndex = ZIndex

    return value
end

Util.MainMaid:GiveTask(Maid)
return Dropdown
