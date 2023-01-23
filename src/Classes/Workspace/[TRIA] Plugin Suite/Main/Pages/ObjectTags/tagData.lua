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
        type = "EndOfName",
        dataType = "number",
        displayName = "Button #",
        default = 1,
    },
    ButtonNum = {
        type = "EndOfName",
        dataType = "number",
        displayName = "Button & Path #",
        default = 1,
    },
    GroupButton = {
        type = "Attribute",
        dataType = "boolean",
        displayName = "Group Button",
        default = false,
    },
    ActiveColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Active Color",
        default = nil,
    },
    ActivatedColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Activated Color",
        default = nil,
    },
    InactiveColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Inactive Color",
        default = nil,
    },
    DisabledColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Disabled Color",
        default = nil,
    },
    LocatorImage = {
        type = "Attribute",
        dataType = "string",
        displayName = "Locator Image",
        default = nil,
    },
    ActivatedSound = {
        type = "Attribute",
        dataType = "string",
        displayName = "Activated Sound",
        default = nil,
    },

    _Delay = {
        type = "ChildInstanceValue",
        dataType = "number",
        displayName = "Delay",
        default = 0,
        textBoxSize = -44
    },
    SoundId = {
        type = "ChildInstanceValue",
        dataType = "string",
        displayName = "Sound ID",
        default = "",
        textBoxSize = -60
    },
    LiquidNum = {
        type = "EndOfName",
        dataType = "number",
        displayName = "Liquid #",
        default = 1,
        textBoxSize = -179
    },
    LiquidType = {
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "liquids",
        displayName = "Type",
        default = 1,
    },
    Oxygen = {
        type = "Attribute",
        dataType = "number",
        displayName = "Amount",
        default = 300,
        textBoxSize = -166
    },
    Speed = {
        type = "Attribute",
        dataType = "number",
        displayName = "WalkSpeed",
        default = 40,
        textBoxSize = -48
    },
    Momentum = {
        type = "Attribute",
        dataType = "number",
        displayName = "Momentum",
        default = 0,
        textBoxSize = -48   
    },
    WalkSpeed = {
        type = "Attribute",
        dataType = "number",
        displayName = "WalkSpeed",
        default = 100,
        textBoxSize = -166  
    },
    JumpPower = {
        type = "Attribute",
        dataType = "number",
        displayName = "JumpPower",
        default = 100,
        textBoxSize = -166
    },


    ZiplineColor = {
        type = "ConfigAttribute",
        dataType = "color",
        displayName = "Wire Color",
        default = Color3.fromRGB(255, 10 , 10),
    },
    ZiplineJumpable = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Jumpable Ziplines",
        default = false,
    },
    ZiplineMaterial = {
        type = "ConfigAttribute",
        dataType = "dropdown",
        dropdownType = "materials",
        default = "Fabric",
        displayName = "Wire Material",
    },
    ZiplineMomentum = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Momentum",
        default = true,
    },
    ZiplineSparkle = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Wire Sparkles",
        default = true,
    },
    ZiplineSpeed = {
        type = "ConfigAttribute",
        dataType = "number",
        displayName = "Speed",
        default = 40,
        textBoxSize = -44
    },
    ZiplineWidth = {
        type = "ConfigAttribute",
        dataType = "number",
        displayName = "Wire Thickness",
        default = 0.25,
        textBoxSize = -48
    },
}

data.dataTypes = {
    buttonTags = {
        _Show = {
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
            IsTagApplicable = true,
        },
        _Hide = {
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
            IsTagApplicable = true,
        },
        _Fall = {
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
            IsTagApplicable = true,
        },
        _Destroy = {
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
            IsTagApplicable = true,
        },
        _Sound = {
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
            IsTagApplicable = true,
        },
        _Explode = {
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
            IsTagApplicable = true,
        },
    },
    objectTags = {
        _WallRun = {
            DisplayText = "WallRun",
            DisplayIcon = "rbxassetid://9468872087",
            LayoutOrder = 3,
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
            IsTagApplicable = true,
        },
        _WallJump = {
            DisplayText = "WallJump",
            DisplayIcon = "rbxassetid://9468872087",
            LayoutOrder = 2,
            metadata = {},
            IsTagApplicable = true,
        },
        _Liquid = {
            DisplayText = "_Liquid",
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
            IsTagApplicable = true,
        },
        _Gas = {
            DisplayText = "_Gas",
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
            IsTagApplicable = true,
        },
        _Button = {
            DisplayText = "_Button",
            DisplayIcon = "rbxassetid://6026647916",
            LayoutOrder = 4,
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
                    data = data.metadataTypes.ActivatedSound,
                    location = 11,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.LocatorImage,
                    location = 13,
                    isFullSize = true,
                },
            },
            IsTagApplicable = false,
        },
        Detail = {
            DisplayText = "Low Detail",
            DisplayIcon = "rbxassetid://6034925618",
            LayoutOrder = 1,
            metadata = {},
            IsTagApplicable = true,
        },
        Zipline = {
            DisplayText = "Zipline",
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
            IsTagApplicable = false,
        },
        _Kill = {
            DisplayText = "Killbrick",
            DisplayIcon = "rbxassetid://6022668916",
            LayoutOrder = 6,
            metadata = {},
            IsTagApplicable = true,
        },
        AirTank = {
            DisplayText = "AirTank",
            DisplayIcon = "rbxassetid://6031068426",
            LayoutOrder = 10,
            metadata = {
                {
                    data = data.metadataTypes.Oxygen,
                    location = 1,
                    isFullSize = true,
                },
            },
            IsTagApplicable = false,
        },
        _SpeedBooster = {
            DisplayText = "SpeedBooster",
            DisplayIcon = "rbxassetid://6034754445",
            LayoutOrder = 8,
            metadata = {
                {
                    data = data.metadataTypes.WalkSpeed,
                    location = 1,
                    isFullSize = true,
                },
            },
            IsTagApplicable = true,
        },
        _JumpBooster = {
            DisplayText = "JumpBooster",
            DisplayIcon = "rbxassetid://6034754445",
            LayoutOrder = 9,
            metadata = {
                {
                    data = data.metadataTypes.JumpPower,
                    location = 1,
                    isFullSize = true,
                },
            },
            IsTagApplicable = true,
        },
    }
}

return data
