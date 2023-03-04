local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local PublicTypes = require(Package.PublicTypes)
local Util = require(Package.Util)

local TagListener = require(script.TagListener)
local TagData = require(script.TagData)

local New = Fusion.New
local ForPairs = Fusion.ForPairs
local Children = Fusion.Children
local Computed = Fusion.Computed
local Out = Fusion.Out
local Value = Fusion.Value

local frame = {}
 
function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local objectFrameSize = Value()
    local addonFrameSize = Value()
    local buttonFrameSize = Value()

    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        Visible = data.Visible,
        Name = "ObjectTags",

        [Children] = {
            Components.PageHeader("Object Tags"),
            Components.ScrollingFrame {
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
                            ForPairs(TagData.dataTypes.buttonTags, function(tagName: string, data: PublicTypes.Dictionary): (string, Instance)
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
                            ForPairs(TagData.dataTypes.objectTags, function(tagName: string, data: PublicTypes.Dictionary): (string, Instance)
                                return tagName, TagListener(tagName, data)
                            end, Fusion.cleanup)
                        },
                    },
                    New "Frame" {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Visible = Util._Addons.hasAddonsWithObjectTags,
                        LayoutOrder = 5,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 2)),
                            Components.FrameHeader("Map Addon Tags", 1, nil, nil, "This map has featured map addons in it that support object tags. The instances for those addons can be edited below."),
                            New "Frame" {
                                [Out "AbsoluteSize"] = addonFrameSize,

                                BackgroundTransparency = 1,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Size = Computed(function()
                                    return UDim2.new(1, 0, 0, addonFrameSize:get() and addonFrameSize:get().Y or 0)
                                end),
                                LayoutOrder = 2,

                                [Children] = {
                                    Components.Constraints.UIListLayout(),
                                    ForPairs(TagData.dataTypes.addonTags, function(tagName: string, data: PublicTypes.Dictionary): (string, Instance)
                                        return tagName, TagListener(tagName, data)
                                    end, Fusion.cleanup)
                                },
                            },
                        }
                    },
                    Components.Spacer(false, 6, 24, 1, Theme.MainBackground.Default)
                }
            }
        }
    }
end

return frame
