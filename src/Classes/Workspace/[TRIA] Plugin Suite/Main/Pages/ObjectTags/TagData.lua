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
        dataType = "string",
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
        hideWhenNil = true,
        default = nil,
    },
    ActivatedColor = {
        _referenceName = "ActivatedColor",
        type = "Attribute",
        dataType = "color",
        dataName = "ActivatedColor",
        displayName = "Activated Color",
        hideWhenNil = true,
        default = nil,
    },
    InactiveColor = {
        _referenceName = "InactiveColor",
        type = "Attribute",
        dataType = "color",
        dataName = "InactiveColor",
        displayName = "Inactive Color",
        hideWhenNil = true,
        default = nil,
    },
    LocatorImage = {
        _referenceName = "LocatorImage",
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "Locators",
        dataName = "LocatorImage",
        displayName = "Locator Image",
        hideWhenNil = true,
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
        dropdownType = "LiquidType",
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
        dropdownType = "Materials",
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

    DoFlash = {
        _referenceName = "DoFlash",
        type = "Attribute",
        dataType = "boolean",
        dataName = "DoFlash",
        displayName = "Do Flash",
        default = true,
        _onlyShow = {
            {
                Attribute = "TeleportType",
                Value = "start"
            }
        }
    },
    FlashColor = {
        _referenceName = "FlashColor",
        type = "Attribute",
        dataType = "color",
        dataName = "FlashColor",
        displayName = "Flash Color",
        default = Color3.new(),
        _onlyShow = {
            {
                Attribute = "TeleportType",
                Value = "start"
            }, {
                Attribute = "DoFlash",
                Value = true
            }
        }
    },
    FlashDuration = {
        _referenceName = "FlashDuration",
        type = "Attribute",
        dataType = "number",
        dataName = "FlashDuration",
        displayName = "Flash Duration",
        default = 0.75,
        _onlyShow = {
            {
                Attribute = "TeleportType",
                Value = "start"
            }, {
                Attribute = "DoFlash",
                Value = true
            }
        }
    },
    TeleportType = {
        _referenceName = "TeleportType",
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "TeleportType",
        dataName = "TeleportType",
        displayName = "Teleport Type",
        default = "start",
    },
    TeleportNumber = {
        _referenceName = "TeleportNumber",
        type = "EndOfName",
        dataType = "number",
        dataName = "TeleportNumber",
        displayName = "Teleport Number",
        default = 0,
    },

    FanNumber = {
        _referenceName = "FanNumber",
        type = "EndOfName",
        dataType = "number",
        dataName = "FanNumber",
        displayName = "Fan #",
        default = 0,
    },
    FanSpeed = {
        _referenceName = "FanSpeed",
        type = "Attribute",
        dataType = "number",
        dataName = "FanSpeed",
        displayName = "Fan Speed",
        default = 32,
    },
    Distance = {
        _referenceName = "Distance",
        type = "Attribute",
        dataType = "number",
        dataName = "Distance",
        displayName = "Jet Distance",
        default = 24,
    },
    LinearMovement = {
        _referenceName = "LinearMovement",
        type = "Attribute",
        dataType = "boolean",
        dataName = "LinearMovement",
        displayName = "Linear Movement",
        default = false,
    },
    Enabled = {
        _referenceName = "Enabled",
        type = "Attribute",
        dataType = "boolean",
        dataName = "Enabled",
        displayName = "Enabled",
        default = true,
    },
    EmissionFace = {
        _referenceName = "EmissionFace",
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "NormalId",
        dataName = "EmissionFace",
        displayName = "Emission Face",
        default = "front",
    },
    FanShape = {
        _referenceName = "FanShape",
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "FanShape",
        dataName = "FanShape",
        displayName = "Fan Shape",
        default = "Square",
    },
    BubbleParticle = {
        _referenceName = "BubbleParticle",
        type = "Attribute",
        dataType = "dropdown",
        dropdownType = "BubbleParticle",
        dataName = "BubbleParticle",
        displayName = "Bubble Particle",
        default = "default",
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

            Tooltip = {
                Header = "_Show#",
                Text = [[Selected Part(s) will appear when the following button is pressed.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect]]
            },
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

            Tooltip = {
                Header = "_Hide#",
                Text = [[Selected Part(s) will be hidden, NOT destroyed when the button is activated. Use this if you want a part to hide then reappear.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect]]
            },
        },
        _Fall = {
            _nameStub = "_Fall",
            DisplayText = "_Fall#",
            DisplayIcon = "rbxassetid://12903664425",
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

            Tooltip = {
                Header = "_Fall#",
                Text = [[Selected Part(s) will become CanCollide false and get deleted after a few seconds when the following button is pressed.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect]]
            },
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

            Tooltip = {
                Header = "_Destroy#",
                Text = [[Selected Part(s) will be <u>destroyed</u> when the following button is pressed.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect]]
            },
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
            _instanceType = "Sound",
            ApplyMethod = "Child",
            IsTagApplicable = true,
            OnlyBaseParts = false,

            Tooltip = {
                Header = "_Sound#",
                Text = [[Selected Part(s) will play a sound with the given AssetID when the following button is pressed.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect
    <font size="15"><b>SoundID#: </b></font>Asset ID of the desired sound. To edit the sound further, use the Properties widget.]]
            },
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

            Tooltip = {
                Header = "_Explode#",
                Text = [[Selected Part(s) will explode when the following button is pressed.

Metadata:
    <font size="15"><b>Button#: </b></font>Defines what button the tag will activate
    <font size="15"><b>Delay#: </b></font>Amount of time in seconds that the tag will wait to take effect]]
            },
        },
    },
    objectTags = {
        _WallRun = {
            DisplayText = "WallRun",
            ActionText = "WallRun",
            DisplayIcon = "rbxassetid://6026568215",
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

            Tooltip = {
                Header = "Wallrun",
                Text = [[Wallruns allow players to latch onto the sides of parts and slide along them in the direction of the face and allow the player to jump off at any time.

Metadata:
    <font size="15"><b>Speed: </b></font>Speed in studs per second that the player will move on the wallrun. Speeds &lt;20 is slower than your walkspeed.
    <font size="15"><b>Momentum: </b></font>a scalar value that determines how much speed the player will carry off of the wallrun into the air.]]
            },
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

            Tooltip = {
                Header = "Walljump",
                Text = "Walljumps allow players to latch onto any side of a part, and jump off of it. After a certain time, you will fall off of the walljump."
            },
        },
        _Liquid = {
            _nameStub = "_Liquid",
            DisplayText = "_Liquid#",
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

            Tooltip = {
                Header = "Liquids",
                Text = [[Liquids are elements that the player can swim inside if the center of their torso is submerged. Liquid type can alter the appearance and oxygen depletion rate of the player.
                
<font size="15"><font color = "rgb(0, 143, 156)"><b>Water: </b></font></font> -8 oxygen/sec
<font size="15"><font color = "rgb(0, 255, 0)"><b>Acid: </b></font></font> -30 oxygen/sec
<font size="15"><font color = "rgb(255, 0, 0)"><b>Lava: </b></font></font> Instant death

You can specify the oxygen depletion, default color, and splash sound with custom liquids.

Metadata:
    <font size="15"><b>Liquid#: </b></font> Used to identify this liquid for others. Useful for coding your map.
    <font size="15"><b>Type: </b></font> Determines if the liquid is water, lava, etc.
    <font size="15"><b>Meshless: </b></font>Determines whether or not the liquid is visible on all 6 faces, instead of just one face.]]
            },
        },
        _Gas = {
            _nameStub = "_Gas",
            DisplayText = "_Gas#",
            ActionText = nil, 
            DisplayIcon = "rbxassetid://6026568253",
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

            Tooltip = {
                Header = "_Gas#",
                Text = [[Gas objects are similar to Liquids, except players do not swim in gas. Gas uses the same types as liquids with the same oxygen depletion rates.

<font size="15"><font color = "rgb(0, 143, 156)"><b>Water: </b></font></font> -8 oxygen/sec
<font size="15"><font color = "rgb(0, 255, 0)"><b>Acid: </b></font></font> -30 oxygen/sec
<font size="15"><font color = "rgb(255, 0, 0)"><b>Lava: </b></font></font> Instant death

Custom oxygen depletion rates can be specified with custom liquids.

Metadata:
    <font size="15"><b>Liquid#: </b></font> Used to identify this liquid for others. Useful for coding your map.
    <font size="15"><b>Type: </b></font> Determines if the liquid is water, lava, etc.]]
            },
        },
        _Button = {
            _nameStub = "_Button",
            DisplayText = "_Button#",
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
                    data = data.metadataTypes.ActiveColor,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ActivatedColor,
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
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,

            Tooltip = {
                Header = "_Button#",
                Text = [[Buttons are an object which players must press in sequential order in order to progress through and complete a map. Events can be called with object tags and within the MapScript to customize your map further.

Metadata:
    <font size="15"><b>Button# & Path#: </b></font>Allows you to determine the order in which buttons can be pressed. Letters after the button number allow you to have buttons that split into many different paths. Example: 5, 6, '5A', '6A'.
    <font size="15"><b>Group: </b></font>Determines whether or not said button is a group button. Group buttons require 50% of all players in the map to press.
    <font size="15"><b>Inactive Color: </b></font>Overrides the inactive color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Active Color: </b></font>Overrides the active color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Activated Color: </b></font>Overrides the activated color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Activated Sound: </b></font>Overrides the activated sound specified in map settings for this button. Leave empty for default.
    <font size="15"><b>LocatorImage: </b></font>Overrides the locator image specified in map settings for this button. Leave empty for default.]]
            },
        },
        _Detail = {
            DisplayText = "Low Detail",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6034925618",
            LayoutOrder = 0,
            metadata = {},
            ApplyMethod = "DetailParent",
            IsTagApplicable = true,
            OnlyBaseParts = false,

            Tooltip = {
                Header = "Low Detail",
                Text = "On medium and low detail, the detail folder will get deleted allowing for more people to experience your map. It is highly reccomended you use this feature, especially with large maps."
            },
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

            Tooltip = {
                Header = "Ziplines",
                Text = [[Ziplines are an interactive way to allow for people to travel from point A to point B in a map.

Metadata:
    <font size="15"><b>Momentum: </b></font>Determines whether or not you continue moving in the direction that you exited the zipline.
    <font size="15"><b>Jumpable: </b></font>Allows players to jump off ziplines mid zipline.
    <font size="15"><b>Color: </b></font>The color of the zipline.
    <font size="15"><b>Material: </b></font>The material of the zipline.
    <font size="15"><b>Zipline Width: </b></font>The width & height of the zipline cable.
    <font size="15"><b>Sparkle: </b></font>Determines if a sparkle particle will play where the player 'grabs' onto the zipline.]]
            },
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

            Tooltip = {
                Header = "Killbrick",
                Text = "Kills the player upon touch."
            },
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

            Tooltip = {
                Header = "Airtank",
                Text = [[Airtanks allow for extended underwater gameplay by allowing players to get extra oxygen. Airtanks cannot prevent you from dying to lava.
                    
Metadata:
    <font size="15"><b>Oxygen: </b></font>The amount of oxygen the player will obtain on collection of the tank.]]
            },
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

            Tooltip = {
                Header = "_SpeedBooster",
                Text = [[Speed boosters allow for easy changing of the players walkspeed. Default player walkspeed is 20.
                    
Metadata:
    <font size="15"><b>WalkSpeed: </b></font>The speed the players WalkSpeed will be set to.]]
            },
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

            Tooltip = {
                Header = "_JumpBooster",
                Text = [[Jump boosters allow for easy changing of the players <u>JumpPower</u>. Default JumpPower is 50.
                    
Metadata:
    <font size="15"><b>JumpPower: </b></font>The power the players JumpPower will be set to.]]
            },
        },
    },
    addonTags = {
        _Teleporter = {
            _nameStub = "_Teleporter",
            DisplayText = "_Teleporter",
            ActionText = "_Teleporter",
            DisplayIcon = "rbxassetid://6031082527",
            LayoutOrder = 2,
            metadata = {
                {
                    data = data.metadataTypes.TeleportNumber,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.TeleportType,
                    location = 3,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.DoFlash,
                    location = 5,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.FlashColor,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.FlashDuration,
                    location = 9,
                    isFullSize = true,
                },
            },
            ApplyMethod = "Name",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Teleporter",
                Text = [[A custom teleporter object from EasyTP that allows for the easy teleport of players inside a round.

Metadata:
    <font size="15"><b>TeleportNumber: </b></font>Determines which teleporters are linked together. There can only be one start and one end.
    <font size="15"><b>TeleportType: </b></font>Determines if its the start or the end of a link.
    <font size="15"><b>DoFlash: </b></font>Determines if the players screen will flash when telepored with the given color and duration.
    <font size="15"><b>FlashColor: </b></font>Determines the color of the flash that will play if DoFlash is true.
    <font size="15"><b>FlashDuration: </b></font>Determines the length of the flash if DoFlash is true.]]
            },
        },
        _Waterjet = {
            _nameStub = "_Waterjet",
            DisplayText = "_Waterjet",
            ActionText = "_Waterjet",
            DisplayIcon = "rbxassetid://6022668890",
            LayoutOrder = 1,
            metadata = {
                {
                    data = data.metadataTypes.FanNumber,
                    location = 1,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.FanSpeed,
                    location = 3,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.Distance,
                    location = 4,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.LinearMovement,
                    location = 5,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.FanShape,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.Enabled,
                    location = 9,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.BubbleParticle,
                    location = 11,
                    isFullSize = true,
                },
            },
            ApplyMethod = "Name",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Waterjets",
                Text = [[A custom jetstream object from the Waterjets Addon that allows for custom underwater jetstream currents.

Metadata:
    <font size="15"><b>FanNumber: </b></font>A unique identifier for the fan in use of scripting.
    <font size="15"><b>FanSpeed: </b></font>Speed in studs/sec that the fan will push players inside its bounds.
    <font size="15"><b>Distance: </b></font>The total distance that the fan can push you.
    <font size="15"><b>LinearMovement: </b></font>When true, the fans push players at a constant rate throughout the entire distance. When false, the rate that the fan pushes players decreases as you get farther away.
    <font size="15"><b>FanShape: </b></font>Determines if the bounds that the fan will push players in is a cylinder, or a box.
    <font size="15"><b>Enabled: </b></font>Determines whether the fan is currently active.
    <font size="15"><b>BubbleParticle: </b></font>The number of the ImageID that the fan's particles will show. 
]]
            },
        },
    }
}

return data
