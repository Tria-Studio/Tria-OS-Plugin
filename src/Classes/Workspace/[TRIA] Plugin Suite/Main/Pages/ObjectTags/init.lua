local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
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

local frame = {}
 
function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        Visible = data.Visible,
        Name = "ObjectTags",

        [Children] = {
            Components.PageHeader("Event & Item Tags"),
            Components.ScrollingFrame {
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.fromOffset(0, 180),
                BackgroundColor3 = Theme.MainBackground.Default,

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 2)),
                    Components.FrameHeader("Button Event Tags", 1),
                    New "Frame" {
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
                    Components.FrameHeader("Event & Item Tags", 3),
                    New "Frame" {
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
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
                                BackgroundTransparency = 1,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Size = UDim2.new(1, 0, 0, 0),
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

function frame.OnOpen()
    Util.objectTagsActive:set(true)

    if not plugin:GetSetting("TRIA_HasViewedObjectTags") then
        plugin:SetSetting("TRIA_HasViewedObjectTags", true)
        Util:ShowMessage("Welcome to Ojbect & Event Tags", "This page allows you to edit the object type of any instance within the map. For example, set a part to be a wallrun, and edit its metadata, etc. and so much more!\n\nUsing a featured addon in your map? Some featured addons support Object Tags!")
    end
end
function frame.OnClose()
    Util.objectTagsActive:set(false)
end


return frame
