local ContentProvider = game:GetService("ContentProvider")
local Fusion = require(script.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Resources.Components)

local New = Fusion.New
local Children = Fusion.Children
local ComputedPairs = Fusion.ComputedPairs
local State = Fusion.State

local whitelistMapId = State("")
local selectedPublishMap = State("")



local frame = {}

local function GetInfoFrame(name, frames)
    return New "Frame" {
        BackgroundColor3 = Theme.TableItem.Default,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, 0),
        
        [Children] = {
            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 4)),
            Components.ScrollingFrameHeader(name, 1),
            ComputedPairs(frames, function(_, frame)
                return frame
            end)
        }
    }
end

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Publish",

        [Children] = {
            Components.PageHeader("Map Whitelisting & Publishing"),
            Components.ScrollingFrame{
                Size = UDim2.new(1, 0, 1, 0),

                Children = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                    Components.Dropdown({
                        Header = "Setup Instructions",
                        Text = 
            [[1) Join the TRIA.os Map Manager
                     - This can be accessed by joining TRIA.os, and opening the map list and clicking 'Whitelist'
             
             2) In the TRIA.os Map Manager, click on the [ ] tab and generate a TRIA API key for your account
                     - NOTE: do <u>NOT</u> share this with anyone.
                     - This API key will enable you to remotely whitelist & publish maps. you cannot do this without generating this key.
             
             3) Below, enter the TRIA Map Key you generated in the Map Manager into the textbox below and click 'Set'
                     - NOTE: This key will not be visible to other users in a team create place.
             
             4) Your'e all set!]],
                        DefaultState = false
                    }),
                    Components.Dropdown({
                        Header = "IMPORTANT NOTICE",
                        Text = "Your creator token is a long phrase which authenticates and allows you to publish/whitelist maps. <u><b>DO NOT SHARE YOUR CODE WITH ANYONE</b></u>. Sharing your code with other players will allow them to whitelist/publish maps under your account. Users in a team create place are not able to see & obtain your token",
                        DefaultState = true
                    }),
                    GetInfoFrame("Map Whitelisting", {
                        New "TextBox" { --// Insert Whitelist ID
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 32),
                            PlaceholderColor3 = Theme.InfoText.Default,
                            TextColor3 = Theme.SubText.Default,
                            PlaceholderText = "Map Model ID"
                        },
                        New "Frame" {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            LayoutOrder = 3,

                            [Children] = Components.TextButton({
                                AnchorPoint = Vector2.new(.5, .5),
                                BackgroundColor3 = Theme.MainButton.Default,
                                BorderSizePixel = 2,
                                Position = UDim2.new(0.5, 0, 0.45, 0),
                                Size = UDim2.new(0.4, 0, 0, 24),
                                Text = "Whitelist",
                                TextColor3 = Theme.BrightText.Default,

                                Callback = function()
                                    -- this function will call to whitelist
                                end
                            })
                        }

                    })
                }
            }
        }
    }
end

return frame
