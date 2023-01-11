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
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    GroupButton = {
        type = "Attribute",
        dataType = "boolean",
        default = false,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ActiveColor = {
        type = "Attribute",
        dataType = "color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ActivatedColor = {
        type = "Attribute",
        dataType = "color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    InactiveColor = {
        type = "Attribute",
        dataType = "color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    DisabledColor = {
        type = "Attribute",
        dataType = "color",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LocatorImage = {
        type = "Attribute",
        dataType = "string",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ACtivatedSound = {
        type = "Attribute",
        dataType = "string",
        default = nil,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },

    _Delay = {
        type = "ChildInstanceValue",
        dataType = "number",
        default = 0,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    SoundId = {
        type = "ChildInstanceValue",
        dataType = "string",
        default = "",
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LiquidNum = {
        type = "EndOfName",
        dataType = "number",
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    LiquidType = {
        type = "Attribute",
        dataType = "liquidSelect",
        default = 1,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Oxygen = {
        type = "Attribute",
        dataType = "number",
        default = 300,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Speed = {
        type = "Attribute",
        dataType = "number",
        default = 40,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    Momentum = {
        type = "Attribute",
        dataType = "number",
        default = 0,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    WalkSpeed = {
        type = "Attribute",
        dataType = "number",
        default = 100,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    JumpPower = {
        type = "Attribute",
        dataType = "number",
        default = 100,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },


    ZiplineColor = {
        type = "ConfigAttribute",
        dataType = "color",
        default = Color3.fromRGB(255, 10 , 10),
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineJumpable = {
        type = "ConfigAttribute",
        dataType = "boolean",
        default = false,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineMaterial = {
        type = "ConfigAttribute",
        dataType = "dropdown_materials",
        default = "Fabric",
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineMomentum = {
        type = "ConfigAttribute",
        dataType = "boolean",
        default = true,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineSparkle = {
        type = "ConfigAttribute",
        dataType = "boolean",
        default = true,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineSpeed = {
        type = "ConfigAttribute",
        dataType = "number",
        default = 40,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
    ZiplineWidth = {
        type = "ConfigAttribute",
        dataType = "number",
        default = 0.25,
        textLabelSize = UDim2.new(),
        textBoxSize = UDim2.new()
    },
}

data.dataTypes = {
    _Show = {
        DisplayText = "_Show#",
        DisplayIcon = "rbxassetid://6031075931",
        metadata = {
            data.metadataTypes.ButtonNum,
            data.metadataTypes._Delay
        },
        metadataLayout = {
            "Half",
            "Half",   
        },
        tagData = {
            format = "ObjectValue",
            changePartName = false,
        },
        IsTagApplicable = nil,
    }
}


return data
