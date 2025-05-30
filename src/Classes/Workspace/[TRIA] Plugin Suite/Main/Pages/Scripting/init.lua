local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Players = game:GetService("Players")
local ScriptEditorService = game:GetService("ScriptEditorService")

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
local Computed = Fusion.Computed

local ENABLE_VAR = "TRIA_AutocompleteEnabled"
local GLOBAL_ENABLE_VAR = "TRIA_GlobalAutocompleteEnabled"
local GLOBAL_INJECT_VAR = "TRIA_GlobalAutocompleteEnabled"
local HEADER = 'require(game:GetService("ServerScriptService").Runtime):Init()\n'

local ScriptMaid = Util.Maid.new()

local mapScripts = Value({})
local hasScripts = {
    LocalMapScript = Value(false),
    EffectScript = Value(false)
}

local frame = {}

local function OptionFrame(props: PublicTypes.Dictionary): Instance
    local enabled = Value(props.Enabled)
    if props.OnToggle then
        props.OnToggle(props.Enabled)
    end

    return New "Frame" {
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.TableItem.Default,
        Size = UDim2.new(1, 0, 0, 20),
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
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Position = UDim2.new(0, 30, 0.5, 0),
                        Size = UDim2.fromScale(0.75, 1),
                        Text = props.Text,
                        TextColor3 = props.TextColor3 or Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        TextSize = 16,

                        [Children] = {
                            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
                        }
                    },
                    Components.TooltipImage {
                        Position = UDim2.new(1, -4, 0, 2),
                        Header = props.Tooltip.Header,
                        Tooltip = props.Tooltip.Tooltip
                    }
                }
            }
        }
    }
end

