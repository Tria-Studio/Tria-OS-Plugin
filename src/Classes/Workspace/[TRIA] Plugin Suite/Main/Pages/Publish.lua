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
local Ref = Fusion.Ref
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Out = Fusion.Out

local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local NoMapsFoundText = Value("No whitelisted maps found.")
local whitelistMapId = Value("")

local selectedPublishMap = Value(nil)

local apiData = {
    apiKey = {
        filtered = Value(""),
        unfiltered = Value(plugin:GetSetting("TRIA_WebserverKey") or "")
    },
    apiTextbox = {
        placeholderTransparency = Value(0),
        filtered = Value(),
        unfiltered = Value()
    },
    submittedApiKey = Value(plugin:GetSetting("TRIA_WebserverKey") ~= nil),
    isShowingApiKey = Value(false)
}

local frame = {}

local function getInfoFrame(name, frames)
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

    local newFrame = New "Frame" {
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
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = [[
    <b>1)</b> Join the TRIA.os Map Manager
        - This can be accessed by joining TRIA.os, and opening the map list and clicking 'Whitelist'
             
    <b>2)</b> In the TRIA.os Map Manager, click on the [ ] tab and generate a TRIA API key for your account
        - NOTE: do <u>NOT</u> share this with anyone.
        - This API key will enable you to remotely whitelist & publish maps. you cannot do this without generating this key.
                        
    <b>3)</b> Below, enter the TRIA Map Key you generated in the Map Manager into the textbox below and click 'Set'
       - NOTE: This key will not be visible to other users in a team create place.
                        
    <b>4)</b> You're all set!
                        ]],
                        DefaultState = false
                    }),

                    Components.Dropdown({
                        Header = "IMPORTANT NOTICE",
                        Text = [[
Your creator token is a long phrase of characters which authenticates and allows you to publish & whitelist maps.
                            
<u><b>DO NOT SHARE YOUR CODE WITH ANYONE</b></u>. Sharing your code with other players will allow them to whitelist/publish maps under your account.
                        ]],
                        DefaultState = true
                    }),

                    getInfoFrame("Map Whitelisting", { --// Whitelisting
                        New "TextBox" { --// Insert Whitelist ID
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 32),
                            PlaceholderColor3 = Theme.DimmedText.Default,
                            TextColor3 = Theme.SubText.Default,
                            PlaceholderText = "Insert map model ID",

                            [Out "Text"] = whitelistMapId
                        },

                        New "Frame" {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            LayoutOrder = 3,

                            [Children] = Components.TextButton({
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                 BorderSizePixel = 2,
                                Position = UDim2.new(0.5, 0, 0.45, 0),
                                Size = UDim2.new(0.4, 0, 0, 24),
                                Text = "Whitelist",

                                Active = Computed(function()
                                    return whitelistMapId:get() ~= ""
                                end),
                                AutoButtonColor = Computed(function()
                                    return whitelistMapId:get() ~= ""
                                end),

                                TextColor3 = Computed(function()
                                    local EnabledColor = Theme.BrightText.Default
                                    local DisabledColor = Theme.SubText.Default

                                    return whitelistMapId:get() ~= "" and EnabledColor:get() or DisabledColor:get()
                                end),
                                BackgroundColor3 = Computed(function()
                                    local EnabledColor = Theme.MainButton.Default
                                    local DisabledColor = Theme.MainButton.Pressed

                                    return whitelistMapId:get() ~= "" and EnabledColor:get() or DisabledColor:get()
                                end),

                                Callback = function()
                                    -- this function will call to whitelist
                                end,

                                Children = Components.Constraints.UICorner(0, 6),
                            })
                        }
                    }),

                    getInfoFrame("Map Publishing", { --// Publishing
                        New "TextLabel" {
                            RichText = true,
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 20),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextColor3 = Theme.MainText.Default,
                            TextWrapped = true,
                            BackgroundTransparency = 1,
                            Text = "Only <b>COMPLETED</b> maps should be published. Publishing sends your map to the map list ingame. <br />"
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
                                            return Components.Constraints.UIGridLayout(UDim2.new(1, 0, 0, publishedMaps[1] == NoMapsFoundText:get() and 40 or 75), UDim2.fromOffset(6, 6))
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
                                                --// GRIF CREATE A MAP FRAME U LAZY NERD
                                                --// https://cdn.discordapp.com/attachments/895042217331261472/1063969336307482704/nerd.png
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
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BorderSizePixel = 2,
                                Position = UDim2.fromScale(0.5, 0.45),
                                Size = UDim2.new(0.4, 0, 0, 24),
                                Text = "Publish",

                                Active = Computed(function()
                                    return selectedPublishMap:get() ~= nil
                                end),
                                AutoButtonColor = Computed(function()
                                    return selectedPublishMap:get() ~= nil
                                end),

                                TextColor3 = Computed(function()
                                    local EnabledColor = Theme.BrightText.Default
                                    local DisabledColor = Theme.SubText.Default

                                    return selectedPublishMap:get() and EnabledColor:get() or DisabledColor:get()
                                end),
                                BackgroundColor3 = Computed(function()
                                    local EnabledColor = Theme.MainButton.Default
                                    local DisabledColor = Theme.MainButton.Pressed

                                    return selectedPublishMap:get() and EnabledColor:get() or DisabledColor:get()
                                end),

                                Callback = function()
                                    -- this function will call to publish
                                end,

                                Children = Components.Constraints.UICorner(0, 6)
                            })
                        }
                    }),

                    getInfoFrame("TRIA Map Creator Key", { --// API Key
                        Components.Dropdown({
                            LayoutOrder = 2,
                            Header = "How This Works",
                            Text = [[
To get your TRIA Map Creator Key, follow the steps at the top of this page. This is where you will enter your TRIA Map Creator Key.

If you generate a new key, your old key will become invalid and you will need to replace it with the new one here.

You cannot whitelist or publish maps without doing this You only need to do this once.
                            ]],
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
                                return if apiData.submittedApiKey:get()
                                    then '<u>Status:</u> <font color="rgb(25,255,0)"> Submitted</font>' 
                                    else '<u>Status:</u> <font color="rgb(255,75,0)"> Not Submitted</font>'
                            end)
                        },

                        New "Frame" { --// Insert API Key
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 4,
                            Size = UDim2.new(1, 0, 0, 32),

                            [Children] = {
                                New "TextButton" { --// Filtered text box
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BackgroundTransparency = 1,
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    Size = UDim2.fromScale(1, 1),

                                    Text = Computed(function()
                                        return apiData.apiKey[apiData.isShowingApiKey:get() and "unfiltered" or "filtered"]:get()
                                    end),
                                    TextTransparency = 0,
                                    TextColor3 = Color3.new(1, 1, 1),

                                    [Ref] = apiData.apiTextbox.filtered,

                                    [OnEvent "Activated"] = function()
                                        apiData.apiTextbox.unfiltered:get():CaptureFocus()
                                    end,

                                    [Children] = {
                                        Components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 22)),
                                        New "TextBox" { --// Hidden text box
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundTransparency = 1,
                                            ClipsDescendants = true,
                                            Position = UDim2.fromScale(0.5, 0.5),

                                            PlaceholderText = "Insert TRIA Map Creator Key",
                                            PlaceholderColor3 = Theme.DimmedText.Default,
                                            TextTransparency = apiData.apiTextbox.placeholderTransparency,

                                            Size = UDim2.fromScale(1, 1),

                                            [Ref] = apiData.apiTextbox.unfiltered,

                                            [OnChange "Text"] = function(newText: string)
                                                local filteredText = string.rep("*", #newText)
                                                apiData.apiKey.filtered:set(filteredText)
                                                apiData.apiKey.unfiltered:set(newText)
                                                apiData.apiTextbox.placeholderTransparency:set(#newText == 0 and 0 or 1)
                                            end,
                                        },
                                        Components.ImageButton({
                                            AutoButtonColor = false,
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            BackgroundTransparency = 1,
                                            Position = UDim2.fromScale(1, 0.5),
                                            Size = UDim2.new(0, 18, 1, 0),
                                            ScaleType = Enum.ScaleType.Fit,
                                            TextColor3 = Theme.BrightText.Default,
            
                                            ImageColor3 = Theme.SubText.Default,
                                            Image = Computed(function()
                                                return if apiData.isShowingApiKey:get() then "rbxassetid://6031075931" else "rbxassetid://6031075929"
                                            end),
                                            Callback = function()
                                                apiData.isShowingApiKey:set(not apiData.isShowingApiKey:get())
                                            end,
                                        })
                                    }
                                }
                            }
                        },

                        New "Frame" {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 30),
                            LayoutOrder = 5,

                            [Children] = {
                                Components.Constraints.UIPadding(UDim.new(0, 4), nil, nil, nil),

                                Components.TextButton({
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BorderSizePixel = 2,
                                    Position = UDim2.fromScale(0.25, 0.45),
                                    Size = UDim2.new(0.4, 0, 0, 24),
                                    Text = "Submit",
    
                                    Active = Computed(function()
                                        return apiData.apiKey.unfiltered:get() ~= ""
                                    end),
                                    AutoButtonColor = Computed(function()
                                        return apiData.apiKey.unfiltered:get() ~= ""
                                    end),
                                    TextColor3 = Computed(function()
                                        local EnabledColor = Theme.BrightText.Default
                                        local DisabledColor = Theme.SubText.Default

                                        return apiData.apiKey.unfiltered:get() ~= "" and EnabledColor:get() or DisabledColor:get()
                                    end),
                                    BackgroundColor3 = Computed(function()
                                        local EnabledColor = Theme.MainButton.Default
                                        local DisabledColor = Theme.MainButton.Pressed

                                        return apiData.apiKey.unfiltered:get() ~= "" and EnabledColor:get() or DisabledColor:get()
                                    end),

                                    Callback = function()
                                        plugin:SetSetting("TRIA_WebserverKey", apiData.apiKey.unfiltered:get())
                                        apiData.submittedApiKey:set(true)
                                    end,

                                    Children = Components.Constraints.UICorner(0, 6)
                                }),

                                Components.TextButton({
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BorderSizePixel = 2,
                                    Position = UDim2.fromScale(0.75, 0.45),
                                    Size = UDim2.new(0.4, 0, 0, 24),
                                    Text = "Remove",
                                   
                                    Active = Computed(function()
                                        return apiData.submittedApiKey:get()
                                    end),
                                    AutoButtonColor = Computed(function()
                                        return apiData.submittedApiKey:get()
                                    end),

                                    TextColor3 = Computed(function()
                                        local EnabledColor = Theme.BrightText.Default
                                        local DisabledColor = Theme.SubText.Default

                                        return apiData.submittedApiKey:get() and EnabledColor:get() or DisabledColor:get()
                                    end),
                                    BackgroundColor3 = Computed(function()
                                        local EnabledColor = Theme.ErrorText.Default
                                        local DisabledColor = Theme.DiffTextDeletionBackground.Default

                                        return apiData.submittedApiKey:get() and EnabledColor:get() or DisabledColor:get()
                                    end),
    
                                    Callback = function()
                                        apiData.apiTextbox.unfiltered:get().Text = ""
                                        plugin:SetSetting("TRIA_WebserverKey", nil)
                                        apiData.submittedApiKey:set(false)
                                    end,

                                    Children = Components.Constraints.UICorner(0, 8)
                                }),
                            }
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

    apiData.apiTextbox.unfiltered:get().Text = apiData.apiKey.unfiltered:get()
    return newFrame
end

return frame
