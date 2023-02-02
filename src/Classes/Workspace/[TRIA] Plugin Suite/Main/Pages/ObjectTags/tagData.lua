local data = {}

--[[
    TYPES: 
        - Attribute
        - ConfigAttribute
        - ChildInstanceValue
        - EndOfName
]]

data.metadataTypes = {
    Button = {
        _referenceName = "Button",
        type = "EndOfName",
        dataType = "number",
        dataName = nil,
        displayName = "Button #",
        default = 1,
    },
    ButtonNum = {
        _referenceName = "ButtonNum",
        type = "EndOfName",
        dataType = "number",
        dataName = nil,
        displayName = "Button & Path #",
        default = 1,
    },
    GroupButton = {
        _referenceName = "GroupButton",
        type = "Attribute",
        dataName = "Group",
        dataType = "boolean",
        displayName = "Group Button",
        default = false,
    },
    ActiveColor = {
        _referenceName = "ActiveColor",
        type = "Attribute",
        dataType = "color",
        dataName = "ActiveColor",
        displayName = "Active Color",
        default = nil,
    },
    ActivatedColor = {
        _referenceName = "ActivatedColor",
        type = "Attribute",
        dataType = "color",
        dataName = "ActivatedColor",
        displayName = "Activated Color",
        default = nil,
    },
    InactiveColor = {
        _referenceName = "InactiveColor",
        type = "Attribute",
        dataType = "color",
        dataName = "InactiveColor",
        displayName = "Inactive Color",
        default = nil,
    },
    DisabledColor = {
        _referenceName = "DisabledColor",
        type = "Attribute",
        dataType = "color",
        dataName = "DisabledColor",
        displayName = "Disabled Color",
        default = nil,
    },
    LocatorImage = {
        _referenceName = "LocatorImage",
        type = "Attribute",
        dataType = "string",
        dataName = "LocatorImage",
        displayName = "Locator Image",
        default = nil,
    },
    ActivatedSound = {
        _referenceName = "ActivatedSound",
        type = "Attribute",
        dataType = "string",
        dataName = "ActivatedSound",
        displayName = "Activated Sound",
        default = nil,
    },

    _Delay = {
        _referenceName = "_Delay",
        type = "ChildInstanceValue",
        dataType = "number",
        displayName = "Delay",
        dataName = "_Delay",
        default = 0,
    },
    SoundId = {
        _referenceName = "SoundId",
        type = "Property",
        _propertyName = "SoundId",
        dataType = "string",
        displayName = "Sound ID",
        default = "",
    },
    LiquidNum = {
        _referenceName = "LiquidNum",
        type = "EndOfName",
        dataType = "number",
        dataName = nil,
        displayName = "Liquid #",
        default = 0,
    },
    Meshless = {
        _referenceName = "Meshless",
        type = "Attribute",
        dataName = "Meshless",
        dataType = "boolean",
        displayName = "Meshless",
        default = false,
    },
    LiquidType = {
        _referenceName = "LiquidType",
        type = "Attribute",
        dataType = "dropdown",
        dataName = "Type",
        dropdownType = "liquids",
        displayName = "Type",
        default = "water",
    },
    Oxygen = {
        _referenceName = "Oxygen",
        type = "Attribute",
        dataType = "number",
        dataName = "Oxygen",
        displayName = "Amount",
        default = 300,
    },
    Speed = {
        _referenceName = "Speed",
        type = "Attribute",
        dataType = "number",
        dataName = "Speed",
        displayName = "Speed",
        default = 40,
    },
    Momentum = {
        _referenceName = "Momentum",
        type = "Attribute",
        dataType = "number",
        dataName = "Momentum",
        displayName = "Momentum",
        default = 0,
    },
    WalkSpeed = {
        _referenceName = "WalkSpeed",
        type = "Attribute",
        dataType = "number",
        dataName = "WalkSpeed",
        displayName = "WalkSpeed",
        default = 100,
    },
    JumpPower = {
        _referenceName = "JumpPower",
        type = "Attribute",
        dataType = "number",
        dataName = "JumpPower",
        displayName = "JumpPower",
        default = 100,
    },


    ZiplineColor = {
        _referenceName = "ZiplineColor",
        type = "ConfigAttribute",
        dataType = "color",
        dataName = "Color",
        displayName = "Wire Color",
        default = Color3.fromRGB(255, 10 , 10),
    },
    ZiplineJumpable = {
        _referenceName = "ZiplineJumpable",
        type = "ConfigAttribute",
        dataType = "boolean",
        dataName = "Jumpable",
        displayName = "Jumpable Ziplines",
        default = false,
    },
    ZiplineMaterial = {
        _referenceName = "ZiplineMaterial",
        type = "ConfigAttribute",
        dataType = "dropdown",
        dataName = "Material",
        dropdownType = "materials",
        default = "Fabric",
        displayName = "Wire Material",
    },
    ZiplineMomentum = {
        _referenceName = "ZiplineMomentum",
        type = "ConfigAttribute",
        dataType = "boolean",
        dataName = "Momentum",
        displayName = "Momentum",
        default = true,
    },
    ZiplineSparkle = {
        _referenceName = "ZiplineSparkle",
        type = "ConfigAttribute",
        dataType = "boolean",
        dataName = "Sparkle",
        displayName = "Wire Sparkles",
        default = true,
    },
    ZiplineSpeed = {
        _referenceName = "ZiplineSpeed",
        type = "ConfigAttribute",
        dataType = "number",
        dataName = "Speed",
        displayName = "Speed",
        default = 40,
    },
    ZiplineWidth = {
        _referenceName = "ZiplineWidth",
        type = "ConfigAttribute",
        dataType = "number",
        dataName = "Width",
        displayName = "Wire Thickness",
        default = 0.25,
    },
}

