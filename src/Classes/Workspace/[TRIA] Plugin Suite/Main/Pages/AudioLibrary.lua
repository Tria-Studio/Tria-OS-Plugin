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
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 2)),
                    Components.FrameHeader("About the Audio Library", 1, nil, nil, nil),
                    Components.BasicTextLabel([[The audio library allows map creators to find approved music to use in their maps.
Below you will find a list of audios which have been approved for use by TRIA staff. You can choose to preview the song or automatically set your map's BGM to the selected audio.]], 2),
                    Components.FrameHeader("Audio Library", 3, nil, nil, nil),

                    New "Frame" { -- Holder
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                        BackgroundTransparency = 0.5,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(1, 0.5),
                        LayoutOrder = 4,

                        [Children] = {
                            New "Frame" { -- Holder
                                
                            }
                        }
                    },
                }
            }
        }
    }
end

return frame
