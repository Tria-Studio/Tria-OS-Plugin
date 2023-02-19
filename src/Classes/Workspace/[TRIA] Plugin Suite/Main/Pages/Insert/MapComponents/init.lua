local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)

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
            local variantsFolder = Util.mapModel:FindFirstChild("Variant") or Util.mapModel.Special:FindFirstChild("Variant")

            if not variantsFolder then
                local variantsFolder = Instance.new("Folder")
                variantsFolder.Name = "Variant"
                variantsFolder.Parent = Util.hasSpecialFolder:get() and Util.mapModel:get().Special or Util.mapModel:get()
            end
            
            newVariant.Name = string.format("Variant #%d", #variantsFolder:GetChildren() + 1)
            newVariant.Parent = variantsFolder
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
            
        end
    }, {
        Name = "New Zipline",
        Icon = "rbxassetid://12536982253",
        LayoutOrder = 2,
        Tooltip = {
            Header = "Ziplines",
            Tooltip = "A feature of the mapkit allowing users to ride along a customizable zipline, with the abillity to jump off and between ziplines."
        },

        InsertFunction = function()
            
        end
    }, {
        Name = "New Airtank",
        Icon = "rbxassetid://12536983920",
        LayoutOrder = 3,
        Tooltip = {
            Header = "Airtank",
            Tooltip = "A feature allowing users to increasee their oxygen supply."
        },

        InsertFunction = function()
            
        end
    }, {
        Name = "Insert Optimized Structure",
        Icon = "rbxassetid://12536983174",
        LayoutOrder = 5,
        Tooltip = {
            Header = "Optimized Structure",
            Tooltip = "An optimized layout of every game object inside of a map, allowing for faster map loading time. Some plugin features may only support maps with this feature."
        },

        InsertFunction = function()
            
        end
    }, {
        Name = "Add Map Spawn",
        Icon = "rbxassetid://12536982981",
        LayoutOrder = 6,
        Tooltip = {
            Header = "Map Spawn",
            Tooltip = "The start of a map where users spawn facing the green colored face."
        },

        InsertFunction = function()
            
        end
    },{
        Name = "Add Exit Region",
        Icon = "rbxassetid://12537665817",
        LayoutOrder = 7,
        Tooltip = {
            Header = "Exit Region",
            Tooltip = "The finish region where players must enter to survive. Any 'ExitBlock' parts will become collidable upon surviving."
        },

        InsertFunction = function()
            
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
            
        end
    }, 

}
