local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Fusion = require(script.Parent.Resources.Fusion)
local Theme = require(script.Parent.Resources.Themes)
local Util = require(script.Parent.Util)
local Pages = require(script.Parent.Resources.Components.Pages)

local Maid = Util.Maid.new()
local State = Fusion.State
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local selectMap = {
    hasOptimizedStructure = State(false),
    selectingMap = State(false),
    selectTextState = State("No map selected"),
    selectTextColor = State(Theme.ErrorText.Default:get()),
    selectCancelColor = State(Theme.SubText.Default:get()),
    selectCancelImage = State("rbxassetid://6022668885")
}

function selectMap:IsTriaMap(Map: Model, ignoreChecks: boolean?)
    local score_1 = 0 -- d2
    local score_2 = 0 -- fe2, fp 275, any other fe2 clone thats lazy and uses the fe2 mapkit lol
    local score_3 = 0 -- tria.os
    local hasMapScript, hasSettings, oldMapLib

    --// script check

    if not ignoreChecks then
        local script1: Script? = Map:FindFirstChild("EventScript")
        if script1 and string.find(script1.Source, "workspace.MapTest.GetMapFunctions:Invoke()", 1, true) then
            score_1 += .5
        end
        if script1 and string.find(script1.Source, "workspace.Multiplayer.GetMapVals:Invoke()", 1, true) then
            score_2 += .5
        end
    end

    local script2: Script? = Map:FindFirstChild("MapScript")
    if script2 and (string.find(script2.Source, "game.GetMapLib:Invoke()()", 1, true) or string.find(script2.Source, "ServerStorage.Bindables.GetMapLib:Invoke()()", 1, true)) then
        score_3 += .5
        hasMapScript = true
    end

    --// settings check

    local settings2 = Map:FindFirstChild("Settings")

    if not ignoreChecks then
        local settings1 = Map:FindFirstChild("MapInfo")
        if settings1 and settings1:FindFirstChild("Lighting")and settings1:FindFirstChild("Audio") and settings1:FindFirstChild("Creator")
        and settings1:FindFirstChild("Difficulty") and settings1:FindFirstChild("MapImage") and settings1:FindFirstChild("MapName") then
            score_1 += .5
        end
    
        if settings2 and settings2:FindFirstChild("Rescue") and settings2:FindFirstChild("BGM") and settings2:FindFirstChild("MaxTime")
        and settings2:FindFirstChild("Difficulty") and settings2:FindFirstChild("MapImage") and settings2:FindFirstChild("MapName") then
            score_2 += .5
        end
    end

     if settings2 and settings2:FindFirstChild("Main") and settings2:FindFirstChild("Lighting")
     and settings2:FindFirstChild("Liquids") and (settings2:FindFirstChild("Button") or settings2:FindFirstChild("Buttons")) then
        score_3 += .5
        hasSettings = true
     end

    --// other checks

    if not ignoreChecks then
        if Map:FindFirstChild("ExitWall") and Map:FindFirstChild("MapPreviewCamera") then
            score_1 += .25
        end
        if Map:FindFirstChild("WalkspeedBooster", true) or Map:FindFirstChild("TeleporterA1", true) and Map:FindFirstChild("TeleporterA2", true) then
            score_1 += .125
        end

        if Map:FindFirstChild("Intro") and Map:FindFirstChild("Intro"):IsA("Model") then
            score_2 += .125
        end
        if Map:FindFirstChild("OST_List") or Map:FindFirstChild("_Variants", true) then
            score_2 += .125
        end
        if Map:FindFirstChild("EndPole", true) and Map:FindFirstChild("EndPole", true):FindFirstChild("RopePiece")
        and Map:FindFirstChild("StartPole", true) and Map:FindFirstChild("StartPole", true):FindFirstChild("RopePiece") then
            score_2 += .125
        end
    end

     if Map:IsA("Model") or Map:IsA("Workspace") then
        if score_1 > .875 or score_2 > 1 then
            return false, "Unknown map type detected. Please make sure this map is a TRIA.os map as this plugin only supports TRIA.os map development."
        end

        if not Map:FindFirstChild("Spawn", true) then
            return false, "No spawn point found. Add a part named 'Spawn', and add it into the Special folder. "
        end

        if not Map:FindFirstChild("ExitBlock", true) then
            return false, "No ExitRegion found. Add a part named 'ExitBlock', and add it into the Special folder. "
        end

        return score_3 >= 1 and hasMapScript and hasSettings
    end

    return false, "Invalid map model format. Must be a 'Model', 'Folder', or unparented in the workspace."
end

