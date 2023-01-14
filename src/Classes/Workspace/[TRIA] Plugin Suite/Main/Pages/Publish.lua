local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")

local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed

local NoMapsFoundText = Value("No whitelisted maps found.")
local whitelistMapId = Value("")
local selectedPublishMap = Value(nil)
local apiKey = Value(nil)

local frame = {}

local function GetInfoFrame(name, frames)
    return New "Frame" {
        BackgroundColor3 = Theme.TableItem.Default,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        Size = UDim2.fromScale(1, 0),
        
        [Children] = {
            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 4)),
            Components.ScrollingFrameHeader(name, 1),
            ForValues(frames, function(frame)
                return frame
            end, Fusion.cleanup)
        }
    }
end

function frame:GetFrame(data)
    local publishedMaps = {}

    if #publishedMaps == 0 then
        table.insert(publishedMaps, NoMapsFoundText:get())
    end

    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Publish",

        [Children] = {
            Components.PageHeader("Map Whitelisting & Publishing"),
            Components.ScrollingFrame{
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.MainBackground.Default,

                Children = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 12)),
                    Components.Dropdown({
                        Header = "Setup Instructions",
                        Text = [[
                            1) Join the TRIA.os Map Manager
                            - This can be accessed by joining TRIA.os, and opening the map list and clicking 'Whitelist'
             
                            2) In the TRIA.os Map Manager, click on the [ ] tab and generate a TRIA API key for your account
                                - NOTE: do <u>NOT</u> share this with anyone.
                                - This API key will enable you to remotely whitelist & publish maps. you cannot do this without generating this key.
                        
                            3) Below, enter the TRIA Map Key you generated in the Map Manager into the textbox below and click 'Set'
                                - NOTE: This key will not be visible to other users in a team create place.
                        
                            4) You're all set!
                        ]],
                        DefaultState = false
                    }),

                    Components.Dropdown({
                        Header = "IMPORTANT NOTICE",
                        Text = "Your creator token is a long phrase which authenticates and allows you to publish/whitelist maps. <u><b>DO NOT SHARE YOUR CODE WITH ANYONE</b></u>. Sharing your code with other players will allow them to whitelist/publish maps under your account. Users in a team create place are not able to see & obtain your token",
                        DefaultState = true
                    }),

                    GetInfoFrame("Map Whitelisting", { --// Whitelisting
                        New "TextBox" { --// Insert Whitelist ID
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 32),
                            PlaceholderColor3 = Theme.DimmedText.Default,
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
                    }),

                    GetInfoFrame("Map Publishing", { --// Publishing
                        New "TextLabel" {
                            RichText = true,
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 20),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextColor3 = Theme.MainText.Default,
                            TextWrapped = true,
                            BackgroundTransparency = 1,
                            Text = "Only <b>COMPLETED</b> maps should be published. Publishing sends your map to the map list ingame."
                        },

                        New "Frame" {
                            BackgroundColor3 = Theme.Item.Default,
                            BorderColor3 = Theme.Border.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 3,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Size = UDim2.fromScale(1, 0),

                            [Children] = {
                                Components.Constraints.UIListLayout(),
                                Components.ScrollingFrameHeader("Your Whitelisted Maps:", -1, nil, 20),
                                New "Frame" {
                                    AutomaticSize = Enum.AutomaticSize.Y,
                                    Size = UDim2.fromScale(1, 0),
                                    BackgroundTransparency = 1,

                                    [Children] = {
                                        Computed(function()
                                            return Components.Constraints.UIGridLayout(UDim2.fromOffset(220, publishedMaps[1] == NoMapsFoundText:get() and 40 or 75), UDim2.fromOffset(6, 6)),
                                        end, Fusion.cleanup),
                                        
                                        ForValues(publishedMaps, function(value)
                                            if value == NoMapsFoundText:get() then
                                                return New "TextLabel" {
                                                    Size = UDim2.new(1, 0, 0, 20),
                                                    Text = NoMapsFoundText:get(),
                                                    BackgroundTransparency = 1,
                                                    TextColor3 = Theme.ErrorText.Default,
                                                }
                                            else
                                                --// This will create the actual map frame but im lazy rn
                                            end
                                        end, Fusion.cleanup)
                                    }
                                }
                            }
                        },

                        New "TextLabel" {
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 4,
                            Size = UDim2.new(1, 0, 0, 32),
                            
                            Text = Computed(function()
                                return if selectedPublishMap:get() then selectedPublishMap:get().Name else "No map selected"
                            end),

                            TextColor3 = Computed(function()
                                local selectedColor = Theme.SubText.Default:get()
                                local inactiveColor = Theme.DimmedText.Default:get()
                                return if selectedPublishMap:get() then selectedColor else inactiveColor
                            end)
                        },

                        New "Frame" {
                            BackgroundTransparency = 1,
                            LayoutOrder = 5,
                            Size = UDim2.new(1, 0, 0, 32),

                            [Children] = Components.TextButton({
                                AnchorPoint = Vector2.new(.5, .5),
                                BackgroundColor3 = Theme.MainButton.Default,
                                BorderSizePixel = 2,
                                Position = UDim2.fromScale(0.5, 0.45),
                                Size = UDim2.new(0.4, 0, 0, 24),
                                Text = "Publish",
                                TextColor3 = Theme.BrightText.Default,

                                Callback = function()
                                    -- this function will call to publish
                                end
                            })
                        }
                    }),

                    GetInfoFrame("TRIA Map Creator Key", { --// API Key
                        Components.Dropdown({
                            LayoutOrder = 2,
                            Header = "How This Works",
                            Text = [[To get your TRIA Map Creator Key, follow the steps at the top of this page.

                            This is where you will enter your TRIA Map Creator Key. You must do this in order to use this page otherwise it will not work.]],
                            DefaultState = true
                        }),

                        New "TextLabel" { --// Status
                            RichText = true,
                            LayoutOrder = 3,
                            Size = UDim2.new(1, 0, 0, 20),
                            TextColor3 = Theme.MainText.Default,
                            TextWrapped = true,
                            BackgroundTransparency = 1,
                            Text = Computed(function()
                                return if apiKey:get() 
                                    then '<u>Status:</u> <font color="rgb(25,255,0)"> Submitted</font>' 
                                    else '<u>Status:</u> <font color="rgb(255,75,0)"> Not Submitted</font>'
                            end)
                        },

                        New "TextBox" { --// Insert API Key
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 4,
                            Size = UDim2.new(1, 0, 0, 32),
                            PlaceholderColor3 = Theme.DimmedText.Default,
                            TextColor3 = Theme.SubText.Default,
                            PlaceholderText = "Insert TRIA Map Creator Key"
                        },

                        New "Frame" {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            LayoutOrder = 5,

                            [Children] = Components.TextButton({
                                AnchorPoint = Vector2.new(.5, .5),
                                BackgroundColor3 = Theme.MainButton.Default,
                                BorderSizePixel = 2,
                                Position = UDim2.fromScale(0.5, 0.45),
                                Size = UDim2.new(0.4, 0, 0, 24),
                                Text = "Submit",
                                TextColor3 = Theme.BrightText.Default,

                                Callback = function()
                                    -- this function will call to whitelist
                                end
                            })
                        },
                    }),

                    New "Frame" {
                        Name = "Spacer",
                        BackgroundTransparency = 1,
                        LayoutOrder = 6,
                        Size = UDim2.new(1, 0, 0, 25)
                    }
                }
            }
        }
    }
end

return frame
