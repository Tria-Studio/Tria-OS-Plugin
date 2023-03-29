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
            Name = name,
            Color = Color3.fromHSV((i / #Util.variantFolderChildren:get()), .25,.875),
            DisplayIcon = "rbxassetid://6035067831"
        })
    end

    varaints:set(newTable)
end)

return {
    LowDetail = {
        TagType = "Parent",
        SingleOption = true,
        DisplayText = "Low Detail View",
        DisplayIcon = "rbxassetid://6034925618",
        LayoutOrder = 1,
        ViewOptions = {},
        Color = Color3.fromRGB(187, 67, 227),
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
                TagType = "Any",
                Name = "_Show",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031075931",
                Color = Color3.fromRGB(51, 162, 48),
            }, {
                TagType = "Any",
                Name = "_Hide",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6031075929",
                Color = Color3.fromRGB(75, 52, 156),
            }, {
                TagType = "Any",
                Name = "_Fall",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://12903664425",
                Color = Color3.fromRGB(214, 240, 99),
            }, {
                TagType = "Any",
                Name = "_Sound",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://6026671215",
                Color = Color3.fromRGB(102, 102, 102),
            }, {
                TagType = "Any",
                Name = "_Destroy",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668962",
                Color = Color3.fromRGB(135, 40, 40),
            }, {
                TagType = "Any",
                Name = "_Explode",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034684949",
                Color = Color3.fromRGB(240, 115, 48),
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
                Name = "WallJump",
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://9468872087",
                Color = Color3.fromRGB(180, 180, 180),
            }, {
                TagType = "Any",
                Name = "WallRun",
                LayoutOrder = 2,
                DisplayIcon = "rbxassetid://6026568215",
                Color = Color3.fromRGB(225, 225, 225),
            }, {
                TagType = "Any",
                Name = "_Liquid",
                LayoutOrder = 3,
                DisplayIcon = "rbxassetid://6026568295",
                Color = Color3.fromRGB(60, 60, 220)
            }, {
                TagType = "Any",
                Name = "_Gas",
                LayoutOrder = 4,
                DisplayIcon = "rbxassetid://6026568253",
                Color = Color3.fromRGB(206, 143, 211)
            }, {
                TagType = "NoChild",
                Name = "Killbrick",
                LayoutOrder = 5,
                DisplayIcon = "rbxassetid://6022668916",
                Color = Color3.fromRGB(255, 0, 0)
            }, {
                TagType = "NoChild",
                Name = "SpeedBooster",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034754445",
                Color = Color3.fromRGB(110, 203, 53)
            }, {
                TagType = "NoChild",
                Name = "JumpBooster",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6034754445",
                Color = Color3.fromRGB(190, 222, 48)
            }, {
                TagType = "Any",
                Name = "AirTank",
                LayoutOrder = 6,
                DisplayIcon = "rbxassetid://6031068426",
                Color = Color3.fromRGB(41, 184, 232)
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
        TagType = "Any",
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
                TagType = "Any",
                Name = "_Teleporter",
                Color = Color3.fromRGB(255, 255, 255),
                LayoutOrder = 1,
                DisplayIcon = "rbxassetid://6031082527",
            }, {
                TagType = "Any",
                Name = "_Waterjet",
                Color = Color3.fromRGB(89, 193, 248),
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
