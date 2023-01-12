local Fusion = require(script.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Resources.Components)
local TagListener = require(script.Parent.Parent.Resources.Components.TagListener)
-- local Util = require(script.Parent.Util)
local TagData = require(script.tagData)

local New = Fusion.New
local ComputedPairs = Fusion.ComputedPairs
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
                BorderColor3 = Theme.Border.Default,
                BorderSizePixel = 2,
                BackgroundColor3 = Theme.ScrollBarBackground.Default,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 180),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarImageColor3 = Theme.ScrollBar.Default,
                BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 2)),
                    Components.ScrollingFrameHeader("Button Event Tags", 1),
                    New "Frame" {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        LayoutOrder = 2,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1)),
                            ComputedPairs(TagData.dataTypes.buttonTags, function(tagName, data)
                                return TagListener(tagName, data)
                            end)
                        },
                    },
                    Components.ScrollingFrameHeader("Object Tags", 3),
                    New "Frame" {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        LayoutOrder = 4,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1)),
                            ComputedPairs(TagData.dataTypes.objectTags, function(tagName, data)
                                return TagListener(tagName, data)
                            end)
                        },
                    }
                }
            }
        }
    }
end

return frame
