local data = {}

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
    PlayerPercentage = {
        _referenceName = "PlayerPercentage",
        type = "Attribute",
        dataType = "number",
        dataName = "PlayerPercentage",
        displayName = "Player %",
        default = 50,
        _onlyShow = {
            {
                Attribute = "Group",
                Value = true
            },
        }
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
    Gravity = {
        _referenceName = "Gravity",
        type = "Attribute",
        dataType = "number",
        dataName = "Gravity",
        displayName = "Gravity",
        default = 196.2,
    },

    EasingStyle = {
        _referenceName = "EasingStyle",
        type = "Attribute",
        dataType = "string",
        dataName = "EasingStyle",
        displayName = "EasingStyle",
        default = "Linear",
    },
    TweenDuration = {
        _referenceName = "TweenDuration",
        type = "Attribute",
        dataType = "number",
        dataName = "TweenDuration",
        displayName = "TweenDuration",
        default = 3,
    },

    Power = {
        _referenceName = "Power",
        type = "Attribute",
        dataType = "number",
        dataName = "Power",
        displayName = "Power",
        default = 300,
    },
    Timeout = {
        _referenceName = "Timeout",
        type = "Attribute",
        dataType = "number",
        dataName = "Timeout",
        displayName = "Timeout",
        default = 1,
    },
    OrbType = {
        _referenceName = "OrbType",
        type = "Attribute",
        dataType = "dropdown",
        dataName = "Type",
        dropdownType = "OrbType",
        displayName = "Type",
        default = "Launch",
    },

    SetCameraFront = {
        _referenceName = "SetCameraFront",
        type = "Attribute",
        dataName = "SetCameraFront",
        dataType = "boolean",
        displayName = "Set Camera Front",
        default = false,
    },

    AllowLeaning = {
        _referenceName = "AllowLeaning",
        type = "ConfigAttribute",
        dataName = "AllowLeaning",
        dataType = "boolean",
        displayName = "Allow Leaning",
        default = false,
    },

    UseFrontOnly = {
        _referenceName = "UseFrontOnly",
        type = "Attribute",
        dataType = "boolean",
        dataName = "UseFrontOnly",
        displayName = "Front Face Only",
        default = false,
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
    RailJumpable = {
        _referenceName = "RailJumpable",
        type = "ConfigAttribute",
        dataType = "boolean",
        dataName = "Jumpable",
        displayName = "Jumpable Rails",
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
        dataType = "number",
        dataName = "Momentum",
        displayName = "Momentum",
        default = 0,
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

    Falloff = {
        _referenceName = "Falloff",
        type = "Attribute",
        dataType = "boolean",
        dataName = "Falloff",
        displayName = "Falloff",
        default = false,
    },


    WallrunSync = {
        _referenceName = "WallrunSync",
        type = nil,
        dataType = "button",
        dataName = "Sync Visuals with Speed",
        displayName = nil,

        callback = function()
            local Util = require(script.Parent.Parent.Parent.Util)
            local TagUtils = require(script.Parent.Parent.Parent.Util.TagUtils)

            for _, part: Instance in pairs(Util._Selection.selectedParts:get()) do
                if TagUtils:PartHasTag(part, "_WallRun") then
                    local Beam = part:FindFirstChildOfClass("Beam")

                    if Beam and Beam.TextureMode ~= Enum.TextureMode.Stretch then
                        local speed = part:GetAttribute("Speed")
                        local length = Beam.TextureLength
                        
                        Beam.TextureSpeed = -(length/speed)^-1
                    end
                end
            end
        end
    },

    ConvertToRail = {
        _referenceName = "ConvertToRail",
        dataType = "button",
        dataName = "Convert Zipline to Rail",

        callback = function()
            local Util = require(script.Parent.Parent.Parent.Util)
            local TagUtils = require(script.Parent.Parent.Parent.Util.TagUtils)

            if Util.mapModel:get():FindFirstChild("Special") then
                local newFolder = Util.mapModel:get().Special:FindFirstChild("Rail")

                if not newFolder then
                    newFolder = Instance.new("Folder")
                    newFolder.Name = "Rail"
                    newFolder.Parent = Util.mapModel:get().Special
                end

                for _, part: Instance in pairs(Util._Selection.selectedParts:get()) do
                    local model = part:IsA("Model") and part or part.Parent:IsA("Model") and part.Parent
                    
                    if model and TagUtils:PartHasTag(model, "Zipline") then
                        model.Name = "Rail"
                        model.Parent = newFolder
                    end
                end

            end
        end
    },
    ConvertToZipline = {
        _referenceName = "ConvertToZipline",
        dataType = "button",
        dataName = "Convert Rail to Zipline",

        callback = function()
            local Util = require(script.Parent.Parent.Parent.Util)
            local TagUtils = require(script.Parent.Parent.Parent.Util.TagUtils)

            if Util.mapModel:get():FindFirstChild("Special") then
                
                local newFolder = Util.mapModel:get().Special:FindFirstChild("Zipline")

                if not newFolder then
                    newFolder = Instance.new("Folder")
                    newFolder.Name = "Zipline"
                    newFolder.Parent = Util.mapModel:get().Special
                end

                for _, part: Instance in pairs(Util._Selection.selectedParts:get()) do
                    local model = part:IsA("Model") and part or part.Parent:IsA("Model") and part.Parent

                    if model and TagUtils:PartHasTag(model, "Rail") then
                        model.Name = "Zipline"
                        model.Parent = Util.mapModel:get().Special.Zipline
                    end
                end
            end 
        end
    }
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
            DisplayIcon = "rbxassetid://6022668885",
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
                }, {
                    data = data.metadataTypes.WallrunSync,
                    location = 3,
                    isFullSize = true,
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
            metadata = {
                {
                    data = data.metadataTypes.UseFrontOnly,
                    location = 1,
                    isFullSize = true,
                },
            },
            ApplyMethod = {
                "_Action",
                "Child"
            },
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Walljump",
                Text = [[Walljumps allow players to latch onto any side of a part, and jump off of it. After a certain time, you will fall off of the walljump.

Metadata:
    <font size="15"><b>Timeout: </b></font>The amount of time the user will cling to the walljump before falling off.]]
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
    <font size="15"><b>Meshless: </b></font>Determines whether or not the liquid is visible on all 6 faces, instead of just the <b>top face</b>.]]
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
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.PlayerPercentage,
                    location = 4, 
                    isFullSize = false,
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
    <font size="15"><b>Group: </b></font>Determines whether or not said button is a group button. Group buttons require the percent specified under PlayerPercentage (default 50%) of all players in the map to press.
    <font size="15"><b>Inactive Color: </b></font>Overrides the inactive color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Active Color: </b></font>Overrides the active color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Activated Color: </b></font>Overrides the activated color specified in map settings for this button. Leave empty for default.
    <font size="15"><b>Activated Sound: </b></font>Overrides the activated sound specified in map settings for this button. Leave empty for default.
    <font size="15"><b>LocatorImage: </b></font>Overrides the locator image specified in map settings for this button. Leave empty for default.
    <font size="15"><b>PlayerPercentage: </b></font>For group buttons, this will determine the percent of players which will need to have pressed the button in order to activate it..]]
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
            DisplayIcon = "rbxassetid://6031229350",
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
                    data = data.metadataTypes.RailJumpable,
                    location = 4,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineColor,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineMaterial,
                    location = 9,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineWidth,
                    location = 11,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineSparkle,
                    location = 3,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.AllowLeaning,
                    location = 5,
                    isFullSize = true,
                }, { 
                    data = data.metadataTypes.ConvertToRail,
                    location = 13,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,

            Tooltip = {
                Header = "Ziplines",
                Text = [[Ziplines are an interactive way to allow for people to travel from point A to point B in a map. Zipline ropes can be previewed with View Modes!

Ziplines support custom color gradients. To add a color gradient to a zipline, add a "UIGradient" Instance into the 'Configuration' Instance to customize it!

Ziplines support custom 'Sparkle's! Insert a ParticleEmitter named <b>'_Sparkle'</b> into the 'Configuration' Instance to customize it!

Metadata:
    <font size="15"><b>Momentum: </b></font>Determines whether or not you continue moving in the direction that you exited the zipline.
    <font size="15"><b>Jumpable: </b></font>Allows players to jump off ziplines mid zipline.
    <font size="15"><b>Color: </b></font>The color of the zipline.
    <font size="15"><b>Material: </b></font>The material of the zipline.
    <font size="15"><b>Zipline Width: </b></font>The width & height of the zipline cable.
    <font size="15"><b>Sparkle: </b></font>Determines if a sparkle particle will play where the player 'grabs' onto the zipline.]]
            },
        },
        Rail = {
            DisplayText = "Rail",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6031229350",
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
                    data = data.metadataTypes.RailJumpable,
                    location = 4,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineColor,
                    location = 7,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineMaterial,
                    location = 9,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineWidth,
                    location = 11,
                    isFullSize = true,
                }, {
                    data = data.metadataTypes.ZiplineSparkle,
                    location = 3,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.AllowLeaning,
                    location = 5,
                    isFullSize = true,
                }, { 
                    data = data.metadataTypes.ConvertToZipline,
                    location = 13,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,

            Tooltip = {
                Header = "Rails",
                Text = [[Rails (Like Ziplines) are an interactive way to allow for people to travel from point A to point B in a map. Rails can be previewed with View Modes!

Rails support custom 'Sparkle's! Insert a ParticleEmitter named <b>'_Sparkle'</b> into the 'Configuration' Instance to customize it!

Metadata:
    <font size="15"><b>Momentum: </b></font>Determines whether or not you continue moving in the direction that you exited the zipline.
    <font size="15"><b>Jumpable: </b></font>Allows players to jump off ziplines mid zipline.
    <font size="15"><b>Color: </b></font>The color of the zipline.
    <font size="15"><b>Material: </b></font>The material of the zipline.
    <font size="15"><b>Rail Width: </b></font>The width & height of the zipline cable.
    <font size="15"><b>Sparkle: </b></font>Determines if a sparkle particle will play where the player 'grabs' onto the zipline.]]
            },
        },
        _Kill = {
            DisplayText = "Killbrick",
            ActionText = "Kill",
            DisplayIcon = "rbxassetid://6031071053",
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
        Cancel = {
            DisplayText = "SkillCancel",
            ActionText = "Cancel",
            DisplayIcon = "rbxassetid://75012014640689",
            LayoutOrder = 6,
            metadata = {},

            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "SkillCancel",
                Text = "If a player is on a wallrun, or zipline/rail and they touch this, they will fall off of said skill."
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
                {
                    data = data.metadataTypes.EasingStyle,
                    location = 3,
                    isFullSize = false,
                }, 
                {
                    data = data.metadataTypes.TweenDuration,
                    location = 4,
                    isFullSize = false,
                }, 
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "_SpeedBooster",
                Text = [[Speed boosters allow for easy changing of the players walkspeed. Default player walkspeed is 20.
                    
Metadata:
    <font size="15"><b>WalkSpeed: </b></font>The speed the players WalkSpeed will be set to.
    <font size="15"><b>EasingStyle: </b></font>The name of the Enum.EasingStyle the gravity will change by.
    <font size="15"><b>TweenDuration: </b></font>How long it will take for their gravity to fully change.]]
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
                {
                    data = data.metadataTypes.EasingStyle,
                    location = 3,
                    isFullSize = false,
                }, 
                {
                    data = data.metadataTypes.TweenDuration,
                    location = 4,
                    isFullSize = false,
                }, 
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "_JumpBooster",
                Text = [[Jump boosters allow for easy changing of the players <u>JumpPower</u>. Default JumpPower is 50.
                    
Metadata:
    <font size="15"><b>JumpPower: </b></font>The power the players JumpPower will be set to.
    <font size="15"><b>EasingStyle: </b></font>The name of the Enum.EasingStyle the gravity will change by.
    <font size="15"><b>TweenDuration: </b></font>How long it will take for their gravity to fully change.]]
            },
        },
        Gravity = {
            DisplayText = "Gravity",
            ActionText = "Gravity",
            DisplayIcon = "rbxassetid://6034754445",
            LayoutOrder = 10,
            metadata = {
                {
                    data = data.metadataTypes.Gravity,
                    location = 1,
                    isFullSize = true,
                }, 
                {
                    data = data.metadataTypes.EasingStyle,
                    location = 3,
                    isFullSize = false,
                }, 
                {
                    data = data.metadataTypes.TweenDuration,
                    location = 4,
                    isFullSize = false,
                }, 
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Gravity",
                Text = [[Gravity pads allow for easy changing of the maps gravity. Default is 196.2.
                    
Metadata:
    <font size="15"><b>Gravity: </b></font>The new gravity the map will be set to.
    <font size="15"><b>EasingStyle: </b></font>The name of the Enum.EasingStyle the gravity will change by.
    <font size="15"><b>TweenDuration: </b></font>How long it will take for their gravity to fully change.]]
            },
        },
        BouncePad = {
            DisplayText = "BouncePad",
            ActionText = "BouncePad",
            DisplayIcon = "rbxassetid://104259770138609",
            LayoutOrder = 11,
            metadata = {
                {
                    data = data.metadataTypes.Power,
                    location = 1,
                    isFullSize = true,
                }
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "BouncePad",
                Text = [[A part that launches the player when touched in the direction of its Top face.
                    
Metadata:
    <font size="15"><b>Power: </b></font>The velocity, in studs, of how strong it should launch the player.]]
            },
        },
        Orb = {
            DisplayText = "Orb",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6031068426",
            LayoutOrder = 14,
            metadata = {
                {
                    data = data.metadataTypes.Power,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.Timeout,
                    location = 2,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.OrbType,
                    location = 3,
                    isFullSize = true,
                },
            },
            ApplyMethod = nil,
            IsTagApplicable = false,
            OnlyBaseParts = nil,

            Tooltip = {
                Header = "Orb",
                Text = [[A part that launches the player when inside. Orbs can launch players in a fixed direction, or allow players to determine where they exit.
                    
Metadata:
    <font size="15"><b>Timeout: </b></font>The amount of time the user will cling to the orb before falling out.]]
            },
        },
        Teleporter = {
            DisplayText = "Teleporter",
            ActionText = "Teleporter",
            DisplayIcon = "rbxassetid://6031082527",
            LayoutOrder = 13,
            metadata = {
                {
                    data = data.metadataTypes.SetCameraFront,
                    location = 1,
                    isFullSize = true,
                },
            },
            ApplyMethod = "_Action",
            IsTagApplicable = false,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Teleporter",
                Text = [[Teleports players when the main part is touched.
                    
Metadata:
    <font size="15"><b>SetCameraFront: </b></font>Determines whether the players camera should get orientated to the direction of the destination or not.]]
            },
        },
        AirTank = {
            DisplayText = "AirTank",
            ActionText = nil,
            DisplayIcon = "rbxassetid://6031488945", 
            LayoutOrder = 15,
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
        Jetstream = {
            DisplayText = "Jetstream",
            ActionText = "Jetstream",
            DisplayIcon = "rbxassetid://6022668890",
            LayoutOrder = 16,
            metadata = {
               {
                    data = data.metadataTypes.Power,
                    location = 1,
                    isFullSize = false,
                }, {
                    data = data.metadataTypes.Falloff,
                    location = 2,
                    isFullSize = false,
                },
            },
            ApplyMethod = "_Action",
            IsTagApplicable = true,
            OnlyBaseParts = true,

            Tooltip = {
                Header = "Waterjets",
                Text = [[A custom jetstream object that allows for underwater currents.

Metadata:
    <font size="15"><b>FanNumber: </b></font>A unique identifier for the fan in use of scripting.
    <font size="15"><b>FanSpeed: </b></font>Speed in studs/sec that the fan will push players inside its bounds.
    <font size="15"><b>LinearMovement: </b></font>When true, the fans push players at a constant rate throughout the entire distance. When false, the rate that the fan pushes players decreases as you get farther away.]]
            },
        },
    },
    addonTags = {}
}

return data