function selectMap:SetMap(Map: Model|Workspace)
    print"setting map"
    if Map then -- add or change selection
        local success, message = selectMap:IsTriaMap(Map)

        if not success then
            return false, message
        end

        selectMap.selectCancelColor:set(Theme.ErrorText.Default:get())
        selectMap.selectTextState:set(Map.Settings.Main:GetAttribute("Name"))
        selectMap.selectTextColor:set(Theme.MainText.Default:get())
        Util.mapModel = Map
        Util.MainMaid:DoCleaning()


        local ObjectType = {}

        function ObjectType.Workspace()
            local workspaceUpdate = false
            Util.MainMaid:GiveTask(Map.ChildRemoved:Connect(function(child)
                if not workspaceUpdate and (child.Name == "Settings" or child.Name == "MapScript") then
                    workspaceUpdate = true

                     if not selectMap:IsTriaMap(Map, true) then
                        task.wait()

                        if not selectMap:AutoSelect() then
                            selectMap:SetMap(nil)
                        end
                    end
                    workspaceUpdate = false
                end
            end))
        end

        local parentChanged = false
        function ObjectType.Model()
            Util.MainMaid:GiveTask(Map.AncestryChanged:Connect(function() --// Model was either ungrouped or deleted
				if not Map.Parent then
                    parentChanged = true

	                if not selectMap:AutoSelect() then
	                    selectMap:SetMap(nil)
	                end
				end
            end))
            Util.MainMaid:GiveTask(Map.ChildRemoved:Connect(function(child)
                task.wait()
                if parentChanged then 
                    return 
                end

                if child.Name == "Settings" or child.Name == "MapScript" then
                    if #Map:GetChildren() == 0 and not selectMap:IsTriaMap(Map, true) then
                        if not selectMap:AutoSelect() then
                            selectMap:SetMap(nil)
                            return 
                        end
                    end
                end
            end))
        end

        ObjectType[Map.ClassName]()

        local Option1 = {
            Text = "Read more",
            Callback = function()
                Pages:ChangePage("Compatibility")
            end
        }
        local Option2 = {
            Text = "Got it",
        }
        local optimizedStructure = Map:FindFirstChild("Special")
        selectMap.hasOptimizedStructure:set(optimizedStructure and optimizedStructure:IsA("Folder"))

        if not selectMap.hasOptimizedStructure:get() then
            Util:ShowMessage("Warning", "The selected map does not use the Optimized Structure model. Some features of this plugin may be unavaliable until your map supports Optimized Structure.", Option1, Option2)
        end
        
    else --// clear selection
        Util.mapModel = nil
        selectMap.hasOptimizedStructure:set(false)
        selectMap.selectCancelColor:set(Theme.SubText.Default:get())
        selectMap.selectTextState:set("No map selected")
        selectMap.selectTextColor:set(Theme.ErrorText.Default:get())
    end

    return true
end

function selectMap:StartMapSelection()
    if selectMap:IsTriaMap(workspace) then
        selectMap:SetMap(workspace)
        return
    end

    local currentTarget
    local lastTarget
    local debounce
    local Highlight = Instance.new("Highlight", workspace.CurrentCamera)
    local Mouse = plugin:GetMouse()

    selectMap.selectCancelImage:set("rbxassetid://6031094678")
    selectMap.selectCancelColor:set(Theme.ErrorText.Default:get())
    selectMap.selectTextState:set("Click to select")
    selectMap.selectTextColor:set(Theme.SubText.Default:get())
    Maid:GiveTask(Highlight)
    selectMap.selectingMap:set(true)
    plugin:Activate(true)

    Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
        local target = Mouse.Target

        if target ~= lastTarget then
            lastTarget = target

            repeat
                target = target and target:FindFirstAncestorOfClass("Model")
            until not target or target.Parent == workspace

            if currentTarget == target then
                return
            end

            if target and selectMap:IsTriaMap(target) then
                Highlight.Adornee = target
                currentTarget = target
            else
                Highlight.Adornee = nil
                currentTarget = nil
            end 
        end
    end))

    Maid:GiveTask(Mouse.Button1Down:Connect(function()
        print(selectMap:SetMap(currentTarget))
        selectMap.selectingMap:set(false)
        selectMap.selectCancelImage:set("rbxassetid://6022668885")
        Maid:DoCleaning()
        plugin:Deactivate()
    end))
end

function selectMap:StopManualSelection()
    selectMap.selectingMap:set(false)
    Maid:DoCleaning()
    plugin:Deactivate()

    selectMap.selectCancelImage:set("rbxassetid://6022668885")
    selectMap.selectCancelColor:set(if Util.mapModel then Theme.ErrorText.Default:get() else Theme.SubText.Default:get())
    selectMap.selectTextState:set(if Util.mapModel then Util.mapModel.Settings.Main:GetAttribute("Name") else "No map selected")
    selectMap.selectTextColor:set(if Util.mapModel then Theme.MainText.Default:get() else Theme.ErrorText.Default:get())
end

function selectMap:AutoSelect()
    local isMap, value = selectMap:IsTriaMap(workspace)

    if isMap then
        selectMap:SetMap(workspace)
        return true
    end

    for _, Thing: Instance in pairs(workspace:GetChildren()) do
        if Thing:IsA("Model") then
            local isMap, value = selectMap:IsTriaMap(Thing)
            if isMap then
                selectMap:SetMap(Thing)
                return true
            end
        end
    end
end

return selectMap
