local Fusion = require(script.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Resources.Components)
-- local Util = require(script.Parent.Util)
-- local TagData = require(script.tagData)

local New = Fusion.New
local Children = Fusion.Children

local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
    
        [Children] = {
            Components.PageHeader("Object Tags"),
            New "ScrollingFrame" {
                BackgroundColor3 = Theme.ScrollBarBackground.Default,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 180),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarImageColor3 = Theme.ScrollBar.Default,
                
                [Children] = {
                    Components.Constraints.UIListLayout(),
                    Components.ScrollingFrameHeader("Button Event Tags", 1),
                    
                }
            }
        }
    }
end

return frame