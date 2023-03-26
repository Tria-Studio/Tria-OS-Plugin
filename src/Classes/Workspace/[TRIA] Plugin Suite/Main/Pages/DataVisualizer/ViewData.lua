local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

local Computed = Fusion.Value
local Observer = Fusion.Observer
local Value = Fusion.Value

local varaints = Value({})
local nameEvents = Util.Maid.new()

Observer(Util.variantFolderChildren):onChange(function()
    local newTable = {}
    nameEvents:DoCleaning()

    for i, variant in pairs(Util.variantFolderChildren:get()) do
        local name = Value(variant.Name)
        nameEvents:GiveTask(variant:GetPropertyChangedSignal("Name"):Connect(function()
            name:set(variant.Name)
        end))

        table.insert(newTable, {
            LayoutOrder = i,
            Name = name,
            DisplayIcon = "rbxassetid://6035067831"
        })
    end

    varaints:set(newTable)
end)

return {
    LowDetail = {
        SingleOption = true,
        DisplayText = "Low Detail View",
        DisplayIcon = "rbxassetid://6034925618",
        LayoutOrder = 1,
        ViewOptions = {},
        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    ButtonTags = {
        DisplayText = "Button Tags",
        SubText = "All Button Tags",
        DisplayIcon = "rbxassetid://6031079158",
        LayoutOrder = 2,
        ViewOptions = {
            {
                Name = "_Show",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031075931",
            }, {
                Name = "_Hide",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6031075929",
            }, {
                Name = "_Fall",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://6031094674",
            }, {
                Name = "_Sound",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://6026671215",
            }, {
                Name = "_Destroy",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668962",
            }, {
                Name = "_Explode",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034684949",
            },
        },
        Tooltip = {
            Header = "",
            Text = ""
        },
    },
    ObjectView = {
        DisplayText = "Object Tags",
        SubText = "All Object Tags",
        DisplayIcon = "rbxassetid://6031079158",
        LayoutOrder = 3,
        ViewOptions = {
            {
                Name = "WallJump",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://9468872087",
            }, {
                Name = "WallRun",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6026568215",
            }, {
                Name = "_Liquid",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://12903642348",
            }, {
                Name = "_Gas",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://12903642348",
            }, {
                Name = "Killbrick",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668916",
            }, {
                Name = "SpeedBooster",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034754445",
            }, {
                Name = "JumpBooster",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034754445",
            }, {
                Name = "AirTank",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6031068426",
            },
        },
        Tooltip = {
            Header = "",
            Text = ""
        },
    },
    ButtonView = {
        SingleOption = true,
        DisplayText = "Button View",
        DisplayIcon = "rbxassetid://6026647916",
        LayoutOrder = 4,
        ViewOptions = {},
        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    ZiplineView = {
        SingleOption = true,
        DisplayText = "Zipline View",
        DisplayIcon = "rbxassetid://6035067839",
        LayoutOrder = 5,
        ViewOptions = {},
        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    VariantView = {
        DisplayText = "Variant View",
        DisplayIcon = "rbxassetid://6022668909",
        LayoutOrder = 6,
        ViewOptions = varaints, --TODO: find a way to have this and the UI update when variants are created and destroyed
        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    AddonView = {
        DisplayText = "Map Addons View",
        SubText = "All Addon Tags",
        DisplayIcon = "rbxassetid://6023565892",
        LayoutOrder = 7,
        ViewOptions = {
            {
                Name = "_Teleporter",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031082527",
            }, {
                Name = "_Waterjet",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6022668890",
            }
        },
        Tooltip = {
            Header = "Map Addons View",
            Text = "Because the selected map has map addons that support Object & Button Tags, those tags can be visualized below."
        }
    },
}
