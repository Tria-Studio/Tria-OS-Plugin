--[[
    Issues:
     - [ ] Api key remove button is clickable when no map is selected
]]
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Pages = require(Resources.Components.Pages)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Computed = Fusion.Computed
local Ref = Fusion.Ref
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Out = Fusion.Out
local Spring = Fusion.Spring

local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local noMapsFoundText = Value("No maps found.")
local publishButtonText = Value("Publish Map")
local whitelistMapId = Value("")
local publishedMaps = {}
local whitelistedMaps = {}

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
    playerApiKey = Value(plugin:GetSetting("TRIA_WebserverKey") or ""),
    submittedApiKey = Value(plugin:GetSetting("TRIA_WebserverKey") ~= nil),
    isShowingApiKey = Value(false)
}

local whitelistIdIsEmpty = Computed(function()
    return whitelistMapId:get() ~= ""
end)

local selectedMapToPublishExists = Computed(function()
    return selectedPublishMap:get() ~= nil
end)

local isUnfilteredKeySimilar = Computed(function()
    return apiData.apiKey.unfiltered:get() ~= "" and apiData.apiKey.unfiltered:get() ~= apiData.playerApiKey:get()
end)

local springs = {
    ["selectedMapSpring"] = Spring(Computed(function()
        return selectedPublishMap:get() and Theme.MainButton.Default:get() or Theme.CurrentMarker.Selected:get()
    end), 20),

    ["publishButtonSpring"] = Spring(Computed(function()
        return selectedPublishMap:get() and Theme.BrightText.Default:get() or Theme.SubText.Default:get()
    end), 20),

    ["whitelistMapSpring"] = Spring(Computed(function()
        return whitelistIdIsEmpty:get() and Theme.MainButton.Default:get() or Theme.CurrentMarker.Selected:get()
    end), 20),

    ["whitelistIdSpring"] = Spring(Computed(function()
        return whitelistIdIsEmpty:get() and Theme.BrightText.Default:get() or Theme.SubText.Default:get()
    end), 20),

    ["whitelistedTextSpring"] = Spring(Computed(function()
        return selectedPublishMap:get() and Theme.BrightText.Default:get() or Theme.SubText.Default:get()
    end), 20)
}
 
local frame = {}

local function GetInfoFrame(name: string, frames: {Instance}): Instance
    return New "Frame" {
        BackgroundColor3 = Theme.TableItem.Default,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        Size = UDim2.fromScale(1, 0),
        
        [Children] = {
            Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 4)),
            Components.FrameHeader(name, 1),
            ForValues(frames, function(frame)
                return frame
            end, Fusion.cleanup)
        }
    }
end

