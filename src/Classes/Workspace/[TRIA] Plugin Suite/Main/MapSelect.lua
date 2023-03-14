local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Pages = require(Resources.Components.Pages)

local Util = require(Package.Util)

local Value = Fusion.Value
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local MapSelect = {
    _Maid = Util.Maid.new(),
    selectingMap = Value(false),
    selectTextState = Value("No map selected (Click to select)"),
    selectTextColor = Value(Theme.ErrorText.Default:get(false)),
    selectCancelColor = Value(Theme.SubText.Default:get(false)),
    selectCancelImage = Value("rbxassetid://6022668885")
}

function MapSelect:IsTriaMap(newMap: Instance, ignoreChecks: boolean?): (boolean, string?)
    local score_1 = 0
    local score_2 = 0
    local score_3 = 0

    local hasMapScript, hasSettings, oldMapLib

    --// script check

    if not ignoreChecks then
        local script1 : Script? = newMap:FindFirstChild("EventScript")
        if script1 and string.find(script1.Source, "workspace.MapTest.GetMapFunctions:Invoke()", 1, true) then
            score_1 += 0.5
        end
        if script1 and string.find(script1.Source, "workspace.Multiplayer.GetMapVals:Invoke()", 1, true) then
            score_2 += 0.5
        end
    end

    local script2: Script? = newMap:FindFirstChild("MapScript")
    if script2 then
        score_3 += 0.5
        hasMapScript = true
    end

    local settings2: Instance? = newMap:FindFirstChild("Settings")

    if not ignoreChecks then
        local settings1 = newMap:FindFirstChild("MapInfo")
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
        if newMap:FindFirstChild("ExitWall") and newMap:FindFirstChild("MapPreviewCamera") then
            score_1 += 0.25
        end
        if newMap:FindFirstChild("WalkspeedBooster", true) or newMap:FindFirstChild("TeleporterA1", true) and newMap:FindFirstChild("TeleporterA2", true) then
            score_1 += 0.125
        end

        if newMap:FindFirstChild("Intro") and newMap:FindFirstChild("Intro"):IsA("Model") then
            score_2 += 0.125
        end
        if newMap:FindFirstChild("OST_List") or newMap:FindFirstChild("_Variants", true) then
            score_2 += 0.125
        end
        if newMap:FindFirstChild("EndPole", true) and newMap:FindFirstChild("EndPole", true):FindFirstChild("RopePiece")
        and newMap:FindFirstChild("StartPole", true) and newMap:FindFirstChild("StartPole", true):FindFirstChild("RopePiece") then
            score_2 += 0.125
        end
    end

     if newMap:IsA("Model") or newMap:IsA("Workspace") then
        if score_1 > 0.875 or score_2 > 1 then
            return false, "Unknown map type detected. Please make sure this map is a TRIA.os map as this plugin only supports TRIA.os map development."
        end

        if not newMap:FindFirstChild("Spawn", true) then
            return false, "No spawn point found. Add a part named 'Spawn', and add it into the Special folder. "
        end

        if not newMap:FindFirstChild("ExitBlock", true) then
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

