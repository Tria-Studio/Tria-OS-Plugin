local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Pages = require(Resources.Components.Pages)

local Util = require(Package.Util)

local Value = Fusion.Value
local Computed = Fusion.Computed
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local MapSelect = {
    _Maid = Util.Maid.new(),
    hasOptimizedStructure = Value(false),
    selectingMap = Value(false),
    selectTextState = Value("No map selected"),
    selectTextColor = Value(Theme.ErrorText.Default:get(false)),
    selectCancelColor = Value(Theme.SubText.Default:get(false)),
    selectCancelImage = Value("rbxassetid://6022668885")
}

function MapSelect:IsTriaMap(Map: Model, ignoreChecks: boolean?): (boolean, string?)
    local score_1 = 0 -- D2
    local score_2 = 0 -- FE2/FP275
    local score_3 = 0 -- TRIA.os

    local hasMapScript, hasSettings, oldMapLib

    --// script check

    if not ignoreChecks then
        local script1: Script? = Map:FindFirstChild("EventScript")
        if script1 and string.find(script1.Source, "workspace.MapTest.GetMapFunctions:Invoke()", 1, true) then
            score_1 += 0.5
        end
        if script1 and string.find(script1.Source, "workspace.Multiplayer.GetMapVals:Invoke()", 1, true) then
            score_2 += 0.5
        end
    end

    local script2: Script? = Map:FindFirstChild("MapScript")
    if script2 then
        score_3 += 0.5
        hasMapScript = true
    end

    local settings2 = Map:FindFirstChild("Settings")

    if not ignoreChecks then
        local settings1 = Map:FindFirstChild("MapInfo")
        if settings1 and settings1:FindFirstChild("Lighting")and settings1:FindFirstChild("Audio") and settings1:FindFirstChild("Creator")
        and settings1:FindFirstChild("Difficulty") and settings1:FindFirstChild("MapImage") and settings1:FindFirstChild("MapName") then
            score_1 += 0.5
        end
    
        if settings2 and settings2:FindFirstChild("Rescue") and settings2:FindFirstChild("BGM") and settings2:FindFirstChild("MaxTime")
        and settings2:FindFirstChild("Difficulty") and settings2:FindFirstChild("MapImage") and settings2:FindFirstChild("MapName") then
            score_2 += 0.5
        end
    end

     if 
        settings2 
        and settings2:FindFirstChild("Main") 
        and settings2:FindFirstChild("Lighting")
        and settings2:FindFirstChild("Liquids") 
        and (settings2:FindFirstChild("Button") or settings2:FindFirstChild("Buttons")) 
    then
        score_3 += 0.5
        hasSettings = true
     end

    --// other checks

    if not ignoreChecks then
        if Map:FindFirstChild("ExitWall") and Map:FindFirstChild("MapPreviewCamera") then
            score_1 += 0.25
        end
        if Map:FindFirstChild("WalkspeedBooster", true) or Map:FindFirstChild("TeleporterA1", true) and Map:FindFirstChild("TeleporterA2", true) then
            score_1 += 0.125
        end

        if Map:FindFirstChild("Intro") and Map:FindFirstChild("Intro"):IsA("Model") then
            score_2 += 0.125
        end
        if Map:FindFirstChild("OST_List") or Map:FindFirstChild("_Variants", true) then
            score_2 += 0.125
        end
        if Map:FindFirstChild("EndPole", true) and Map:FindFirstChild("EndPole", true):FindFirstChild("RopePiece")
        and Map:FindFirstChild("StartPole", true) and Map:FindFirstChild("StartPole", true):FindFirstChild("RopePiece") then
            score_2 += 0.125
        end
    end

     if Map:IsA("Model") or Map:IsA("Workspace") then
        if score_1 > 0.875 or score_2 > 1 then
            return false, "Unknown map type detected. Please make sure this map is a TRIA.os map as this plugin only supports TRIA.os map development."
        end

        if not Map:FindFirstChild("Spawn", true) then
            return false, "No spawn point found. Add a part named 'Spawn', and add it into the Special folder. "
        end

        if not Map:FindFirstChild("ExitBlock", true) then
            return false, "No ExitRegion found. Add a part named 'ExitBlock', and add it into the Special folder. "
        end

        if not hasMapScript then
            return false, "No MapScript found. Add a script named 'MapScript' into the map. "
        end

        if not hasSettings then
            return false, "No Settings found. Add a folder named 'Settings' into the map with the relevant subfolders (it's recommended to copy straight from the MapKit). "
        end

        return true, nil
    end

    return false, "Invalid map model format. Must be a 'Model', 'Folder', or unparented in the workspace."
end