data.dataTypes = {
    buttonTags = {
        _Show = {
            _nameStub = "_Show",
            DisplayText = "_Show#",
            DisplayIcon = "rbxassetid://6031075931",
            LayoutOrder = 1,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        _Hide = {
            _nameStub = "_Hide",
            DisplayText = "_Hide#",
            DisplayIcon = "rbxassetid://6031075929",
            LayoutOrder = 2,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        _Fall = {
            _nameStub = "_Fall",
            DisplayText = "_Fall#",
            DisplayIcon = "rbxassetid://6031094674",
            LayoutOrder = 3,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        _Destroy = {
            _nameStub = "_Destroy",
            DisplayText = "_Destroy#",
            DisplayIcon = "rbxassetid://6022668962",
            LayoutOrder = 5,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        _Sound = {
            _nameStub = "_Sound",
            DisplayText = "_Sound#",
            DisplayIcon = "rbxassetid://6026671215",
            LayoutOrder = 4,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.SoundId,
                    location = 3,
                    isFullSize = true,
                }
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        _Explode = {
            _nameStub = "_Explode",
            DisplayText = "_Explode#",
            DisplayIcon = "rbxassetid://6034684949",
            LayoutOrder = 6,
            metadata = {
                {
                    data = data.metadataTypes.Button,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2,
                    isFullSize = false,
                },
            },
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
    },
    objectTags = {
        _WallRun = {
            DisplayText = "WallRun",
            ActionText = "WallRun",
            DisplayIcon = "rbxassetid://9468872087",
            LayoutOrder = 2,
            metadata = {
                {
                    data = data.metadataTypes.Speed,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.Momentum,
                    location = 2,
                    isFullSize = false,
                },
            },
            ApplyMethod = {
                "_Action",
                "Child"
            },
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        _WallJump = {
            DisplayText = "WallJump",
            ActionText = "WallJump",
            DisplayIcon = "rbxassetid://9468872087",
            LayoutOrder = 1,
            metadata = {},
            ApplyMethod = {
                "_Action",
                "Child"
            },
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        _Liquid = {
            _nameStub = "_Liquid",
            DisplayText = "_Liquid",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6026568295",
            LayoutOrder = 4,
            metadata = {
                {
                    data = data.metadataTypes.LiquidNum,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.LiquidType,
                    location = 3,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.Meshless,
                    location = 5,
                    isFullSize = true,
                },

            },
            ApplyMethod = "Name",
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        _Gas = {
            _nameStub = "_Gas",
            DisplayText = "_Gas",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6026568295",
            LayoutOrder = 5,
            metadata = {
                {
                    data = data.metadataTypes.LiquidNum,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.LiquidType,
                    location = 3,
                    isFullSize = true,
                },
            },
            ApplyMethod = "Name",
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        _Button = {
            _nameStub = "_Button",
            DisplayText = "_Button",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6026647916",
            LayoutOrder = 3,
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.GroupButton,
                    location = 3,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.InactiveColor,
                    location = 5,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.DisabledColor,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ActiveColor,
                    location = 9,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ActivatedColor,
                    location = 11,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ActivatedSound,
                    location = 13,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.LocatorImage,
                    location = 15,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,
        },
        Detail = {
            DisplayText = "Low Detail",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6034925618",
            LayoutOrder = 0,
            metadata = {},
            ApplyMethod = "DetailParent",
            IsTagApplicable = true,
            OnlyBaseParts = false,
        },
        Zipline = {
            DisplayText = "Zipline",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6035067839",
            LayoutOrder = 7,
            metadata = {
                {
                    data = data.metadataTypes.ZiplineSpeed,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.ZiplineMomentum,
                    location = 2,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.ZiplineJumpable,
                    location = 3,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineColor,
                    location = 5,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineMaterial,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineWidth,
                    location = 9,
                    isFullSize = true,
                },   {
                    data = data.metadataTypes.ZiplineSparkle,
                    location = 11,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,
        },
        _Kill = {
            DisplayText = "Killbrick",
            ActionText = "Kill",
            DisplayIcon = "rbxassetid://6022668916",
            LayoutOrder = 6,
            metadata = {},
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        AirTank = {
            DisplayText = "AirTank",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6031068426",
            LayoutOrder = 10,
            metadata = {
                {
                    data = data.metadataTypes.Oxygen,
                    location = 1,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,
        },
        _SpeedBooster = {
            DisplayText = "SpeedBooster",
            ActionText = "WalkSpeed",
            DisplayIcon = "rbxassetid://6034754445",
            LayoutOrder = 8,
            metadata = {
                {
                    data = data.metadataTypes.WalkSpeed,
                    location = 1,
                    isFullSize = true,
                },
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
        _JumpBooster = {
            DisplayText = "JumpBooster",
            ActionText = "JumpPower",
            DisplayIcon = "rbxassetid://6034754445",
            LayoutOrder = 9,
            metadata = {
                {
                    data = data.metadataTypes.JumpPower,
                    location = 1,
                    isFullSize = true,
                },
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,
        },
    }
}

return data
