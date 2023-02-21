local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local PublicTypes = require(Package.PublicTypes)

local TagListener = require(script.TagListener)
local TagData = require(script.tagData)

local New = Fusion.New
local ForPairs = Fusion.ForPairs
local Children = Fusion.Children
local Computed = Fusion.Computed
local Out = Fusion.Out
local Value = Fusion.Value

local frame = {}
 
function frame:GetFrame(data: PublicTypes.dictionary): Instance
    local objectFrameSize = Value()
    local buttonFrameSize = Value()

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
                    Components.FrameHeader("Button Event Tags", 1),
                    New "Frame" {
                        [Out "AbsoluteSize"] = buttonFrameSize,

                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        LayoutOrder = 2,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            ForPairs(TagData.dataTypes.buttonTags, function(tagName, data)
                                return tagName, TagListener(tagName, data)
                            end, Fusion.cleanup)
                        },
                    },
                    Components.FrameHeader("Object Tags", 3),
                    New "Frame" {
                        [Out "AbsoluteSize"] = objectFrameSize,

                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = Computed(function()
                            return UDim2.new(1, 0, 0, objectFrameSize:get() and objectFrameSize:get().Y or 0)
                        end),
                        LayoutOrder = 4,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
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
