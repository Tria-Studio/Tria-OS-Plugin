local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)
local TagUtils = require(Package.Util.TagUtils)
local ConvertToOptimized = require(script.OptimizedConvert)

local componentFiles = script.Parent.ComponentFiles

local COMMA_BREAK = ",*%s*"
local TUNE_MATCH = `local%s[%w%p+]{COMMA_BREAK}(%w+)%s=%spcall%(require,%s*(%d+)%)%w*`

local function positionModel(model: Model)
    local newPos = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -36)
    model:PivotTo(CFrame.new(newPos.Position))
    Selection:Set({model})
end

local function insertModel(modelName: string, parent: Instance?): Instance
    local newModel = componentFiles:FindFirstChild(modelName)
    newModel.Parent = parent
    return newModel
end

local function getInsertFolder(specialChildName: string): Instance
    local currentMap = Util.mapModel:get(false)

    return Util.hasSpecialFolder:get(false) 
        and currentMap.Special:FindFirstChild(specialChildName) 
        or currentMap:FindFirstChild("Geometry") 
        or currentMap
end

return {
    Addons = {},
    Components = {
        {
            Name = "Create new variant",
            Icon = "rbxassetid://12537256759",
            LayoutOrder = 6,
            Tooltip = {
                Header = "Variants",
                Tooltip = "Whenever a map starts, one random variant will be chosen and the rest will be deleted. This can be useful to add variation in a map."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Variant"))
                if recording then

                    local newVariant = Instance.new("Folder")
                    local currentMap = Util.mapModel:get(false)
        
                    local variantsFolder = currentMap:FindFirstChild("Variant") or currentMap.Special:FindFirstChild("Variant")
        
                    if not variantsFolder then
                        variantsFolder = Instance.new("Folder")
                        variantsFolder.Name = "Variant"
                        variantsFolder.Parent = Util.hasSpecialFolder:get(false) and currentMap.Special or currentMap
                    end
                    
                    newVariant.Name = string.format("Variant #%d", #variantsFolder:GetChildren() + 1)
                    newVariant.Parent = variantsFolder
                    Util.debugWarn("Successfully inserted new map variant!")

                    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
                end
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
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Button"))
                if recording then

                    local newParent = getInsertFolder("Button")
                    local highestButton = Util.getObjectCountWithNameMatch("_Button")
                    local model = insertModel("_Button0", newParent)
                    model.Name = "_Button" .. (highestButton + 1)
                    positionModel(model)
                    TagUtils.OnTagAdded("_Button"):Fire(model)
        
                    Util.debugWarn("Successfully inserted new Button!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end

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
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Zipline"))
                if recording then

                    local newParent = getInsertFolder("Zipline")
                    local model = insertModel("Zipline", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("Zipline"):Fire(model)
                    Util.debugWarn("Successfully inserted new Zipline!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "New Airtank",
            Icon = "rbxassetid://13677007811",
            LayoutOrder = 3,
            Tooltip = {
                Header = "Airtank",
                Tooltip = "A feature allowing users to increase their oxygen supply."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "MapExit"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("AirTank", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("Airtank"):Fire(model)
                    Util.debugWarn("Successfully inserted new AirTank!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "New Launch Orb", 
            Icon = "rbxassetid://13676946865",
            LayoutOrder = 4,
            Tooltip = {
                Header = "Launch Orbs",
                Tooltip = "One of two types of orbs. Launch Orbs always launch the player in the direction indicated in the model."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "LaunchOrb"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("LaunchOrb", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("LaunchOrb"):Fire(model)
                    Util.debugWarn("Successfully inserted new Launch Orb!")
                    
                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "New Pivot Orb", 
            Icon = "rbxassetid://13676946975",
            LayoutOrder = 5,
            Tooltip = {
                Header = "Pivot Orbs",
                Tooltip = "One of two types of orbs. Pivot Orbs launch the character in the direction they rotate their character."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "PivotOrb"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("PivotOrb", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("PivotOrb"):Fire(model)
                    Util.debugWarn("Successfully inserted new Pivot Orb!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "Insert Optimized Structure",
            Icon = "rbxassetid://13693728508",
            LayoutOrder = 0,
            Tooltip = {
                Header = "Optimized Structure",
                Tooltip = "An optimized layout of every game object inside of a map, allowing for faster map loading time. Some plugin features may only support maps with this feature."
            },
    
            InsertFunction = function()
                if Util.hasSpecialFolder:get(false) then
                    Util:ShowMessage("Cannot insert model", "Your map already has the optimized map structure format! (Folder named 'Special').\n\n Would you like to convert your map into this structure anyways? \n\n(NOTE: This will not convert your scripts. If your MapScript is referencing any key map component (liquid, buttons, etc.) You will need to manually update it.)", {Text = "Yes", Callback = ConvertToOptimized}, {Text = "No"})
                    return
                end
    
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "OptimizedStructure"))
                if recording then

                    local newParent = Util.mapModel:get(false)
                    insertModel("Special", newParent)
                    Util.debugWarn("Successfully added OptimizedStructure!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)

                    Util:ShowMessage("Convert Map?", "Would you like to convert your map's components to use this structure automatically?\n\nNOTE: This will not convert your scripts. If your MapScript is referencing any key map component (liquid, buttons, etc.) You will need to manually update it.", {Text = "Yes", Callback = ConvertToOptimized}, {Text = "No"})
                end
            end
        }, {
            Name = "Add Exit Region",
            Icon = "rbxassetid://13693329144",
            LayoutOrder = 7,
            Tooltip = {
                Header = "Exit Region",
                Tooltip = "The finish region where players must enter to survive. Any 'ExitBlock' parts will become collidable upon surviving."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "MapExit"))
                if recording then

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

                    ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "Add Teleporter",
            Icon = "rbxassetid://13677069251",
            LayoutOrder = 9,
            Tooltip = {
                Header = "Teleporter",
                Tooltip = "When touched will move the player to the Destination part, with the option to adjust the players camera."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Teleporter"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("Teleporter", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("Teleporter"):Fire(model)
                    Util.debugWarn("Successfully inserted new Teleporter!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "Add Walljump",
            Icon = "rbxassetid://12536982734",
            LayoutOrder = 10,
            Tooltip = {
                Header = "Walljumps",
                Tooltip = "A normal walljump, but with the stock TRIA walljump texture."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Walljump"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("Walljump", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("_WallJump"):Fire(model)
                    Util.debugWarn("Successfully inserted new Walljump!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end

            end
        }, {
            Name = "Insert Wallrun",
            Icon = "rbxassetid://12536982483",
            LayoutOrder = 11,
            Tooltip = {
                Header = "Wallruns",
                Tooltip = "A normal wallrun, but with the stock TRIA wallrun texture."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Wallrun"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("Wallrun", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("_WallRun"):Fire(model)
                    Util.debugWarn("Successfully inserted new Wallrun!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "Insert Conveyor",
            Icon = "rbxassetid://135482160119855",
            LayoutOrder = 11,
            Tooltip = {
                Header = "Conveyors",
                Tooltip = "A normal conveyor, but with the stock TRIA conveyor texture."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Conveyor"))
                if recording then

                    local newParent = getInsertFolder("Interactable")
                    local model = insertModel("Conveyor", newParent)
                    positionModel(model)
                    TagUtils.OnTagAdded("Conveyor"):Fire(model)
                    Util.debugWarn("Successfully inserted new Conveyor!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, {
            Name = "Insert Gas",
            Icon = "rbxassetid://13677024452",
            LayoutOrder = 12,
            Tooltip = {
                Header = "Gas",
                Tooltip = "A normal gas liquid, but with the stock mapkit appearance."
            },
    
            InsertFunction = function()
                local recording = ChangeHistoryService:TryBeginRecording("insertPluginComponent", string.format('Inserted map component "%s"', "Gas"))
                if recording then

                    local newParent = getInsertFolder("Fluid")
    
                    local highestGas = Util.getObjectCountWithNameMatch("_Gas", nil, true)
                    local model = insertModel("_Gas0", newParent)
                    model.Name = "_Gas" .. (highestGas + 1)
                    positionModel(model)
                    TagUtils.OnTagAdded("_Gas"):Fire(model)
                    Util.debugWarn("Successfully inserted new Gas!")

                    ChangeHistoryService:FinishRecording(recording,  Enum.FinishRecordingOperation.Commit)
                end
            end
        }, 
    }
}