local function InfoTextLabel(text: string, layoutOrder: number): Instance
    return New "TextLabel" {
        RichText = true,
        LayoutOrder = layoutOrder,
        Size = UDim2.new(1, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextColor3 = Theme.MainText.Default,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Text = text
    }
end

local function CreateMapList(list: {}, layoutOrder: number): (boolean) -> Instance
    return function(visible)
        return New "Frame" {
            LayoutOrder = layoutOrder,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.fromScale(1, 0),
            BackgroundTransparency = 1,
            Visible = visible,
            Position = UDim2.new(0, 0, 0, 24),

            [Children] = {
                Components.Constraints.UISizeConstraint(nil, Vector2.new(math.huge, 256)),
                Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                
                ForValues(list, function(value)
                    if value == noMapsFoundText:get() then
                        return New "TextLabel" {
                            Size = UDim2.new(1, 0, 0, 32),
                            Text = noMapsFoundText,
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            TextColor3 = Theme.ErrorText.Default,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            Font = Enum.Font.SourceSansSemibold,
                            TextSize = 15,
                            Visible = visible,

                            [Children] = Components.Constraints.UIStroke(1, Color3.new(), Enum.ApplyStrokeMode.Contextual)
                        }
                    else
                        local colorMultiplier = Value(1)
                        return Components.ImageButton {
                            Visible = visible,
                            LayoutOrder = value.ID,
                            Image = value.Image,
                            ScaleType = Enum.ScaleType.Crop,
                            Size = Computed(function()
                                return UDim2.new(1, 0, 0, publishedMaps[1] == noMapsFoundText:get() and 40 or 75)
                            end),
                            ImageColor3 = Spring(Computed(function()
                                return Color3.new(colorMultiplier:get(), colorMultiplier:get(), colorMultiplier:get())
                            end), 20),

                            [OnEvent "MouseEnter"] = function()
                                colorMultiplier:set(0.7)
                            end,
                            [OnEvent "MouseButton1Down"] = function()
                                colorMultiplier:set(1.15)

                            end,
                            [OnEvent "MouseButton1Up"] = function()
                                colorMultiplier:set(0.7)
                                selectedPublishMap:set(value)
                                publishButtonText:set(list == whitelistedMaps and "Publish Map" or "Update Map")
                            end,
                            [OnEvent "MouseLeave"] = function()
                                colorMultiplier:set(1)
                            end,

                            [Children] = New "Frame" {
                                BackgroundColor3 = Color3.new(0, 0, 0),
                                BackgroundTransparency = 0.625,
                                Position = UDim2.fromScale(0, 1),
                                Size = UDim2.new(1, 0, 0, 34),
                                AnchorPoint = Vector2.new(0, 1),

                                [Children] = {
                                    New "TextLabel" { --// Map Name
                                        Text = value.Name,
                                        AnchorPoint = Vector2.new(0.5, 0),
                                        BackgroundTransparency = 1,
                                        Position = UDim2.fromScale(0.5, 0.45),
                                        Size = UDim2.new(0, 110, 0.55, 0),
                                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
                                        TextSize = 18,
                                        TextColor3 = Spring(Computed(function()
                                            return Color3.fromRGB(204 * colorMultiplier:get(), 204 * colorMultiplier:get(), 204 * colorMultiplier:get())
                                        end), 20)
                                    },
                                    New "TextLabel" { --// Difficulty
                                        Text = string.format("[%s]", Util.Difficulty[value.Difficulty].Name),
                                        AnchorPoint = Vector2.new(0.5, 0),
                                        BackgroundTransparency = 1,
                                        Position = UDim2.fromScale(0.5, 0),
                                        Size = UDim2.new(0, 110, 0.45, 0),
                                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold),
                                        TextStrokeColor3 = Theme.Border.Default,
                                        TextStrokeTransparency = 0,
                                        TextColor3 = Spring(Computed(function()
                                            local Color = Util.Difficulty[value.Difficulty].Color
                                            return Color3.new(Color.R * colorMultiplier:get(), Color.G * colorMultiplier:get(), Color.B * colorMultiplier:get())
                                        end), 20)
                                    },
                                    New "ImageLabel" {--// Difficulty Icon
                                        BackgroundTransparency = 1,
                                        Position = UDim2.new(1, -34, 0, 4),
                                        Size = UDim2.fromOffset(26, 26),
                                        Image = Util.Difficulty[value.Difficulty].Image,
                                        ImageColor3 = Spring(Computed(function()
                                            return Color3.new(colorMultiplier:get(), colorMultiplier:get(), colorMultiplier:get())
                                        end), 20)
                                    }
                                }
                            }
                        }
                    end
                end, Fusion.cleanup)
            }
        }
    end
end

