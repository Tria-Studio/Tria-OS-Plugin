local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Autocompleter = require(script.Autocompleter)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent

local frame = {}

function OptionFrame(props)
    local enabled = Value(props.Enabled)
    if props.OnToggle then
        props.OnToggle(props.Enabled)
    end

    return New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.25),

        [Children] = {
            New "TextButton" {
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
    
                [OnEvent "Activated"] = function()
                    enabled:set(not enabled:get(false))
                    if props.OnToggle then
                        props.OnToggle(enabled:get(false))
                    end
                end,
    
                [Children] = {
                    Components.Checkbox(16, UDim2.new(0, 8, 0.5, 0), Vector2.new(0, 0.5), enabled),
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 2,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.8, 1),
                        Text = props.Text,
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 16,

                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
                        }
                    },
                }
            }
        }
    }
end

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Scripting",

        [Children] = {
            Components.PageHeader("Scripting"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 1,
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                    Components.BasicHeaderText({Text = "About MapScript", LayoutOrder = 1, Tooltip = "Some basic information about how MapScript works."}),
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(1, 0),
                        Text = [[The MapScript is the main script in which most of a maps scripting takes place. 
                        
All maps must have a MapScript in order to be loaded and ran, however not all of a maps scripting needs to be done in the MapScript.]],
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 16,

                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
                        }
                    },

                    Components.BasicHeaderText({Text = "About EffectScript", LayoutOrder = 3, Tooltip = "Some basic information about how EffectScript works."}),
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 4,
                        Size = UDim2.fromScale(1, 0),
                        Text = [[The EffectScript is a localscript which allows your code to be replicated to other spectators.

The EffectScript can communicate with the server using RemoteEvents and gets cloned to the player's PlayerGui.]],
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 16,

                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
                        }
                    },

                    Components.BasicHeaderText({Text = "Script Autocomplete Settings", LayoutOrder = 5, Tooltip = [[Here you can customise how the script autocompleter works.

You can allow certain phrases to be suggested/removed, and can disable/enable the autocompleter fully.

You may also choose whether to only run the autocompleter inside the MapScript.
                    ]]}),

                    New "Frame" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        LayoutOrder = 5,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                            OptionFrame {
                                Text = "Enable Autocomplete",
                                Enabled = true,
                                OnToggle = function(newState: boolean)
                                    Autocompleter:toggle(newState)
                                end
                            }
                        }
                    }
                }
            }
        }
    }
end

return frame
