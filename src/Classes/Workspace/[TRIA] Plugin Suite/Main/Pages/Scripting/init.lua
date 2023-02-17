local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Autocompleter = require(script.Autocompleter)
local GlobalSettings = require(script.Autocompleter.GlobalSettings)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

local frame = {}
 
function OptionFrame(props: PublicTypes.propertiesTable): Instance
    local enabled = Value(props.Enabled)
    if props.OnToggle then
        props.OnToggle(props.Enabled)
    end

    return New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0.125),
        LayoutOrder = props.LayoutOrder,

        [Children] = {
            New "TextButton" {
                Active = Util.interfaceActive,
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
    
                [OnEvent "Activated"] = function()
                    if props.CanCheck then
                        if not props.CanCheck:get(false) then
                            return
                        end
                    end

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
                        LayoutOrder = 2,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.8, 1),
                        Text = props.Text,
                        TextColor3 = props.TextColor3 or Theme.MainText.Default,
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

function frame:GetFrame(data: PublicTypes.propertiesTable): Instance
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
                    Components.FrameHeader("About MapScript", 1, nil, nil, "Basic information about how MapScript works."),
                    New "TextLabel" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(1, 0),
                        RichText = true,
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

                    Components.FrameHeader("About LocalMapScript", 3, nil, nil, "Basic information about how LocalMapScript works."),
                    New "TextLabel" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = 4,
                        Size = UDim2.fromScale(1, 0),
                        RichText = true,
                        Text = [[The LocalMapScript is a client-sided script which runs when players load into the game.
                        
You do not need to use LocalMapScript, however it is useful for creating client-sided effects which will only be seen by ingame players. LocalMapScript does <b>not</b> clone to spectators (unlike EffectScript)]],
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 16,

                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
                        }
                    },

                    Components.FrameHeader("About EffectScript", 5, nil, nil, "Basic information about how EffectScript works."),
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = 6,
                        Size = UDim2.fromScale(1, 0),
                        RichText = true,
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

                    Components.FrameHeader("Script Autocomplete Settings", 7, nil, nil, [[Here you can customise how the script autocompleter works.

You can choose whether to only run the autocompleter inside certain scripts, or to disable/enable the autocompleter fully.]]),
                    
                    New "Frame" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        LayoutOrder = 8,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                            OptionFrame {
                                Text = "Enable Autocomplete",
                                LayoutOrder = 1,
                                Enabled = true,
                                OnToggle = function(newState: boolean)
                                    Autocompleter:toggle(newState)
                                end
                            },
                            OptionFrame {
                                Text = "Run autocomplete globally",
                                LayoutOrder = 1,
                                Enabled = GlobalSettings.runsInAnyScript:get(false),
                                OnToggle = function(newState: boolean)
                                    GlobalSettings.runsInAnyScript:set(newState)
                                end
                            },
                            ForPairs({"MapScript", "LocalMapScript", "EffectScript"}, function(index, value)
                                return index, OptionFrame {
                                    Text = `Run Autocomplete in {value}`,
                                    TextColor3 = Computed(function()
                                        return if GlobalSettings.runsInAnyScript:get() then Theme.ErrorText.Default:get() else Theme.SubText.Default:get()
                                    end),
                                    LayoutOrder = 1 + index,
                                    Enabled = false,
                                    CanCheck = Computed(function()
                                        return not GlobalSettings.runsInAnyScript:get()
                                    end),
                                    OnToggle = function(newState: boolean)
                                        GlobalSettings.runsIn[value] = newState
                                        Autocompleter:toggle(GlobalSettings.enabled)
                                    end
                                }
                            end, Fusion.cleanup)
                        }
                    }
                }
            }
        }
    }
end

return frame
