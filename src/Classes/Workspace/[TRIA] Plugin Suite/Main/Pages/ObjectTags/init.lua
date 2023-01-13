local Fusion = require(script.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Resources.Components)
local TagListener = require(script.TagListener)
local TagData = require(script.tagData)

local New = Fusion.New
local ComputedPairs = Fusion.ComputedPairs
local Children = Fusion.Children

local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        Visible = data.Visible,
        Name = "ObjectTags",

        [Children] = {
            Components.PageHeader("Object Tags"),
            Components.ScrollingFrame({
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 180),
                BackgroundColor3 = Theme.MainBackground.Default,

                Children = {
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
            })
        }
    }
end

return frame
