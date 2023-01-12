local data = {}

--[[
    TYPES: 
        - Attribute
        - ConfigAttribute
        - ChildInstanceValue
        - EndOfName
]]
data.metadataTypes = {
    ButtonNum = {
        type = "EndOfName",
        dataType = "number",
        displayName = "Button & Path #",
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    GroupButton = {
        type = "Attribute",
        dataType = "boolean",
        displayName = "Group Button",
        default = false,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ActiveColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Active Color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ActivatedColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Activated Color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    InactiveColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Inactive Color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    DisabledColor = {
        type = "Attribute",
        dataType = "color",
        displayName = "Disabled Color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LocatorImage = {
        type = "Attribute",
        dataType = "string",
        displayName = "Locator Image",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ActivatedSound = {
        type = "Attribute",
        dataType = "string",
        displayName = "Activated Sound",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    --//asd

    _Delay = {
        type = "ChildInstanceValue",
        dataType = "number",
        displayName = "Delay",
        default = 0,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    SoundId = {
        type = "ChildInstanceValue",
        dataType = "string",
        displayName = "Sound ID",
        default = "",
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LiquidNum = {
        type = "EndOfName",
        dataType = "number",
        displayName = "Liquid #",
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LiquidType = {
        type = "Attribute",
        dataType = "liquidSelect",
        displayName = "Type",
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Oxygen = {
        type = "Attribute",
        dataType = "number",
        displayName = "Amount",
        default = 300,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Speed = {
        type = "Attribute",
        dataType = "number",
        displayName = "WalkSpeed",
        default = 40,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Momentum = {
        type = "Attribute",
        dataType = "number",
        displayName = "Momentum",
        default = 0,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    WalkSpeed = {
        type = "Attribute",
        dataType = "number",
        displayName = "WalkSpeed",
        default = 100,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    JumpPower = {
        type = "Attribute",
        dataType = "number",
        displayName = "JumpPower",
        default = 100,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },


    ZiplineColor = {
        type = "ConfigAttribute",
        dataType = "color",
        displayName = "Wire Color",
        default = Color3.fromRGB(255, 10 , 10),
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineJumpable = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Jumpable Ziplines",
        default = false,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineMaterial = {
        type = "ConfigAttribute",
        dataType = "dropdown_materials",
        default = "Fabric",
        displayName = "Wire Material",
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineMomentum = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Momentum",
        default = true,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineSparkle = {
        type = "ConfigAttribute",
        dataType = "boolean",
        displayName = "Wire Sparkles",
        default = true,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineSpeed = {
        type = "ConfigAttribute",
        dataType = "number",
        displayName = "Speed",
        default = 40,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineWidth = {
        type = "ConfigAttribute",
        dataType = "number",
        displayName = "Wire Thickness",
        default = 0.25,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
}

data.dataTypes = {
    buttonTags = {
        _Show = {
            DisplayText = "_Show#",
            DisplayIcon = "rbxassetid://6031075931",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            tagFormat = "ObjectValue",
            IsTagApplicable = true,
        },
        _Hide = {
            DisplayText = "_Hide#",
            DisplayIcon = "rbxassetid://6031075929",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            tagFormat = "ObjectValue",
            IsTagApplicable = true,
        },
        _Fall = {
            DisplayText = "_Fall#",
            DisplayIcon = "rbxassetid://6031094674",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            tagFormat = "ObjectValue",
            IsTagApplicable = true,
        },
        _Destroy = {
            DisplayText = "_Destroy#",
            DisplayIcon = "rbxassetid://6022668962",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2
                }
            },
            tagFormat = "ObjectValue",
            IsTagApplicable = true,
        },
        _Sound = {
            DisplayText = "_Sound#",
            DisplayIcon = "rbxassetid://6026671215",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
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
            tagFormat = "Sound",
            IsTagApplicable = true,
        },
        _Explode = {
            DisplayText = "_Explode#",
            DisplayIcon = "rbxassetid://6034684949",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes._Delay,
                    location = 2,
                    isFullSize = false,
                },
            },
            tagFormat = "ObjectValue",
            IsTagApplicable = true,
        },
    },
    objectTags = {
        WallRun = {
            DisplayText = "WallRun",
            DisplayIcon = "rbxassetid://9468872087",
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
            tagFormat = "_Action",
            IsTagApplicable = true,
        },
        WallJump = {
            DisplayText = "WallJump",
            DisplayIcon = "rbxassetid://9468872087",
            metadata = {},
            tagFormat = "_Action",
            IsTagApplicable = true,
        },
        
        _Button = {
            DisplayText = "_Button",
            DisplayIcon = "rbxassetid://6274811030",
            metadata = {
                {
                    data = data.metadataTypes.ButtonNum,
                    location = 1,
                    isFullSize = false,
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
            tagFormat = nil,
            IsTagApplicable = false,
        },
        Detail = {
            DisplayText = "Low Detail",
            DisplayIcon = "rbxassetid://6034925618",
            metadata = {},
            tagFormat = "DetailFolder",
            IsTagApplicable = true,
        },
        Zipline = {
            DisplayText = "Zipline",
            DisplayIcon = "rbxassetid://6274811030",
            metadata = {
                {
                    data = data.metadataTypes.ZiplineColor,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineMaterial,
                    location = 3,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineWidth,
                    location = 5,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineSparkle,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineSpeed,
                    location = 9,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineMomentum,
                    location = 11,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineJumpable,
                    location = 13,
                    isFullSize = true,
                },
            },
            tagFormat = nil,
            IsTagApplicable = false,
        },
        Kill = {
            DisplayText = "Killbrick",
            DisplayIcon = "rbxassetid://6022668916",
            metadata = {},
            tagFormat = "_Action",
            IsTagApplicable = true,
        },
        AirTank = {
            DisplayText = "AirTank",
            DisplayIcon = "rbxassetid://6031068426",
            metadata = {
                {
                    data = data.metadataTypes.Oxygen,
                    location = 1,
                    isFullSize = false,
                },
            },
            tagFormat = nil,
            IsTagApplicable = false,
        },
        SpeedBoost = {
            DisplayText = "SpeedBooster",
            DisplayIcon = "rbxassetid://6034754445",
            metadata = {
                {
                    data = data.metadataTypes.WalkSpeed,
                    location = 1,
                    isFullSize = false,
                },
            },
            tagFormat = "_Action",
            IsTagApplicable = true,
        },
        JumpBoost = {
            DisplayText = "JumpBooster",
            DisplayIcon = "rbxassetid://6034754445",
            metadata = {
                {
                    data = data.metadataTypes.JumpPower,
                    location = 1,
                    isFullSize = false,
                },
            },
            tagFormat = "_Action",
            IsTagApplicable = true,
        },
    }
}

return data
