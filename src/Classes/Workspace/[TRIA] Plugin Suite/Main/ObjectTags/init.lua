local Fusion = require(script.Parent.Resources.Fusion)
local Components = require(script.Parent.Resources.Components)
local Theme = require(script.Parent.Resources.Themes)
local Util = require(script.Parent.Util)
local TagData = require(script.tagData)

local New = Fusion.New
local Children = Fusion.Children



return New "ScrollingFrame" {
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
