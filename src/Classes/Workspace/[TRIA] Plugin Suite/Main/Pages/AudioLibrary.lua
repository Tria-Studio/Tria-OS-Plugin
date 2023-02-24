local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Value = Fusion.Value
local ForValues = Fusion.ForValues
local Hydrate = Fusion.Hydrate
local Ref = Fusion.Ref

local frame = {}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local MOCK_DATA = {
    {["Name"] = "Test Audio 1", ["ID"] = 123456789, ["Artist"] = "Kris"},
    {["Name"] = "Test Audio 2", ["ID"] = 123456789, ["Artist"] = "Grif"},
    {["Name"] = "Test Audio 3", ["ID"] = 123456789, ["Artist"] = "Ethan"},
    {["Name"] = "Test Audio 4", ["ID"] = 123456789, ["Artist"] = "Umbreon"},
    {["Name"] = "Test Audio 5", ["ID"] = 123456789, ["Artist"] = "Super"}
}

local ITEMS_PER_PAGE = 10

local CURRENT_PAGE_COUNT = Value(1)
local TOTAL_PAGE_COUNT = Value(1)

local function AudioButton(data: PublicTypes.Dictionary): Instance
    return New "TextLabel" {
        Size = UDim2.new(1, 0, 1 / ITEMS_PER_PAGE, -4),
        Text = data.Name,
        TextSize = 18,
        BackgroundTransparency = 0.75
    }
end

local function getAudioChildren(): {Instance}
    local children = {}

    -- MOCK_DATA will be a state object, so we can hook a computed later on.

    for index = 1, #MOCK_DATA, ITEMS_PER_PAGE do 
        table.insert(children, New "Frame" {
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, nil, UDim.new(0, 4)),
                Computed(function()
                    local pageChildren = {}
                    for count = index, index + (ITEMS_PER_PAGE - 1) do
                        if MOCK_DATA[count] then
                            table.insert(pageChildren, AudioButton(MOCK_DATA[count]))
                        end
                    end
                    return pageChildren
                end):get()
            }
        })
    end

    TOTAL_PAGE_COUNT:set(#children)
    return children
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local pageLayout = Value()
    
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 1,
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 2)),
                    Components.FrameHeader("About the Audio Library", 1, nil, nil, nil),
                    Components.BasicTextLabel([[The audio library allows map creators to find approved music to use in their maps.
Below you will find a list of audios which have been approved for use by TRIA staff. You can choose to preview the song or automatically set your map's BGM to the selected audio.]], 2),
                    Components.FrameHeader("Audio Library", 3, nil, nil, nil),

                    New "Frame" { -- Holder
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(1, 0.85),
                        LayoutOrder = 4,

                        [Children] = {
                            New "Frame" { -- Audio Library
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.95),

                                [Children] = {
                                    New "Frame" { -- Main
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(1, 0.925),

                                        [Children] = {
                                            Hydrate(Components.Constraints.UIPageLayout(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, UDim.new(0, 4), Computed(function()
                                                return TOTAL_PAGE_COUNT:get() > 1
                                            end))) {
                                                [Ref] = pageLayout
                                            },

                                            Computed(getAudioChildren)
                                        }
                                    },

                                    New "Frame" { -- Page Cycler
                                        BackgroundColor3 = Color3.new(),
                                        BackgroundTransparency = 0.25,
                                        Size = UDim2.fromScale(1, 0.075),
                                        Position = UDim2.fromScale(0, 0.925),

                                        [Children] = {
                                            Components.ImageButton { -- Skip to first page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 1,
                                                Image = "rbxassetid://4458877936",
                                                Rotation = 180,
                                                Position = UDim2.fromScale(0.1, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):JumpToIndex(0)
                                                    CURRENT_PAGE_COUNT:set(1)
                                                end
                                            },
                                            
                                            Components.ImageButton { -- Skip one page left
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                Image = "rbxassetid://6031094687",
                                                LayoutOrder = 2,
                                                Rotation = 90,
                                                Position = UDim2.fromScale(0.3, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):Previous()

                                                    local currentPage = CURRENT_PAGE_COUNT:get(false)
                                                    CURRENT_PAGE_COUNT:set((currentPage - 1 < 1 and TOTAL_PAGE_COUNT:get(false) or currentPage - 1))
                                                end
                                            },
                                            
                                            New "TextLabel" {
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 3,
                                                Text = Computed(function()
                                                    return ("Page %d/%d"):format(CURRENT_PAGE_COUNT:get(), TOTAL_PAGE_COUNT:get())
                                                end),
                                                TextColor3 = Theme.TitlebarText.Default,
                                                TextXAlignment = Enum.TextXAlignment.Center,
                                                TextSize = 16,
                                                Position = UDim2.fromScale(0.5, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                            },

                                            Components.ImageButton { -- Skip one page right
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 4,
                                                Image = "rbxassetid://6031094687",
                                                Rotation = -90,
                                                Position = UDim2.fromScale(0.7, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),

                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):Next()

                                                    local currentPage = CURRENT_PAGE_COUNT:get(false)
                                                    CURRENT_PAGE_COUNT:set((currentPage + 1 > TOTAL_PAGE_COUNT:get(false) and 1 or currentPage + 1))
                                                end
                                            },

                                            Components.ImageButton { -- Skip to end page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 5,
                                                Image = "rbxassetid://4458877936",
                                                Position = UDim2.fromScale(0.9, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),

                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):JumpToIndex(TOTAL_PAGE_COUNT:get(false) - 1)
                                                    CURRENT_PAGE_COUNT:set(TOTAL_PAGE_COUNT:get(false))
                                                end
                                            }
                                        }
                                    },

                                    New "Frame" { -- Line
                                        BackgroundColor3 = Theme.Border.Default,
                                        Position = UDim2.new(0, 0, 1, -2),
                                        Size = UDim2.new(1, 0, 0, 2)
                                    },
                                }
                            },

                            New "Frame" { -- Refresh time
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.05),
                                Position = UDim2.fromScale(0, 0.95),

                                [Children] = {
                                    New "TextLabel" {
                                        BackgroundTransparency = 1,
                                        Position = UDim2.new(0.5, -4, 0, 0),
                                        Size = UDim2.fromScale(0.5, 1),
                                        Text = "Refreshing in 12:00:00",
                                        TextColor3 = Theme.SubText.Default,
                                        TextXAlignment = Enum.TextXAlignment.Right
                                    },
                                }
                            }
                        }
                    },
                }
            }
        }
    }
end

return frame
