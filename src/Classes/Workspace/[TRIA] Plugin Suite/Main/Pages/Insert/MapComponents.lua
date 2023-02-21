local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)



local function PositionModel(Model)
    local Position = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -36)
    Model:PivotTo(CFrame.new(Position.Position))
    Selection:Set({Model})
end

local function InsertModel(Name, Parent)
    ChangeHistoryService:SetWaypoint(string.format("Inserting model '%s'", Name))
    local NewModel = script.Parent.ComponentFiles:FindFirstChild(Name):Clone()
    NewModel.Parent = Parent

    ChangeHistoryService:SetWaypoint(string.format("Inserting model '%s'", Name))
    return NewModel
end

return {
    {
        Name = "Create new variant",
        Icon = "rbxassetid://12537256759",
        LayoutOrder = 4,
        Tooltip = {
            Header = "Variants",
            Tooltip = "Whenever a map starts, one random variant will be chosen and the rest will be deleted. This can be useful to add variation in a map."
        },

        InsertFunction = function()
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
            local map = Util.mapModel:get()
            local newParent = if Util.hasSpecialFolder:get() and map.Special:FindFirstChild("Button")
                then map.Special.Button
                elseif map:FindFirstChild("Geometry") then map.Geometry
                else map
            local model = InsertModel("_Button0", newParent)
            PositionModel(model)
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
            local newParent = Util.hasSpecialFolder:get() and Util.mapModel:get().Special:FindFirstChild("Zipline") or Util.mapModel:get():FindFirstChild("Geometry") or Util.mapModel:get()
            local model = InsertModel("Zipline", newParent)
            PositionModel(model)
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
            local newParent = Util.hasSpecialFolder:get() and Util.mapModel:get().Special:FindFirstChild("Interactable") or Util.mapModel:get():FindFirstChild("Geometry") or Util.mapModel:get()
            local model = InsertModel("AirTank", newParent)
            PositionModel(model)
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
            if Util.hasSpecialFolder:get() then
                Util:ShowMessage("Cannot insert model", "Your map already has the optimized map structure format! (Folder named 'Special')")
                return
            end

            local newParent = Util.mapModel:get()
            InsertModel("Special", newParent)
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
            ChangeHistoryService:SetWaypoint("Inserting model 'Spawn'")
            local newModel = script.Parent.ComponentFiles.ExitRegion:Clone()
            PositionModel(newModel)

            if Util.hasSpecialFolder:get() then
                newModel.ExitRegion.Parent = Util.mapModel:get().Special.Exit.ExitRegion
                newModel.ExitBlock.Parent = Util.mapModel:get().Special.Exit.ExitBlock
            else
                newModel.ExitRegion.Parent = Util.mapModel:get()
                newModel.ExitBlock.Parent = Util.mapModel:get()
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
            local newParent = Util.hasSpecialFolder:get() and Util.mapModel:get():FindFirstChild("Interactable") or Util.mapModel:get():FindFirstChild("Geometry") or Util.mapModel:get()
            local model = InsertModel("Walljump", newParent)
            PositionModel(model)
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
            local newParent = Util.hasSpecialFolder:get() and Util.mapModel:get():FindFirstChild("Interactable") or Util.mapModel:get():FindFirstChild("Geometry") or Util.mapModel:get()
            local model = InsertModel("Wallrun", newParent)
            PositionModel(model)
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
            local newParent = Util.hasSpecialFolder:get() and Util.mapModel:get():FindFirstChild("Fluid") or Util.mapModel:get():FindFirstChild("Geometry") or Util.mapModel:get()
            local model = InsertModel("_Gas0", newParent)
            PositionModel(model)
            Util.debugWarn("Successfully inserted new Gas!")
        end
    }, 

}
