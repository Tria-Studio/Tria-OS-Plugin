local ChangeHistoryService = game:GetService("ChangeHistoryService")

local plugin = script:FindFirstAncestorWhichIsA("Plugin")
local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local Autocompleter = require(script.Autocompleter)
local GlobalSettings = require(script.Autocompleter.GlobalSettings)

local Observer = Fusion.Observer
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

local localMapScript = Value(false)
local effectScript = Value(false)

local maid = Util.Maid.new()
local mapScripts = Value({})
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
                    enabled:set(not enabled:get(false))

                    if props.Validate then
                        if not props.Validate(enabled) then
                            enabled:set(not enabled:get(false))
                            return
                        end
                    end

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

local function GetScriptButton(state, scriptName, layoutOrder)
   return Components.TextButton {
        Active = Computed(function()
            return not state:get()
        end),
        AutoButtonColor = Computed(function()
            return not state:get()
        end),
        Text = Computed(function()
            return state:get() and string.format("%s already inserted!", scriptName)
                or string.format("Insert %s", scriptName)
        end),
        BackgroundColor3 = Computed(function()
            local ActiveColor = Theme.MainButton.Default:get()
            local DisabledColor = Theme.CurrentMarker.Selected:get()
            return state:get() and DisabledColor
                or ActiveColor
        end),
        TextColor3 = Computed(function()
            return state:get() and Theme.MainText.Default:get()
                or Theme.BrightText.Default:get()
        end),
        Font = Enum.Font.SourceSansSemibold,
        Size = UDim2.new(0, 0, 0, 24),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = layoutOrder,

        [OnEvent "Activated"] = function()
            ChangeHistoryService:SetWaypoint("Inserting TRIA Script")

            Util.attemptScriptInjection()
            if not plugin:GetSetting("TRIA_ScriptInjectionEnabled") then
                Util:ShowMessage("Error", "There was an error while trying to insert the requested script. This may be due to the plugin not having script injection permissions, you can change this in the \"Plugin Settings\" tab.")
            else
                plugin:OpenScript(result)
                ChangeHistoryService:SetWaypoint("Inserted TRIA Script")
            end
        end,
        [Children] = {
            Components.Constraints.UICorner(0, 6),
            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), UDim.new(0, 6))
        },
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
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 6)),
                    Components.FrameHeader("About MapScript", 1, nil, nil, nil),
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

                    Components.FrameHeader("About LocalMapScript", 4, nil, nil, nil),
                    New "TextLabel" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = 5,
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
                    GetScriptButton(localMapScript, "LocalMapScript", 6),

                    Components.FrameHeader("About EffectScript", 7, nil, nil, nil),
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        LayoutOrder = 8,
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
                    GetScriptButton(effectScript, "EffectScript", 9),

                    Components.FrameHeader("Script Autocomplete Settings", 10, nil, nil, [[Here you can customise how the script autocompleter works.

TRIA Autocomplete adds full support for the entire TRIA.os MapLib into the scripting autocomplete menu. Complete with descriptions, code samples, and function arguments.]]),
                    
                    New "Frame" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        LayoutOrder = 11,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6)),
                            OptionFrame {
                                Text = "Enable Autocomplete",
                                LayoutOrder = 1,
                                Enabled = false,
                                Validate = function(newState)
                                    if newState:get(false) == true then
                                        Util.attemptScriptInjection()
                                        if not plugin:GetSetting("TRIA_ScriptInjectionEnabled") then
                                            Util:ShowMessage("Error", "There was an error while trying to initiate autocomplete. This may be due to the plugin not having script injection permissions, you can change this in the \"Plugin Settings\" tab.")
                                            return false
                                        end
                                    end
                                    return true
                                end,

                                OnToggle = function(newState: boolean)
                                    Autocompleter:toggle(newState)
                                end

                            },
                            OptionFrame {
                                Text = "Run autocomplete globally",
                                LayoutOrder = 1,
                                Enabled = GlobalSettings.runsInTriaScripts,
                                OnToggle = function(newState: boolean)
                                    GlobalSettings.runsInTriaScripts = not newState
                                end
                            }
                        }
                    }
                }
            }
        }
    }
end


Observer(mapScripts):onChange(function()
    local children = mapScripts:get()
    local hasEffectScript = false
    local hasLocalMapScript = false

    local function checkScript(Script)
        if not hasLocalMapScript then
            hasLocalMapScript = Script.Name == "LocalMapScript"
        end
        if not hasEffectScript then
            hasEffectScript = Script.Name == "EffectScript"
        end
    end

    for _, child in pairs(children) do
        maid:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(function()
            hasEffectScript = false
            hasLocalMapScript = false

            for _, child in pairs(mapScripts:get()) do
                checkScript(child)
            end

            localMapScript:set(hasLocalMapScript)
            effectScript:set(hasEffectScript)
        end))
        checkScript(child)
    end

    localMapScript:set(hasLocalMapScript)
    effectScript:set(hasEffectScript)
end)

Util.MapChanged:Connect(function()
    localMapScript:set(false)
    effectScript:set(false)

    local Map = Util.mapModel:get()
    if not Map then
        mapScripts:set({})
        maid:DoCleaning()
        return
    end

    task.wait()

    local function updateChildren()
        local newTable = {}
        for _, child in pairs(Map:GetChildren()) do
            if child:IsA("Script") then
                table.insert(newTable, child)
            end
        end

        maid:DoCleaning()
        mapScripts:set(newTable)
    end

    updateChildren()
    Util.MapMaid:GiveTask(Map.ChildAdded:Connect(updateChildren))
    Util.MapMaid:GiveTask(Map.ChildRemoved:Connect(updateChildren))
end)
return frame
