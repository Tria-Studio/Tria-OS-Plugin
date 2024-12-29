local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local Package = script.Parent.Parent.Parent.Parent.Parent

local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)
local Components = require(Package.Resources.Components)
local PublicTypes = require(Package.PublicTypes)

local SettingsUtil = require(script.Parent.Parent.Parent.SettingsUtil)

local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues
local OnEvent = Fusion.OnEvent

local Data = {
	Directory = "Fluid",
	Dynamic = false,
	Items = {},
}

Data.Items = {
    {
		Text = "Refill Rate",
		Type = "Number",

		Attribute = "RefillRate",
		Fallback = 16,

		Value = Value(""),
		Tooltip = {
			Text = "How fast your oxygen will replenish per second when outside of a liquid & gas for a second.",
		},
	},

    {
		Text = "Default Oxygen",
		Type = "Number",

		Attribute = "DefaultOxygen",
		Fallback = 100,

		Value = Value(""),
		Tooltip = {
			Text = "How much oxygen you start with & the maximum amount you can have without a tank.",
		},
	},
}

local directories = SettingsUtil.Directories
local idToConfig = {}

local function addLiquidToItems(liquid: Instance | Configuration)
    local liquidData = {
        {
            Text = "Color", 
            Type = "Color",  
            Attribute = "Color", 
            Fallback = Color3.new(1, 1, 1), 
            Default = Color3.new(1, 1, 1),
            Value = Value(Color3.new(1, 1, 1)),
            Tooltip = {Text = "The color of this liquid/gas."}
        },
        {
            Text = "Oxygen Depletion", 
            Type = "Number",  
            Attribute = "OxygenDepletion", 
            Fallback = 1, 
            Value = Value(1),
            Tooltip = {Text = "How fast the oxygen will deplete when a player is inside this liquid/gas."}
        },
        {
            Text = "Splash Sound", 
            Type = "Dropdown",
            DropdownArray = "Liquids",
             
            Attribute = "SplashSound", 
            Fallback = "water", 
            Value = Value(""),
            Tooltip = {Text = "The assetID of the sound that will play when entering/exiting this liquid/gas. Defaults to 'water'"}
        }
    }

    local liquidId = HttpService:GenerateGUID(false)

    for _, tbl in ipairs(liquidData) do
        tbl.Directory = "Fluid." .. liquid.Name
        tbl.Errored = Value(false)
    end

    for _, liquidSetting in ipairs(liquidData) do
        SettingsUtil.connectValue(liquid, liquidSetting)
    end

    idToConfig[liquidId] = liquid

    local function update()
        SettingsUtil.modifyStateTable(directories.Fluid.Items, "set", liquid, {
            Name = liquid.Name, 
            Data = liquidData,
            ID = liquidId,
            _isCustomLiquid = true
        })
    end

    SettingsUtil.SettingMaid:GiveTask(liquid:GetPropertyChangedSignal("Name"):Connect(update))
    update()
end

local function insertLiquids()
	local liquidFolder = Util.getDirFolder("Fluid")
    if not liquidFolder then
        return
    end

    directories.Fluid.Items:set({})
    for _, liquid in ipairs(liquidFolder:GetChildren()) do
        addLiquidToItems(liquid)
    end
end

local function addLiquid()
    local recording = ChangeHistoryService:TryBeginRecording("CreateCustomLiquid", "Creating custom liqud")
    if recording then
        
        local liquidFolder = Util.getDirFolder("Fluid")
        if not liquidFolder then
            return
        end
        local currentMap = Util.mapModel:get(false)
        local newLiquid = Instance.new("Configuration")
        newLiquid.Name = string.format("Custom Liquid #%d", Util.getObjectCountWithNameMatch("Custom Liquid #", currentMap.Settings, true) + 1)
        newLiquid:SetAttribute("Color", Color3.new(1, 1, 1))
        newLiquid:SetAttribute("OxygenDepletion", 1)
        newLiquid:SetAttribute("SplashSound", "water")
        newLiquid.Parent = liquidFolder

        ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
    end
end

local function removeLiquid(id: string)
    if idToConfig[id] then
        idToConfig[id].Parent = nil
    end
end

function Data:getHeaderChildren(): Instance
    return Components.ImageButton {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Name = "_HeaderButton",
        Position = UDim2.fromScale(0.9, 0.5),
        Image = "rbxassetid://6035047391",
        HoverImage = "rbxassetid://6035047380",
        ImageColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(18, 18),
        ZIndex = 2,

        [OnEvent "Activated"] = addLiquid
    }
end

local liquidVisibleMap = {}

function Data:getDropdown(visible: Fusion.StateObject<boolean>): Instance
    local index = 0

	return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForPairs(directories.Fluid.Items, function(liquid: Instance, data: PublicTypes.Dictionary): (Instance, Instance)
                local itemName = data.Name
                local itemData = data.Data

                index += 1
                local liquidDropdown = SettingsUtil.DirectoryDropdown({
                    Default = false, 
                    Display = itemName, 
                    IsSecondary = true,
                    LayoutOrder = index,
                    HeaderChildren = Components.ImageButton {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.9, 0.5),
                        Image = "rbxassetid://6035067843",
                        HoverImage = "rbxassetid://6035067837",
                        Size = UDim2.fromOffset(18, 18),
                        ZIndex = 2,
                
                        [OnEvent "Activated"] = function()
                            removeLiquid(data.ID)
                        end
                    },

                    HeaderEditable = true,
                    HasButton = true,
                    OnHeaderChange = function(newHeader: string)
                        liquid.Name = newHeader
                    end

                }, function(isSectionVisible: Fusion.StateObject<boolean>): Instance
                    if not data._isCustomLiquid then
                        return
                    end
                    if liquidVisibleMap[data.ID] then  
                        isSectionVisible:set(liquidVisibleMap[data.ID])
                    else
                        liquidVisibleMap[data.ID] = isSectionVisible:get(false)
                    end

                    return Components.DropdownHolderFrame {
                        DropdownVisible = isSectionVisible,
                        Children = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
                            ForValues(itemData, function(liquidData: PublicTypes.Dictionary): Instance
                                return SettingsUtil.settingOption(liquidData.Type, liquidData)
                            end, Fusion.cleanup)
                        }
                    }
                end)
                return liquid, liquidDropdown
            end, Fusion.doNothing)
        }
    }
end

function Data:init()
    insertLiquids()

    local liquidFolder = Util.getDirFolder("Fluid")
    if liquidFolder then
        SettingsUtil.SettingMaid:GiveTask(liquidFolder.ChildAdded:Connect(function(child: Instance | Configuration)
            addLiquidToItems(child)
        end))
        SettingsUtil.SettingMaid:GiveTask(liquidFolder.ChildRemoved:Connect(function(child: Instance | Configuration)
            local items = directories.Fluid.Items
            if items:get(false)[child] then
                SettingsUtil.modifyStateTable(items, "set", child, nil)
            end
        end))
    end
end

return Data