function MapSelect:SetMap(Map: Model | Workspace): boolean
    if Map then -- add or change selection
        local success, message = self:IsTriaMap(Map)

        if not success then
            Util:ShowMessage(Util.ERROR_HEADER, tostring(message))
            self:ResetSelection()
            return false
        end

        self.selectCancelColor:set(Theme.ErrorText.Default:get(false))
        self.selectTextColor:set(Theme.MainText.Default:get(false))
        Util.mapModel:set(Map)
        Util.MapChanged:Fire()
        Util.MapMaid:DoCleaning()
        Util.updateSelectedParts()

        self.selectTextState:set(Map.Settings.Main:GetAttribute("Name"))

        local nameChangedSignal; nameChangedSignal = Map.Settings.Main:GetAttributeChangedSignal("Name"):Connect(function()
            self.selectTextState:set(Map.Settings.Main:GetAttribute("Name"))
        end)
        Util.MapMaid:GiveTask(nameChangedSignal)

        local ObjectType = {}

        function ObjectType.Workspace()
            local workspaceUpdate = false
            Util.MapMaid:GiveTask(Map.ChildRemoved:Connect(function(child)
                if not workspaceUpdate and (child.Name == "Settings" or child.Name == "MapScript") then
                    workspaceUpdate = true

                     if not self:IsTriaMap(Map, true) then
                        task.wait()

                        if not self:AutoSelect() then
                            self:SetMap(nil)
                        end
                    end
                    workspaceUpdate = false
                end
            end))
        end

        local parentChanged = false
        function ObjectType.Model()
            Util.MapMaid:GiveTask(Map.AncestryChanged:Connect(function() --// Model was either ungrouped or deleted
				if not Map.Parent then
                    parentChanged = true

	                if not self:AutoSelect() then
	                    self:SetMap(nil)
	                end
				end
            end))

            Util.MapMaid:GiveTask(Map.ChildRemoved:Connect(function(child)
                task.wait()
                if parentChanged then 
                    return 
                end

                if child.Name == "Settings" or child.Name == "MapScript" then
                    if #Map:GetChildren() == 0 and not self:IsTriaMap(Map, true) then
                        if not self:AutoSelect() then
                            self:SetMap(nil)
                            return 
                        end
                    end
                end
            end))
        end

        ObjectType[Map.ClassName]()

        local optimizedStructure = Map:FindFirstChild("Special")
        self.hasOptimizedStructure:set(optimizedStructure and optimizedStructure:IsA("Folder"))

        task.wait()
        if not self.hasOptimizedStructure:get(false) then
            Util:ShowMessage(Util.WARNING_HEADER, "The selected map does not use the Optimized Structure model. Some features of this plugin may be unavaliable until your map supports Optimized Structure")
        end
    else
        self:ResetSelection()
    end

    return true
end

function MapSelect:StartMapSelection()
    if self:IsTriaMap(workspace) then
        self:SetMap(workspace)
        return
    end

    local currentTarget, lastTarget

    local mapHighlight = Instance.new("Highlight", workspace.CurrentCamera)
    local mouse = plugin:GetMouse()

    self.selectCancelImage:set("rbxassetid://6031094678")
    self.selectCancelColor:set(Theme.ErrorText.Default:get(false))
    self.selectTextState:set("Click to select")
    self.selectTextColor:set(Theme.SubText.Default:get(false))
    self._Maid:GiveTask(mapHighlight)
    self.selectingMap:set(true)
    plugin:Activate(true)

    self._Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime)
        local target = mouse.Target
        if target ~= lastTarget then
            lastTarget = target

            repeat
                target = target and target:FindFirstAncestorOfClass("Model")
            until not target or target.Parent == workspace

            if currentTarget == target then
                return
            end

            if target then
                local isMap, text = self:IsTriaMap(target)
                mapHighlight.FillColor = isMap and Color3.fromRGB(168, 229, 153) or Color3.fromRGB(245, 130, 130)
                mapHighlight.Adornee = target
                currentTarget = target
            else
                mapHighlight.Adornee = nil
                currentTarget = nil
            end 
        end
    end))

    self._Maid:GiveTask(mouse.Button1Down:Connect(function()
        self:SetMap(currentTarget)
        self.selectingMap:set(false)
        self.selectCancelImage:set("rbxassetid://6022668885")
        self._Maid:DoCleaning()
        mapHighlight.Adornee = nil
        plugin:Deactivate()
    end))
end

function MapSelect:StopManualSelection()
    self.selectingMap:set(false)
    self._Maid:DoCleaning()
    plugin:Deactivate()

    local currentMap = Util.mapModel:get(false)

    self.selectCancelImage:set("rbxassetid://6022668885")
    self.selectCancelColor:set(if currentMap then Theme.ErrorText.Default:get(false) else Theme.SubText.Default:get(false))
    self.selectTextState:set(if currentMap then currentMap.Settings.Main:GetAttribute("Name") else "No map selected")
    self.selectTextColor:set(if currentMap then Theme.MainText.Default:get(false) else Theme.ErrorText.Default:get(false))
end

function MapSelect:AutoSelect(): boolean
    local isMap, value = self:IsTriaMap(workspace)

    if isMap then
        self:SetMap(workspace)
        return true
    end

    for _, v: Instance in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") then
            isMap, value = self:IsTriaMap(v)
            if isMap then
                self:SetMap(v)
                return true
            end
        end
    end

    if not isMap then
        self:ResetSelection()
        return false
    end
end

function MapSelect:ResetSelection()
    Util._Selection.selectedParts:set({})
    Util.mapModel:set(nil)
    Util.MapChanged:Fire()
    self.hasOptimizedStructure:set(false)
    self.selectCancelColor:set(Theme.SubText.Default:get(false))
    self.selectTextState:set("No map selected")
    self.selectTextColor:set(Theme.ErrorText.Default:get(false))
end

return MapSelect
