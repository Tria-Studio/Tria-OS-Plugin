local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)

local componentFiles = script.Parent.ComponentFiles
local addonFiles = script.Parent.AddonFiles

local COMMA_BREAK = ",*%s*"
local TUNE_MATCH = `local%s[%w%p+]{COMMA_BREAK}(%w+)%s=%spcall%(require,%s*(%d+)%)%w*%s*pcall%((%w+)%.Init{COMMA_BREAK}(%w+){COMMA_BREAK}true{COMMA_BREAK}true%)`

local function positionModel(model: Model)
    local newPos = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -36)
    model:PivotTo(CFrame.new(newPos.Position))
    Selection:Set({model})
end

local function insertModel(modelName: string, parent: Instance): Instance
    ChangeHistoryService:SetWaypoint(string.format("Inserting model '%s'", modelName))
    local newModel = (componentFiles:FindFirstChild(modelName) or addonFiles:FindFirstChild(modelName)):Clone()
    newModel.Parent = parent

    ChangeHistoryService:SetWaypoint(string.format("Inserting model '%s'", modelName))
    return newModel
end

local function getInsertFolder(specialChildName: string): Instance
    local currentMap = Util.mapModel:get(false)

    return Util.hasSpecialFolder:get(false) 
        and currentMap.Special:FindFirstChild(specialChildName) 
        or currentMap:FindFirstChild("Geometry") 
        or currentMap
end

local function areStringsSimilar(...): (boolean, string)
    local strings = {...}
    local similar = false
    
    if #strings < 2 then
        return true, strings[1]
    end

    for i = 2, #strings do
        if strings[1] ~= strings[i] then
            similar = false
            break
        end 
    end
    
    return similar, if similar then strings[1] else nil
end

