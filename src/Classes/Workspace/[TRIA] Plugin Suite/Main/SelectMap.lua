local Fusion = require(script.Parent.Resources.Fusion)
local Theme = require(script.Parent.Resources.Themes)

local State = Fusion.State

local selectMap = {
    selectTextState = State("No map selected"),
    selectTextColor = State(Theme.ErrorText.Default:get())
}

function selectMap:IsTriaMap(Map: Model)
    local score_1 = 0 -- d2
    local score_2 = 0 -- fe2, fp 275, any other fe2 clone thats lazy and uses the fe2 mapkit lol
    local score_3 = 0 -- tria.os
    local hasMapScript, hasSettings, oldMapLib

    --// script check
    local script1: Script? = Map:FindFirstChild("EventScript")
    if script1 and string.find(script1.Source, "workspace.MapTest.GetMapFunctions:Invoke()", 1, true) then
        score_1 += .5
    end
    if script1 and string.find(script1.Source, "workspace.Multiplayer.GetMapVals:Invoke()", 1, true) then
        score_2 += .5
    end

    local script2: Script? = Map:FindFirstChild("MapScript")
    if script2 and (string.find(script2.Source, "game.GetMapLib:Invoke()()", 1, true) or string.find(script2.Source, "ServerStorage.Bindables.GetMapLib:Invoke()()", 1, true)) then
        score_3 += .5
        hasMapScript = true
    end

    --// settings check

    local settings1 = Map:FindFirstChild("MapInfo")
    if settings1 and settings1:FindFirstChild("Lighting")and settings1:FindFirstChild("Audio") and settings1:FindFirstChild("Creator")
     and settings1:FindFirstChild("Difficulty") and settings1:FindFirstChild("MapImage") and settings1:FindFirstChild("MapName") then
        score_1 += .5
     end

     local settings2 = Map:FindFirstChild("Settings")
     if settings2 and settings2:FindFirstChild("Rescue") and settings2:FindFirstChild("BGM") and settings2:FindFirstChild("MaxTime")
     and settings2:FindFirstChild("Difficulty") and settings2:FindFirstChild("MapImage") and settings2:FindFirstChild("MapName") then
        score_2 += .5
     end

     if settings2 and settings2:FindFirstChild("Main") and settings2:FindFirstChild("Lighting")
     and settings2:FindFirstChild("Liquids") and (settings2:FindFirstChild("Button") or settings2:FindFirstChild("Buttons")) then
        score_3 += .5
        hasSettings = true
     end

    --// other checks

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

     if Map:IsA("Model") or Map:IsA("Folder") or Map:IsA("Workspace") then
        if score_1 > .875 or score_2 > 1 then
            return false, "Unknown map type detected. Please make sure this map is a TRIA.os map."
        end

        local OptimizedStructure = Map:FindFirstChild("Special")
        if not Map:FindFirstChild("Spawn") and not (OptimizedStructure and OptimizedStructure:FindFirstChild("Spawn")) then
            return false, "No spawn point found. Add a part named 'Spawn', and add it into the Special folder. "
        end

        if not Map:FindFirstChild("ExitBlock", true) then
            return false, "No ExitRegion found. Add a part named 'ExitBlock', and add it into the Special folder. "
        end

        return score_3 >= 1 and hasMapScript and hasSettings
    end

    return false, "Invalid map model format. Must be a 'Model', 'Folder', or unparented in the workspace."
end

function selectMap:SetMap(Map: Model|Folder|Workspace)
    if Map then -- add or change selection
        selectMap.selectTextState:set(Map.Settings.Main:GetAttribute("Name"))
        selectMap.selectTextColor:set(Theme.MainText.Default:get())
    else --// clear selection
        selectMap.selectTextState:set("No map selected")
        selectMap.selectTextColor:set(Theme.ErrorText.Default:get())
    end
end

function selectMap:AutoSelect()
    local isMap, value = selectMap:IsTriaMap(workspace)

    if isMap then
        selectMap:SetMap(workspace)
        return
    end

    for _, Thing: Instance in pairs(workspace:GetChildren()) do
        if Thing:IsA("Model") or Thing:IsA("Folder") then
            local isMap, value = selectMap:IsTriaMap(Thing)
            if isMap then
                selectMap:SetMap(Thing)
                return
            end
        end
    end
end

return selectMap