function frame.OnClose()
    publishButtonText:set("Publish Map")
    selectedPublishMap:set(nil)
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    if #whitelistedMaps == 0 then
        table.insert(whitelistedMaps, noMapsFoundText:get())
    end
    if #publishedMaps == 0 then
        table.insert(publishedMaps, noMapsFoundText:get())
    end

    local newFrame = New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Publish",

        [Children] = {
            Components.PageHeader("Map Whitelisting & Publishing"),
            Components.ScrollingFrame({
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.MainBackground.Default,

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 12)),
                    New "Frame" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            Components.Dropdown({
                                Header = "Setup Instructions",
                                DefaultState = false
                            }, function(visible)
                                return Components.DropdownTextlabel {
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    DropdownVisible = visible,
                                    Text = [[
<b>1)</b> Join the TRIA.os Map Manager
    - This can be accessed by joining TRIA.os, and opening the map list and clicking 'Whitelist'
                     
<b>2)</b> In the TRIA.os Map Manager, click on the [ ] tab and generate a TRIA API key for your account
    - NOTE: Do <u>NOT</u> share this with anyone.
    - This API key will enable you to remotely whitelist & publish maps. you cannot do this without generating this key.
                                
<b>3)</b> Below, enter the TRIA Map Key you generated in the Map Manager into the textbox below and click 'Set'
    - NOTE: This key will not be visible to other users in a team create place.
                                
<b>4)</b> You're all set!
                                ]]
                                }
                            end, true),
        
                            Components.Dropdown({
                                Header = "IMPORTANT NOTICE",
                                DefaultState = true
                            }, function(visible)
                                return Components.DropdownTextlabel {
                                    DropdownVisible = visible,
                                    Text = [[Your creator token is a long phrase of characters which authenticates and allows you to publish & whitelist maps.

<u><b>DO NOT SHARE YOUR CODE WITH ANYONE</b></u>. Sharing your code with other players will allow them to whitelist/publish maps under your account.
                                ]]
                                }
                            end, true),
                        }
                    },

                    GetInfoFrame("Map Whitelisting", { --// Whitelisting
                        Components.TextBox { --// Insert Whitelist ID
                            LayoutOrder = 2,
                            Size = UDim2.new(1, 0, 0, 32),
                            TextSize = 16,
                            PlaceholderText = "Insert map model ID",

                            [Out "Text"] = whitelistMapId
                        },

                        Components.TextButton {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BorderSizePixel = 2,
                            LayoutOrder = 3,
                            Position = UDim2.new(0.5, 0, 0.45, 0),
                            Size = UDim2.new(0.4, 0, 0, 24),
                            Text = "Whitelist Map",

                            Active = whitelistIdIsEmpty,
                            AutoButtonColor = whitelistIdIsEmpty,

                            TextColor3 = springs.whitelistIdSpring,
                            BackgroundColor3 = springs.whitelistMapSpring,

                            [OnEvent "Activated"] = function()
                                 -- this function will call to whitelist
                            end,

                            [Children] = Components.Constraints.UICorner(0, 6),
                        }
                    }),

                    GetInfoFrame("Map Publishing", { --// Publishing
                        InfoTextLabel("Only <b>COMPLETED</b> maps should be published. Publishing sends your map to the map list ingame.\n ", 2),
                        
                        New "TextLabel" {
                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                            BorderColor3 = Theme.InputFieldBorder.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 4,
                            Font = Enum.Font.SourceSansBold,
                            TextSize = 16,
                            Size = UDim2.new(1, 0, 0, 32),
                            Text = Computed(function()
                                return if selectedPublishMap:get() then selectedPublishMap:get().Name else "No map selected"
                            end),
                            TextColor3 = springs.whitelistedTextSpring,

                            [Children] = Components.ImageButton {
                                AnchorPoint = Vector2.new(1, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.new(1, -4, 0.5, 0),
                                Size = UDim2.new(0, 18, 1, 0),
                                ScaleType = Enum.ScaleType.Fit,

                                ImageColor3 = Theme.SubText.Default,
                                Image = "rbxassetid://6022668885",

                                [OnEvent "Activated"] = function()
                                    selectedPublishMap:set(nil)
                                    publishButtonText:set("Publish Map")
                                end,
                            }
                        },

                        Components.TextButton {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BorderSizePixel = 2,
                            LayoutOrder = 5,
                            Position = UDim2.fromScale(0.5, 0.45),
                            Size = UDim2.new(0.4, 0, 0, 24),
                            Text = publishButtonText,

                            Active = selectedMapToPublishExists,
                            AutoButtonColor = selectedMapToPublishExists,

                            TextColor3 = springs.publishButtonSpring,
                            BackgroundColor3 = springs.selectedMapSpring,

                            [OnEvent "Activated"] = function()
                                 -- this function will call to publish
                            end,

                            [Children] = Components.Constraints.UICorner(0, 6)
                        },

                        New "Frame" {
                            BackgroundColor3 = Theme.Item.Default,
                            BorderColor3 = Theme.Border.Default,
                            BorderSizePixel = 1,
                            LayoutOrder = 6,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Size = UDim2.fromScale(1, 0),

                            [Children] = {
                                Components.Constraints.UIListLayout(),
                                Components.Dropdown({
                                    DefaultState = true,
                                    Header = "Your Whitelisted Maps:",
                                    LayoutOrder = 2
                                }, CreateMapList(whitelistedMaps, 2), true),

                                Components.Dropdown({
                                    DefaultState = true,
                                    Header = "Your Published Maps:",
                                    LayoutOrder = 4
                                }, CreateMapList(publishedMaps, 4), true),
                            }
                        },
                    }),

                    GetInfoFrame("TRIA Map Creator Key", { --// API Key
                        InfoTextLabel("Your TRIA Map Creator Key is required to publish maps. This allows the game to authenticate you.\n", 1),
                        
                        Components.Dropdown({
                            LayoutOrder = 2,
                            Header = "How This Works",
                            DefaultState = true
                        }, function(visible)
                            return Components.DropdownTextlabel {
                                DropdownVisible = visible,
                                Text = [[
To get your TRIA Map Creator Key, follow the steps at the top of this page. This is where you will enter your Map Creator Key.

If you generate a new key, your old key will become invalid and you will need to replace it with the new one.]],
                            }
                        end, true),

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

                                    TextSize = 16,
                                    TextTransparency = 0,
                                    TextColor3 = Theme.BrightText.Default,
                                    Text = Computed(function()
                                        return apiData.apiKey[apiData.isShowingApiKey:get() and "unfiltered" or "filtered"]:get()
                                    end),

                                    [Ref] = apiData.apiTextbox.filtered,

                                    [OnEvent "Activated"] = function()
                                        apiData.apiTextbox.unfiltered:get(false):CaptureFocus()
                                    end,

                                    [Children] = {
                                        Components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 22)),
                                       
                                        Components.TextBox({ --// Hidden text box
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            BackgroundTransparency = 1,
                                            ClipsDescendants = true,
                                            ClearTextOnFocus = false,
                                            Position = UDim2.fromScale(0.5, 0.5),

                                            PlaceholderText = "Insert TRIA Map Creator Key",
                                            TextTransparency = apiData.apiTextbox.placeholderTransparency,

                                            Size = UDim2.fromScale(1, 1),

                                            [OnChange "Text"] = function(newText: string)
                                                local filteredText = string.rep("*", #newText)
                                                apiData.apiKey.filtered:set(filteredText)
                                                apiData.apiKey.unfiltered:set(newText)
                                                apiData.apiTextbox.placeholderTransparency:set(#newText == 0 and 0 or 1)
                                            end,

                                            [Ref] = apiData.apiTextbox.unfiltered
                                        }),

                                        Components.ImageButton {
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            BackgroundTransparency = 1,
                                            Position = UDim2.fromScale(1, 0.5),
                                            Size = UDim2.new(0, 18, 1, 0),
                                            ScaleType = Enum.ScaleType.Fit,
            
                                            ImageColor3 = Theme.SubText.Default,
                                            Image = Computed(function()
                                                return if apiData.isShowingApiKey:get() then "rbxassetid://6031075931" else "rbxassetid://6031075929"
                                            end),

                                            [OnEvent "Activated"] = function()
                                                apiData.isShowingApiKey:set(not apiData.isShowingApiKey:get(false))
                                            end,
                                        } 
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

                                Components.TextButton {
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BorderSizePixel = 2,
                                    Position = UDim2.fromScale(0.26, 0.45),
                                    Size = UDim2.new(0.4, 0, 0, 24),
                                    Text = "Submit",
                                    Active = isUnfilteredKeySimilar,
                                    AutoButtonColor = isUnfilteredKeySimilar,
                                    TextColor3 = Spring(Computed(function()
                                        return if isUnfilteredKeySimilar:get()
                                            then Theme.BrightText.Default:get()
                                            else Theme.SubText.Default:get()
                                    end), 20),
                                    BackgroundColor3 = Spring(Computed(function()
                                        return if isUnfilteredKeySimilar:get()
                                            then Theme.MainButton.Default:get() 
                                            else Theme.CurrentMarker.Selected:get()
                                    end), 20),

                                    [OnEvent "Activated"] = function()
                                        plugin:SetSetting("TRIA_WebserverKey", apiData.apiKey.unfiltered:get(false))
                                        apiData.submittedApiKey:set(true)
                                        apiData.playerApiKey:set(apiData.apiKey.unfiltered:get(false))
                                    end,

                                    [Children] = Components.Constraints.UICorner(0, 6)
                                },

                                Components.TextButton {
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    BorderSizePixel = 2,
                                    Position = UDim2.fromScale(0.73, 0.45),
                                    Size = UDim2.new(0.4, 0, 0, 24),
                                    Text = "Remove",

                                    Active = apiData.submittedApiKey,
                                    AutoButtonColor = apiData.submittedApiKey,

                                    TextColor3 = Spring(Computed(function()
                                        return if apiData.submittedApiKey:get()
                                            then Theme.BrightText.Default:get() 
                                            else Theme.SubText.Default:get()
                                    end), 20),
                                    BackgroundColor3 = Spring(Computed(function()
                                        return if apiData.submittedApiKey:get() 
                                            then Theme.ErrorText.Default:get() 
                                            else Theme.DiffTextDeletionBackground.Default:get()
                                    end), 20),
    
                                    [OnEvent "Activated"] = function()
                                        apiData.apiTextbox.unfiltered:get(false).Text = ""
                                        plugin:SetSetting("TRIA_WebserverKey", nil)
                                        apiData.submittedApiKey:set(false)
                                    end,

                                    [Children] = Components.Constraints.UICorner(0, 8)
                                },
                            }
                        },
                    }),
                    
                    New "Frame" {
                        BackgroundTransparency = 1,
                        LayoutOrder = 6,
                        Size = UDim2.new(1, 0, 0, 25)
                    }
                }
            }, true)
        }
    }

    apiData.apiTextbox.unfiltered:get(false).Text = apiData.apiKey.unfiltered:get(false)
    return newFrame
end

function frame.OnOpen()
    Util:ShowMessage(Util._Headers.WIP_HEADER, "This page is a work in progress and is currently unavailable until a future update, don't worry, we're working hard behind the scenes to get it done as quick as possible!", {
        Text = "Go Back",
        Callback = function()
            Pages:ChangePage(Pages.pageData.previousPage:get(false) or "ObjectTags")
        end
    })
end

return frame
