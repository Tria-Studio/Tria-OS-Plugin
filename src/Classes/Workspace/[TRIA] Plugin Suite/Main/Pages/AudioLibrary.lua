local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Value = Fusion.Value

local frame = {}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local function AudioButton(data: PublicTypes.Dictionary): Instance
    
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
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
                                        BackgroundTransparency = 0.8,
                                        BackgroundColor3 = Color3.new(1, 0, 0),
                                        Size = UDim2.fromScale(1, 0.925),
                                    },

                                    New "Frame" { -- Page Cycler
                                        BackgroundColor3 = Color3.new(),
                                        BackgroundTransparency = 0.25,
                                        Size = UDim2.fromScale(1, 0.075),
                                        Position = UDim2.fromScale(0, 0.925),

                                        [Children] = {
                                            Components.ImageButton { -- Skip to first page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 1,
                                                Image = "rbxassetid://4458877936",
                                                Rotation = 180,
                                                Position = UDim2.fromScale(0.1, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                            },
                                            
                                            Components.ImageButton { -- Skip one page left
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                Image = "rbxassetid://6031094687",
                                                LayoutOrder = 2,
                                                Rotation = 90,
                                                Position = UDim2.fromScale(0.3, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                            },
                                            
                                            New "TextLabel" {
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 3,
                                                Text = "Page 1/10",
                                                TextColor3 = Theme.TitlebarText.Default,
                                                TextXAlignment = Enum.TextXAlignment.Center,
                                                TextSize = 16,
                                                Position = UDim2.fromScale(0.5, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                            },

                                            Components.ImageButton { -- Skip one page right
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 4,
                                                Image = "rbxassetid://6031094687",
                                                Rotation = -90,
                                                Position = UDim2.fromScale(0.7, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                            },

                                            Components.ImageButton { -- Skip to end page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 5,
                                                Image = "rbxassetid://4458877936",
                                                Position = UDim2.fromScale(0.9, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),

                                                [Children] = Components.Constraints.UIAspectRatio(1),
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
