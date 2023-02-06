local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)
local Theme = require(Package.Resources.Themes)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local Maid = Util.Maid.new()
local DataChosen = Util.Signal.new()

local value

local Dropdown = {}


function Dropdown:Cancel()
    print"cancel"
    value = nil
    DataChosen:Fire()
end

function Dropdown:GetValue(dataArray, uiParent)
    Maid:GiveTask(
        New "Frame" {
            Parent = uiParent,
            Size = UDim2.fromOffset(80, 0),
            Position = UDim2.fromScale(0, 1),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Border.Default,
            BorderColor3 = Theme.Border.Default,
            BorderSizePixel = 1,
            ZIndex = 8,

            [Children] = {
                Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1)),
                ForValues(dataArray, function(data)
                    return Components.TextButton {
                        Text = data.text,
                        BackgroundColor3 = Theme.Dropdown.Default,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 8,

                        [OnEvent "Activated"] = function()
                            value = data.Value
                            DataChosen:Fire()
                        end
                    }     
                end, Fusion.Cleanup)
            }
        }
    )
    Util.dropdownActive:set(true)
    DataChosen:Wait()
    Maid:DoCleaning()
    Util.dropdownActive:set(false)

    return value
end

return Dropdown