return {
    Addons = {
        {
            Name = "Tune",
            Creator = "@Ethan76167",
            Icon = "rbxassetid://12570661206",
            LayoutOrder = 1,
            Tooltip = {
                Header = "TUNE",
                Tooltip = "tune tooltip"
            },
    
            InsertFunction = function()
                if Util.failedScriptInjection(Util.SCRIPT_INSERT_ERROR) then
                    return
                end

                local currentMap = Util.mapModel:get(false)
                local mapScript = currentMap:FindFirstChild("MapScript")

                if not mapScript then
                    return;
                end

                local variable, moduleId, pcallVar1, pcallVar2 = mapScript.Source:match(TUNE_MATCH)
                local similar, match = areStringsSimilar(variable, pcallVar1, pcallVar2)
                if similar and match:lower() == "tune" then
                    Util:ShowMessage("Module already installed", "TUNE is already installed in your map!")
                    return;
                end
            end
        }, {
            Name = "Jump Measurement",
            Creator = "@TechnocraticAviation",
            Icon = "rbxassetid://12581662208",
            LayoutOrder = 3,
            Tooltip = {
                Header = "Jump & Fall Measurement Tools",
                Tooltip = [[Allows for precise measurement of jumps for your maps. Each of the 5 different lines tracks a different part of the characters body within a jump.
                
<font color = "rgb(0,200,0)">Green line</font> - represents the bottom of the player's legs
<font color = "rgb(200,200,0)">Yellow line</font> - represents the bottom of the player's legs, but indicates the highest jump that could be made
<font color = "rgb(70,70,255)">Blue line</font> - represents the center of the torso
<font color = "rgb(225,0,0)">Red line</font> - represents the top of the player's head
<font color = "rgb(165,0,0)">Deep red line</font> - represents the top of the player's head, but indicates the highest jump that could be made ]]
            },
    
            InsertFunction = function()
                local model = insertModel("JumpMeasurement", nil)
                positionModel(model)
                model.JumpMeasurement.Parent = workspace
                model.FallMeasurement.Parent = workspace
                model:Destroy()
                Util.debugWarn("Successfully inserted Jump Measurement Tools addon!")
                ChangeHistoryService:SetWaypoint("Inserted jump measurement")
            end
        }, {
            Name = "",
            Creator = "@grif_0",
            Icon = "rbxassetid://12581932576",
            LayoutOrder = 2,
            Tooltip = {
                Header = "EasyTP",
                Tooltip = "Allows for you to easily add timed teleports into your maps with minimal setup. \n\nOpen the ModuleScript for instructions on how to use."
            },
    
            InsertFunction = function()
                if Util.failedScriptInjection(Util.SCRIPT_INSERT_ERROR) then
                    return
                end
            end
        }, 
    },
    Components = {
        {
            Name = "Create new variant",
            Icon = "rbxassetid://12537256759",
            LayoutOrder = 4,
            Tooltip = {
                Header = "Variants",
                Tooltip = "Whenever a map starts, one random variant will be chosen and the rest will be deleted. This can be useful to add variation in a map."
            },
    
            InsertFunction = function()
                ChangeHistoryService:SetWaypoint("Inserting new variant")
                local newVariant = Instance.new("Folder")
                local currentMap = Util.mapModel:get(false)
    
                local variantsFolder = currentMap:FindFirstChild("Variant") or currentMap.Special:FindFirstChild("Variant")
    
                if not variantsFolder then
                    local variantsFolder = Instance.new("Folder")
                    variantsFolder.Name = "Variant"
                    variantsFolder.Parent = Util.hasSpecialFolder:get(false) and currentMap.Special or currentMap
                end
                
                newVariant.Name = string.format("Variant #%d", #variantsFolder:GetChildren() + 1)
                newVariant.Parent = variantsFolder
                Util.debugWarn("Successfully inserted new map variant!")
                ChangeHistoryService:SetWaypoint("Inserted new variant")
            end
        }, {
            Name = "New Button",
            Icon = "rbxassetid://12536983604",
            LayoutOrder = 1,
            Tooltip = {
                Header = "Buttons",
                Tooltip = "One of the main features of a map. An item which players must press in sequential order to escape."
            },
    
            InsertFunction = function()
                local map = Util.mapModel:get(false)
    
                local newParent = if Util.hasSpecialFolder:get(false) and map.Special:FindFirstChild("Button")
                    then map.Special.Button
                    elseif map:FindFirstChild("Geometry") then map.Geometry
                    else map
    
                local highestButton = Util.getObjectCountWithNameMatch("_Button")
                local model = insertModel("_Button0", newParent)
                model.Name = "_Button" .. (highestButton + 1)
                positionModel(model)
    
                Util.debugWarn("Successfully inserted new Button!")
            end
        }, {
            Name = "New Zipline",
            Icon = "rbxassetid://12536982253",
            LayoutOrder = 2,
            Tooltip = {
                Header = "Ziplines",
                Tooltip = "A feature of the mapkit allowing users to ride along a customizable zipline, with the ability to jump off and between ziplines."
            },
    
            InsertFunction = function()
                local newParent = getInsertFolder("Zipline")
                local model = insertModel("Zipline", newParent)
                positionModel(model)
                Util.debugWarn("Successfully inserted new Zipline!")
            end
        }, {
            Name = "New Airtank",
            Icon = "rbxassetid://12536983920",
            LayoutOrder = 3,
            Tooltip = {
                Header = "Airtank",
                Tooltip = "A feature allowing users to increase their oxygen supply."
            },
    
            InsertFunction = function()
                local newParent = getInsertFolder("Interactable")
                local model = insertModel("AirTank", newParent)
                positionModel(model)
                Util.debugWarn("Successfully inserted new AirTank!")
            end
        }, {
            Name = "Insert Optimized Structure",
            Icon = "rbxassetid://12536983174",
            LayoutOrder = 0,
            Tooltip = {
                Header = "Optimized Structure",
                Tooltip = "An optimized layout of every game object inside of a map, allowing for faster map loading time. Some plugin features may only support maps with this feature."
            },
    
            InsertFunction = function()
                if Util.hasSpecialFolder:get(false) then
                    Util:ShowMessage("Cannot insert model", "Your map already has the optimized map structure format! (Folder named 'Special')")
                    return
                end
    
                local newParent = Util.mapModel:get(false)
                insertModel("Special", newParent)
                Util.debugWarn("Successfully added OptimizedStructure!")
            end
        }, {
            Name = "Add Exit Region",
            Icon = "rbxassetid://12537665817",
            LayoutOrder = 7,
            Tooltip = {
                Header = "Exit Region",
                Tooltip = "The finish region where players must enter to survive. Any 'ExitBlock' parts will become collidable upon surviving."
            },
    
            InsertFunction = function()
                ChangeHistoryService:SetWaypoint("Inserting part 'Exit Region'")
    
                local newModel = componentFiles.ExitRegion:Clone()
                positionModel(newModel)
    
                local currentMap = Util.mapModel:get(false)
                if Util.hasSpecialFolder:get(false) then
                    newModel.ExitRegion.Parent = currentMap.Special.Exit.ExitRegion
                    newModel.ExitBlock.Parent = currentMap.Special.Exit.ExitBlock
                else
                    newModel.ExitRegion.Parent = currentMap
                    newModel.ExitBlock.Parent = currentMap
                end
                newModel:Destroy()
                ChangeHistoryService:SetWaypoint("Inserted new map exit!")
            end
        }, {
            Name = "Add Walljump",
            Icon = "rbxassetid://12536982734",
            LayoutOrder = 8,
            Tooltip = {
                Header = "Walljumps",
                Tooltip = "A normal walljump, but with the stock TRIA walljump texture."
            },
    
            InsertFunction = function()
                local newParent = getInsertFolder("Interactable")
                local model = insertModel("Walljump", newParent)
                positionModel(model)
                Util.debugWarn("Successfully inserted new Walljump!")
            end
        }, {
            Name = "Insert Wallrun",
            Icon = "rbxassetid://12536982483",
            LayoutOrder = 9,
            Tooltip = {
                Header = "Wallruns",
                Tooltip = "A normal wallrun, but with the stock TRIA wallrun texture."
            },
    
            InsertFunction = function()
                local newParent = getInsertFolder("Interactable")
                local model = insertModel("Wallrun", newParent)
                positionModel(model)
                Util.debugWarn("Successfully inserted new Wallrun!")
            end
        }, {
            Name = "Insert Gas",
            Icon = "rbxassetid://12536983391",
            LayoutOrder = 10,
            Tooltip = {
                Header = "Gas",
                Tooltip = "A normal gas liquid, but with the stock mapkit appearance."
            },
    
            InsertFunction = function()
                local newParent = getInsertFolder("Fluid")
    
                local highestGas = Util.getObjectCountWithNameMatch("_Gas")
                local model = insertModel("_Gas0", newParent)
                model.Name = "_Gas" .. (highestGas + 1)
                positionModel(model)
                Util.debugWarn("Successfully inserted new Gas!")
            end
        }, 
    }
}