local function GetScriptButton(state: Fusion.StateObject<boolean>, scriptName: string, layoutOrder: number): Instance
    local activeState = Computed(function(): boolean
        return not state:get() and Util.interfaceActive:get()
    end)
    return New "Frame" {
        BackgroundColor3 = Theme.TableItem.Default,
        Size = UDim2.new(1, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = layoutOrder,

        [Children] = Components.TextButton {
            Active = activeState,
            AutoButtonColor = activeState,
            Text = Computed(function(): string
                return state:get() 
                    and string.format("%s already inserted!", scriptName)
                    or string.format("Insert %s", scriptName)
            end),
            BackgroundColor3 = Computed(function(): Color3
                return state:get() 
                    and Theme.CurrentMarker.Selected:get()
                    or Theme.MainButton.Default:get()
            end),
            TextColor3 = Computed(function(): Color3
                return state:get() 
                    and Theme.MainText.Default:get()
                    or Theme.BrightText.Default:get()
            end),
            Font = Enum.Font.SourceSansSemibold,
            Size = UDim2.new(0, 0, 0, 24),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AutomaticSize = Enum.AutomaticSize.X,
    
            [OnEvent "Activated"] = function()
                if Util.failedScriptInjection(Util._Errors.SCRIPT_INSERT_ERROR) then
                    return;
                end
    
                local recording = ChangeHistoryService:TryBeginRecording("InsertScript", "Inserting TRIA Script")
                if recording then
                    
                    local currentMap = Util.mapModel:get(false)
    
                    local newScript = Instance.new("LocalScript")
                    newScript.Name = scriptName
                    newScript.Source = "local MapLib = game.GetMapLib:Invoke()()\nlocal map = MapLib.map" .. (scriptName == "EffectScript" and "\n\n-- For more information and examples on how EffectScript works, visit:\n-- https://github.com/Tria-Studio/Tria-OS-Docs/blob/main/EffectScript.md")
                    newScript.Enabled = false
                    newScript.Parent = currentMap
        
                    plugin:OpenScript(newScript)

                    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
                end
            end,
            [Children] = {
                Components.Constraints.UICorner(0, 6),
                Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), UDim.new(0, 6))
            },
        }
    }
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "Scripting",

        [Children] = {
            Components.PageHeader("Map Scripting"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.TableItem.Default,
                Size = UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center),
                    Components.FrameHeader("About MapScript", 1, nil, nil, nil),
                    Components.Spacer(false, 2, 6, nil),
                    Components.BasicTextLabel([[The MapScript is the main script in which most of a maps functionallity happens.
                    
You can have as many scripts as you want, but you must have a main MapScript. The MapScript is required to allow maps to load and run.]], 3, Theme.TableItem.Default),
                    Components.Spacer(false, 4, 6, nil),

                    Components.FrameHeader("About LocalMapScript", 5, nil, nil, nil),
                    Components.Spacer(false, 6, 6, nil),
                    Components.BasicTextLabel([[The LocalMapScript is a client-sided script which runs when players load into the game.

You do not need to use LocalMapScript, however it is useful for creating client-sided effects which will only be seen by ingame players. LocalMapScript does <b>NOT</b> replicate to spectators.]], 7, Theme.TableItem.Default),
                    Components.Spacer(false, 8, 9, nil),

                    GetScriptButton(hasScripts.LocalMapScript, "LocalMapScript", 9),
                    Components.Spacer(false, 10, 3, nil),

                    Components.FrameHeader("About EffectScript", 11, nil, nil, nil),
                    Components.Spacer(false, 12, 6, nil),
                    Components.BasicTextLabel([[The EffectScript is a localscript which allows your code to be replicated to other spectators, which will provide a better experience for players spectating your map.

EffectScript communicates with the server / MapScript using RemoteEvents and gets cloned to the player's PlayerGui, meaning that it does not get deleted when the player dies.]], 13, Theme.TableItem.Default),
                    Components.Spacer(false, 14, 9, nil),

                    GetScriptButton(hasScripts.EffectScript, "EffectScript", 15),
                    Components.Spacer(false, 16, 3, nil),

                    Components.FrameHeader("Script Autocomplete Settings", 17, nil, nil, [[Here you can customise how the script autocompleter works.

TRIA Autocomplete adds full support for the entire TRIA.os MapLib into the scripting autocomplete menu. Complete with descriptions, code samples, and function arguments.]]),
                    
                    Components.Spacer(false, 18, 6, nil),
                    New "Frame" {
                        BackgroundColor3 = Theme.TableItem.Default,
                        Size = UDim2.new(1, 0, 0, 52),
                        LayoutOrder = 19,

                        [Children] = {
                            Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 6), Enum.VerticalAlignment.Center),
                            OptionFrame {
                                Text = "Enable Autocomplete",
                                LayoutOrder = 1,
                                Enabled = 
                                    if plugin:GetSetting(ENABLE_VAR) and plugin:GetSetting("TRIA_ScriptInjectionEnabled") 
                                    then plugin:GetSetting(ENABLE_VAR) 
                                    else true,
                                
                                Validate = function(newState: Fusion.StateObject<boolean>): boolean
                                    if newState:get(false) == true then
                                        return not Util.failedScriptInjection(Util._Errors.AUTOCOMPLETE_ERROR)
                                    end
                                    return true
                                end,

                                OnToggle = function(newState: boolean)
                                    if plugin:GetSetting("TRIA_ScriptInjectionEnabled") then
                                        Autocompleter:toggle(newState)
                                        plugin:SetSetting(ENABLE_VAR, newState)
                                    end
                                end,

                                Tooltip = {
                                    Header = "Autocomplete",
                                    Tooltip = "Determines whether or not Autocomplete for the TRIA.os MapLib will suggest functions and properties when scripting your map."
                                }

                            },
                            OptionFrame {
                                Text = "Run autocomplete globally",
                                LayoutOrder = 3,
                                Enabled = 
                                    if plugin:GetSetting(GLOBAL_ENABLE_VAR) 
                                    then plugin:GetSetting(GLOBAL_ENABLE_VAR) 
                                    else true,
                                    
                                OnToggle = function(newState: boolean)
                                    GlobalSettings.runsInTriaScripts = not newState
                                    plugin:SetSetting(GLOBAL_ENABLE_VAR, newState)
                                end,

                                Tooltip = {
                                    Header = "Global Autocomplelte",
                                    Tooltip = "Determines whether or not Autocomplete will happen in TRIA scripts (MapScript, LocalMapScript, EffectScript) or any script in your map."
                                }
                            },
                            OptionFrame {
                                Text = "Automatic Runtime Injection",
                                LayoutOrder = 3,
                                Enabled = 
                                    if plugin:GetSetting(GLOBAL_INJECT_VAR) 
                                    then plugin:GetSetting(GLOBAL_INJECT_VAR) 
                                    else true,
                                    
                                OnToggle = function(newState: boolean)
                                    GlobalSettings.autoInjectRuntime = not newState
                                    plugin:SetSetting(GLOBAL_INJECT_VAR, newState)
                                end,

                                Tooltip = {
                                    Header = "Runtime Injection",
                                    Tooltip = "When enabled, every script inside your map will automatically have the runtime header put at the top of it if it does not have it."
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

local function DoRuntimeCheck(script: LuaSourceContainer)
    if #Players:GetPlayers() > 1 or not GlobalSettings.autoInjectRuntime then
        return
    end
    task.delay(0.5, ScriptEditorService.UpdateSourceAsync, ScriptEditorService, script, function(old)
        if string.sub(old, 1, #HEADER) ~= HEADER then
            return HEADER .. '\n' .. old
        end
        return old
    end)
end

Observer(mapScripts):onChange(function()
    local children = mapScripts:get(false)
    local scripts = {
        LocalMapScript = false,
        EffectScript = false
    }

    local function checkScript(newScript: Instance)
        for k in pairs(scripts) do
            if not scripts[k] then
                scripts[k] = newScript.Name == k
            end
        end
    end

    for _, child in pairs(children) do
        ScriptMaid:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(function()
            for k in pairs(scripts) do
                scripts[k] = false
            end

            for _, child in pairs(mapScripts:get()) do
                checkScript(child)
            end

            for k in pairs(hasScripts) do
                hasScripts[k]:set(scripts[k])
            end
        end))
        checkScript(child)
    end

    for k in pairs(hasScripts) do
        hasScripts[k]:set(scripts[k])
    end
end)

local connections = {}
Util.MapChanged:Connect(function()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    table.clear(connections)

    for k in pairs(hasScripts) do
        hasScripts[k]:set(false)
    end

    local newMap = Util.mapModel:get(false)
    if not newMap then
        mapScripts:set({})
        ScriptMaid:DoCleaning()
        return
    end

    task.wait()

    local function updateChildren(doRuntime)
        local newTable = {}
        for _, child in pairs(newMap:GetChildren()) do
            if child:IsA("Script") then
                table.insert(newTable, child)
            end
            if doRuntime and child:IsA("LuaSourceContainer") then
                DoRuntimeCheck(child)
            end
        end

        ScriptMaid:DoCleaning()
        mapScripts:set(newTable)
    end

    updateChildren(true)
    local connection1 = newMap.ChildAdded:Connect(updateChildren)
    local connection2 = newMap.ChildRemoved:Connect(updateChildren)
    local connection3 = newMap.DescendantAdded:Connect(function(newThing: Instance)
        if newThing:IsA("LuaSourceContainer") then
            task.wait()
            DoRuntimeCheck(newThing)
        end
    end)

    table.insert(connections, connection1)
    table.insert(connections, connection2)
    table.insert(connections, connection3)
end)

return frame
