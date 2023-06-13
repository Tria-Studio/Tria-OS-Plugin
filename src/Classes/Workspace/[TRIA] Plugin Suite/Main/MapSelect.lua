local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Pages = require(Resources.Components.Pages)

local Util = require(Package.Util)

local Observer = Fusion.Observer
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
    local other_folder

    if not ignoreChecks then
        local settings1 = newMap:FindFirstChild("MapInfo")
        if settings1 and settings1:FindFirstChild("Lighting") and settings1:FindFirstChild("Audio") and settings1:FindFirstChild("Creator")
        and settings1:FindFirstChild("Difficulty") and settings1:FindFirstChild("MapImage") and settings1:FindFirstChild("MapName") then
            score_1 += 0.5
            other_folder = true
        end
    
        if 
            settings2 and(settings2:FindFirstChild("Rescue") or settings2:FindFirstChild("RescueCutscene")) and (settings2:FindFirstChild("BGM") or settings2:FindFirstChild("BGMs")) and settings2:FindFirstChild("MaxTime")
            and settings2:FindFirstChild("Difficulty") and settings2:FindFirstChild("MapImage") and settings2:FindFirstChild("MapName")
        then
            score_2 += 0.5
            other_folder = true
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
        if newMap:FindFirstChild("ExitWall") and newMap:FindFirstChild("MapPreviewCamera") and other_folder then
            score_1 += 0.25
        end
        if other_folder and newMap:FindFirstChild("TeleporterA1", true) and newMap:FindFirstChild("TeleporterA2", true) then
            score_1 += 0.125
        end

        if newMap:FindFirstChild("Features") and newMap.Features:FindFirstChild("StunObjects") and newMap.Features:FindFirstChild("Interactives") and newMap.Features:FindFirstChild("Buttons") and newMap.Features:FindFirstChild("Triggers") then
            score_2 += 0.25
        end


        local instructions = newMap:FindFirstChild("MapInstructions")
        if instructions and instructions.Source:find("LB Map Kit") and instructions.Source:find("Liquid Breakout") then
            score_2 += 0.125
        end

        local mapScript = newMap:FindFirstChild("EventScript")
        if mapScript and mapScript.Source:find("https://devforum.roblox.com/t/fe2cm-map-making-kit/2249987") then
            score_2 += 0.125
        end

        if newMap:FindFirstChild("Intro") and newMap:FindFirstChild("Intro"):IsA("Model") then
            score_2 += 0.125
        end
        if newMap:FindFirstChild("BGMLists") and (newMap.BGMLists:FindFirstChild("FE2Classic") or newMap.BGMLists:FindFirstChild("LiquidBreakout")) then
            score_2 += 0.125
        end
        
        local model = newMap:FindFirstChild("_Variants", true)
        if model and  model:IsA("Model") then
            score_2 += 0.125
        end

        if newMap:FindFirstChild("EndPole", true) and newMap:FindFirstChild("EndPole", true):FindFirstChild("RopePiece")
        and newMap:FindFirstChild("StartPole", true) and newMap:FindFirstChild("StartPole", true):FindFirstChild("RopePiece") then
            score_2 += 0.125
        end
    end 

     if newMap:IsA("Model") or newMap:IsA("Workspace") then
        if score_1 > 0.875 or score_2 > 1 then
            return false, "Unknown map detected. This plugin is designed to aid TRIA.os development."
        end

        if not newMap:FindFirstChild("Spawn", true) then
            return false, "No spawn point found. Add a part named 'Spawn', and add it into the Special folder or map model. "
        end

        if not newMap:FindFirstChild("ExitRegion", true) then
            return false, "No ExitRegion found. Add a part named 'ExitRegion', and add it into the Special folder or map model. "
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
        local oldMap = Util.mapModel:get()

        Util.mapModel:set(newMap)
        Util.MapMaid:DoCleaning()
        Util.updateSelectedParts()
        if oldMap ~= newMap then
            Util.MapChanged:Fire()
        end

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

        local function detectSpecialFolder(force)
            local specialFolder = newMap:FindFirstChild("Special")
            updateSpecial()
            Util.MapMaid:GiveTask(newMap.ChildAdded:Connect(updateSpecial))
            Util.MapMaid:GiveTask(newMap.ChildRemoved:Connect(updateSpecial))
            task.spawn(function()
                Util.hasSpecialFolder:set(newMap:FindFirstChild("Special") ~= nil, true)
                while newMap == Util.mapModel:get() do
                    task.wait(1)
                    Util.hasSpecialFolder:set(newMap:FindFirstChild("Special") ~= nil)
                end
            end)

            if specialFolder then
                Util.MapMaid:GiveTask(specialFolder:GetPropertyChangedSignal("Name"):Connect(updateSpecial))
            end
        end

        mapTypes[newMap.ClassName]()
        detectSpecialFolder(true)

        -- make sure the map has every settings folder, if not add it
        -- i got lazy so no it doesnt automatically add every setting

        local Settings = Util.mapModel:get().Settings

        if not Settings:FindFirstChild("Music") then
            local musicFolder = Instance.new("Configuration")
            musicFolder.Name = "Music"
            musicFolder.Parent = Settings

            musicFolder:SetAttribute("Music", Settings.Main:GetAttribute())
            musicFolder:SetAttribute("Volume", 0.5)
            musicFolder:SetAttribute("TimePosition", 0)
        end

        if not Settings:FindFirstChild("Materials") then
            local musicFolder = Instance.new("Configuration")
            musicFolder.Name = "Materials"
            musicFolder.Parent = Settings

            musicFolder:SetAttribute("Use2022Materials", false)
        end

        if not Settings:FindFirstChild("Skills") then
            local musicFolder = Instance.new("Configuration")
            musicFolder.Name = "Skills"
            musicFolder.Parent = Settings

            musicFolder:SetAttribute("AllowAirDive", false)
            musicFolder:SetAttribute("AllowSliding", false)
            musicFolder:SetAttribute("LinearSliding", false)
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
    if Selection:get()[1] and self:IsTriaMap(Selection:get()[1]) then
        self:SetMap(Selection:get()[1])
        return
    end

    local currentTarget, lastTarget

    local humanoid = Instance.new("Humanoid")
    humanoid.Name = "_tria_temp"
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
                if #target:GetDescendants() < 1_000 then
                    humanoid.Parent = target
                end

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
    local oldModel = Util.mapModel:get()
    Util._Selection.selectedParts:set({})
    Util.mapModel:set(nil)
    Util.hasSpecialFolder:set(false)
    self.selectCancelColor:set(Theme.SubText.Default:get(false))
    self.selectTextState:set("No map selected (Click to select)")
    self.selectTextColor:set(Theme.ErrorText.Default:get(false))

    if oldModel then
        Util.MapChanged:Fire()
    end
end

local active = true
Observer(Util.hasSpecialFolder):onChange(function()
    if not Util.mapModel:get() then
        return
    end

    local folder = Util.mapModel:get().Special

    local function check()
        active = true
        while Util.hasSpecialFolder:get() and Util.mapModel:get() and Util.mapModel:get().Special:FindFirstChild("Variant") do
            if #Util.variantFolderChildren:get() ~= #folder:FindFirstChild("Variant"):GetChildren() then
                Util.variantFolderChildren:set(folder:FindFirstChild("Variant"):GetChildren())
            end
            task.wait(1)
        end
        if not Util.mapModel:get() or not Util.mapModel:get():FindFirstChild("Special") or Util.mapModel:get():FindFirstChild("Special") and not Util.mapModel:get().Special:FindFirstChild("Variant") then
            Util.variantFolderChildren:set({})
        end
        active = false
    end
    
    task.spawn(function()
        while task.wait(1) and Util.mapModel:get() do
            if not active and folder:FindFirstChild("Variant") then
                check()
            end
        end
    end)
    check()
end)

return MapSelect
