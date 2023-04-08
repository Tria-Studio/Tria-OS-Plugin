local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)

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
            TagType = "Parent",
            SubName = "Variant",
            Name = name,
            DisplayIcon = "rbxassetid://6035067831",

            Color = Color3.fromHSV((i / #Util.variantFolderChildren:get()), 0.25,0.875),
            ObjectType = "SelectionBox",
        })
    end

    varaints:set(newTable)
end)

return {
    LowDetail = {
        TagType = "Parent",
        SingleOption = true,
        Name = "_Detail",
        DisplayText = "Low Detail View",
        DisplayIcon = "rbxassetid://6034925618",
        LayoutOrder = 1,
        ViewOptions = {},
        Tooltip = {
            Header = "",
            Text = ""
        },

        Color = Color3.fromRGB(187, 67, 227),
        ObjectType = "SelectionBox",
    },
    ButtonTags = {
        DisplayText = "Button Tags",
        SubText = "All Button Tags",
        DisplayIcon = "rbxassetid://6031079158",
        LayoutOrder = 2,
        ViewOptions = {
            {
                TagType = "Child",
                Name = "_Show",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031075931",

                Color = Color3.fromRGB(51, 162, 48),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Hide",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6031075929",

                Color = Color3.fromRGB(75, 52, 156),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Fall",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://12903664425",

                Color = Color3.fromRGB(214, 240, 99),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Sound",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://6026671215",

                Color = Color3.fromRGB(102, 102, 102),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Destroy",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668962",

                Color = Color3.fromRGB(135, 40, 40),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Explode",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034684949",

                Color = Color3.fromRGB(240, 115, 48),
                ObjectType = "SelectionBox",
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
                TagType = "Any",
                Name = "_WallJump",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://9468872087",
                UsesAllInstances = true,

                Color = Color3.fromRGB(180, 180, 180),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Any",
                Name = "_WallRun",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6026568215",
                UsesAllInstances = true,
                
                Color = Color3.fromRGB(225, 225, 225),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Liquid",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://6026568295",

                Color = Color3.fromRGB(60, 60, 220),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Child",
                Name = "_Gas",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://6026568253",

                Color = Color3.fromRGB(206, 143, 211),
                ObjectType = "SelectionBox",
            }, {
                TagType = "NoChild",
                Name = "_Kill",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668916",
                UsesAllInstances = true,

                Color = Color3.fromRGB(255, 0, 0),
                ObjectType = "SelectionBox",
            }, {
                TagType = "NoChild",
                Name = "_SpeedBooster",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034754445",
                UsesAllInstances = true,

                Color = Color3.fromRGB(110, 203, 53),
                ObjectType = "SelectionBox",
            }, {
                TagType = "NoChild",
                Name = "_JumpBooster",
                LayoutOrder = 7,
                DisplayIcon = "rbxassetid://6034754445",
                UsesAllInstances = true,

                Color = Color3.fromRGB(190, 222, 48),
                ObjectType = "SelectionBox",
            }, {
                TagType = "Any",
                Name = "AirTank",
                LayoutOrder = 8,
                DisplayIcon = "rbxassetid://6031068426",
                UsesAllInstances = true,

                Color = Color3.fromRGB(41, 184, 232),
                ObjectType = "SelectionBox",
            },
        },
        Tooltip = {
            Header = "",
            Text = ""
        },
    },
    ButtonView = {
        TagType = "Any",
        SingleOption = true,
        Name = "_Button",
        ObjectType = "Button",
        DisplayText = "Button Preview",
        DisplayIcon = "rbxassetid://6026647916",
        LayoutOrder = 4,
        ViewOptions = {},
        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    ZiplineView = {
        TagType = "Any",
        Name = "Zipline",
        SingleOption = true,
        DisplayText = "Zipline Preview",
        DisplayIcon = "rbxassetid://6035067839",
        LayoutOrder = 5,
        ViewOptions = {},
        ObjectType = "Zipline",

        Tooltip = {
            Header = "",
            Text = ""
        }
    },
    VariantView = {
        DisplayText = "Variant View",
        SubText = "All Variants",
        AltSubText = "No Variants Found.",
        DisplayIcon = "rbxassetid://6022668909",
        LayoutOrder = 6,
        ViewOptions = varaints,
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
                TagType = "Addon",
                Name = "_Teleporter",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031082527",
                UsesAllInstances = true,

                Color = Color3.fromRGB(255, 255, 255),
                ObjectType = "SelectionBox"
            }, {
                TagType = "Addon",
                Name = "_Waterjet",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6022668890",
                UsesAllInstances = true,

                ObjectType = "Waterjet"
            }
        },
        Tooltip = {
            Header = "Map Addons View",
            Text = "Because the selected map has map addons that support Object & Button Tags, those tags can be visualized below."
        }
    },
}
