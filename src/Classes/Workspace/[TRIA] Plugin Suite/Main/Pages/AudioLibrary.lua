local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children

local frame = {}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local function AudioButton(data: PublicTypes.Dictionary): Instance
    
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "ViewModes",

        [Children] = {
            Components.PageHeader("Audio Library"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 1,
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 6)),
                    Components.FrameHeader("About the Audio Library", 1, nil, nil, nil),
                    Components.BasicTextLabel([[The audio library allows map creators to find approved music to use in their maps.
Below you will find a list of audios which have been approved for use by TRIA staff. You can choose to preview the song or automatically set your map's BGM to the selected audio.]], 2),
                    Components.FrameHeader("Audio Library", 3, nil, nil, nil),

                    Components.ScrollingFrame {
                        Size = UDim2.fromScale(1, 0.625),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        LayoutOrder = 4,

                        [Children] = {
                            New "Frame" { -- Audio library
                                AnchorPoint = Vector2.new(0.5, 0),
                                BackgroundTransparency = 0.75,
                                Position = UDim2.fromScale(0.5, 0),
                                Size = UDim2.fromScale(1, 0.875),
                                LayoutOrder = 1,

                                [Children] = {
                                    
                                }
                            },

                            New "Frame" { -- Audio library
                                AnchorPoint = Vector2.new(0.5, 1),
                                BackgroundTransparency = 0.8,
                                Position = UDim2.fromScale(0.5, 1),
                                Size = UDim2.fromScale(1, 0.125),
                                LayoutOrder = 1,

                                [Children] = {
                                    
                                }
                            }
                        }
                    },

                    New "Frame" { -- Refresh Time
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 25),
                        LayoutOrder = 5,

                        [Children] = {
                            New "TextLabel" {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.875, 0.5),
                                Size = UDim2.fromScale(0.25, 1),
                                TextColor3 = Theme.SubText.Default,
                                Text = "Refreshing in 5:00"
                            }
                        }
                    }
                }
            }
        }
    }
end

return frame