function MapSelect:SetMap(newMap: Model | Workspace?): boolean
    if newMap then -- add or change selection
        local success, message = self:IsTriaMap(newMap)

        if not success then
            Util:ShowMessage(Util._Headers.ERROR_HEADER, tostring(message), {Text = "Get Mapkit", Callback = function()
                Pages:ChangePage("Insert")
            end})
            self:ResetSelection()
            return false
        end

        self.selectCancelColor:set(Theme.ErrorText.Default:get(false))
        self.selectTextColor:set(Theme.MainText.Default:get(false))
        Util.mapModel:set(newMap)
        Util.MapChanged:Fire()
        Util.MapMaid:DoCleaning()
        Util.updateSelectedParts()

        self.selectTextState:set(newMap.Settings.Main:GetAttribute("Name"))

        local nameChangedSignal; nameChangedSignal = newMap.Settings.Main:GetAttributeChangedSignal("Name"):Connect(function()
            self.selectTextState:set(newMap.Settings.Main:GetAttribute("Name"))
        end)
        Util.MapMaid:GiveTask(nameChangedSignal)

        local mapTypes = {}

        function mapTypes.Workspace()
            local workspaceUpdate = false
            Util.MapMaid:GiveTask(newMap.ChildRemoved:Connect(function(child)
                if not workspaceUpdate and (child.Name == "Settings" or child.Name == "MapScript") then
                    workspaceUpdate = true

                     if not self:IsTriaMap(newMap, true) then
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
        function mapTypes.Model()
            Util.MapMaid:GiveTask(newMap.AncestryChanged:Connect(function() --// Model was either ungrouped or deleted
				if not newMap.Parent then
                    parentChanged = true

	                if not self:AutoSelect() then
	                    self:SetMap(nil)
	                end
				end
            end))

            Util.MapMaid:GiveTask(newMap.ChildRemoved:Connect(function(child)
                task.wait()
                if parentChanged then 
                    return 
                end

                if child.Name == "Settings" or child.Name == "MapScript" then
                    if #newMap:GetChildren() == 0 and not self:IsTriaMap(newMap, true) then
                        if not self:AutoSelect() then
                            self:SetMap(nil)
                            return 
                        end
                    end
                end
            end))
        end

        local function updateSpecial()
            Util.hasSpecialFolder:set(newMap:FindFirstChild("Special") ~= nil)
        end

        local function detectSpecialFolder()
            local specialFolder = newMap:FindFirstChild("Special")

            updateSpecial()
            Util.MapMaid:GiveTask(newMap.ChildAdded:Connect(updateSpecial))
            Util.MapMaid:GiveTask(newMap.ChildRemoved:Connect(updateSpecial))

            if specialFolder then
                Util.MapMaid:GiveTask(specialFolder:GetPropertyChangedSignal("Name"):Connect(updateSpecial))
            end
        end

        mapTypes[newMap.ClassName]()
        detectSpecialFolder()

        task.wait()
        if not Util.hasSpecialFolder:get(false) then
            Util:ShowMessage(Util._Headers.WARNING_HEADER, "The selected map does not use the Optimized Structure model. Some features of this plugin may be unavaliable until your map supports Optimized Structure")
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
    if self:IsTriaMap(Selection:get()[1]) then
        self:SetMap(Selection:get()[1])
        return
    end

    local currentTarget, lastTarget

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "_tempplugin"
    humanoid.Archivable = false

    local mapHighlight = Instance.new("Highlight", workspace.CurrentCamera)
    local mouse = plugin:GetMouse()

    self.selectCancelImage:set("rbxassetid://6031094678")
    self.selectCancelColor:set(Theme.ErrorText.Default:get(false))
    self.selectTextState:set("Click to select")
    self.selectTextColor:set(Theme.SubText.Default:get(false))
    self._Maid:GiveTask(mapHighlight)
    self._Maid:GiveTask(humanoid)
    self.selectingMap:set(true)
    plugin:Activate(true)

    self._Maid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
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
                humanoid.Parent = target

                local isMap, text = self:IsTriaMap(target)
                mapHighlight.FillColor = isMap and Color3.fromRGB(168, 229, 153) or Color3.fromRGB(245, 130, 130)
                mapHighlight.Adornee = target
                currentTarget = target
            else
                mapHighlight.Adornee = nil
                humanoid.Parent = nil
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
    self.selectTextState:set(if currentMap then currentMap.Settings.Main:GetAttribute("Name") else "No map selected (Click to select)")
    self.selectTextColor:set(if currentMap then Theme.MainText.Default:get(false) else Theme.ErrorText.Default:get(false))
end

function MapSelect:AutoSelect(DontSet: boolean?): boolean
    local isMap, value = self:IsTriaMap(workspace)

    if isMap then
        if not DontSet then
            self:SetMap(workspace)
        end
        return true
    end

    for _, v: Instance in ipairs(workspace:GetChildren()) do
        if v:IsA("Model") then
            isMap, value = self:IsTriaMap(v)
            if isMap then
                if not DontSet then
                    self:SetMap(v)
                end
                return true
            end
        end
    end

    if DontSet then
        return false
    end

    if not isMap then
        self:ResetSelection()
        return false
    end

    return false
end

function MapSelect:ResetSelection()
    Util._Selection.selectedParts:set({})
    Util.mapModel:set(nil)
    Util.MapChanged:Fire()
    Util.hasSpecialFolder:set(false)
    self.selectCancelColor:set(Theme.SubText.Default:get(false))
    self.selectTextState:set("No map selected (Click to select)")
    self.selectTextColor:set(Theme.ErrorText.Default:get(false))
end

return MapSelect
