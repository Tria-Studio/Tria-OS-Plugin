local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)

local TagListener = require(script.TagListener)
local TagData = require(script.tagData)

local New = Fusion.New
local ForPairs = Fusion.ForPairs
local Children = Fusion.Children

local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        Visible = data.Visible,
        Name = "ObjectTags",

        [Children] = {
            Components.PageHeader("Object Tags"),
            Components.ScrollingFrame({
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.fromOffset(0, 180),
                BackgroundColor3 = Theme.MainBackground.Default,

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 2)),
                    Components.ScrollingFrameHeader("Button Event Tags", 1),
                    New "Frame" {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(1, 0),
                        LayoutOrder = 2,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1)),
                            ForPairs(TagData.dataTypes.buttonTags, function(tagName, data)
                                return tagName, TagListener(tagName, data)
                            end, Fusion.cleanup)
                        },
                    },
                    Components.ScrollingFrameHeader("Object Tags", 3),
                    New "Frame" {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(1, 0),
                        LayoutOrder = 4,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 1)),
                            ForPairs(TagData.dataTypes.objectTags, function(tagName, data)
                                return tagName, TagListener(tagName, data)
                            end, Fusion.cleanup)
                        },
                    }
                }
            })
        }
    }
end

return frame
