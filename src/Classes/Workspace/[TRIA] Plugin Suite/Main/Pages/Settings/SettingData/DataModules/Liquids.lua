local HttpService = game:GetService("HttpService")
local Package = script.Parent.Parent.Parent.Parent.Parent

local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)
local Components = require(Package.Resources.Components)

local SettingsUtil = require(script.Parent.Parent.Parent.SettingsUtil)

local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues
local OnEvent = Fusion.OnEvent

local Data = {
	Directory = "Skills",
	Dynamic = true,
	Items = {},
}

local directories = SettingsUtil.Directories
local idToConfig = {}

function insertLiquids()
	local liquidFolder = Util.getDirFolder("Liquids")
    if not liquidFolder then
        return
    end

    directories.Liquids.Items:set({})
    for _, liquid in ipairs(liquidFolder:GetChildren()) do
        local liquidData = {
            {
                Text = "Color", 
                Type = "Color",  
                Attribute = "Color", 
                Fallback = Color3.new(1, 1, 1), 
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
                Type = "Number",  
                Attribute = "SplashSound", 
                Fallback = "water", 
                Value = Value(""),
                Tooltip = {Text = "The assetID of the sound that will play when entering/exiting this liquid/gas. Defaults to 'water'"}
            }
        }

        for _, tbl in ipairs(liquidData) do
            tbl.Directory = "Liquids." .. liquid.Name
            tbl.Errored = Value(false)
        end

        for _, liquidSetting in ipairs(liquidData) do
            local currentValue = liquid:GetAttribute(liquidSetting.Attribute)
            local function updateConnection()
                SettingsUtil.updateStateValue(currentValue, liquid:GetAttribute(liquidSetting.Attribute), liquidSetting)
                SettingsUtil.hookAttributeChanged(liquid, liquidSetting.Attribute, updateConnection)
            end
            updateConnection()
        end

        local liquidId = HttpService:GenerateGUID(false)
        idToConfig[liquidId] = liquid

        SettingsUtil.SettingMaid:GiveTask(liquid:GetPropertyChangedSignal("Name"):Connect(insertLiquids))
        SettingsUtil.modifyStateTable(directories.Liquids.Items, "insert", {
            Name = liquid.Name, 
            Data = liquidData,
            ID = liquidId
        })
    end
end

function addLiquid()
    local liquidFolder = Util.getDirFolder("Liquids")
    if not liquidFolder then
        return
    end

    local newLiquid = Instance.new("Configuration")
    newLiquid.Name = string.format("customliquid%d", #Util.mapModel:get().Settings.Liquids:GetChildren() + 1)
    newLiquid:SetAttribute("Color", Color3.new(1, 1, 1))
    newLiquid:SetAttribute("OxygenDepletion", 1)
    newLiquid:SetAttribute("SplashSound", "water")
    newLiquid.Parent = liquidFolder
end

function removeLiquid(id: string)
    if idToConfig[id] then
        idToConfig[id]:Destroy()
    end
end

function Data:getHeaderChildren()
    return Components.ImageButton {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.9, 0.5),
        Image = "rbxassetid://6035047391",
        HoverImage = "rbxassetid://6035047380",
        ImageColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(18, 18),
        ZIndex = 2,

        [OnEvent "Activated"] = addLiquid
    }
end

function Data:getDropdown(visible)
	return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForPairs(directories.Liquids.Items, function(index, data)
                local itemName = data.Name
                local itemData = data.Data

                local liquidDropdown = SettingsUtil.DirectoryDropdown({
                    Default = true, 
                    Display = itemName, 
                    LayoutOrder = index,
                    HeaderChildren = Components.ImageButton {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.9, 0.5),
                        Image = "rbxassetid://6035067843",
                        HoverImage = "rbxassetid://6035067837",
                        Size = UDim2.fromOffset(18, 18),
                        ZIndex = 2,
                
                        [OnEvent "Activated"] = function()
                            removeLiquid(data.ID)
                        end
                    }

                }, function(isSectionVisible)
                    return Components.DropdownHolderFrame {
                        DropdownVisible = isSectionVisible,
                        Children = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
                            ForValues(itemData, function(liquidData)
                                return SettingsUtil.settingOption(liquidData.Type, liquidData)
                            end, Fusion.cleanup)
                        }
                    }
                end)
                return index, liquidDropdown
            end, Fusion.cleanup)
        }
    }
end

function Data:init()
    insertLiquids()

    local liquidFolder = Util.getDirFolder("Liquids")
    if liquidFolder then
        SettingsUtil.SettingMaid:GiveTask(liquidFolder.ChildAdded:Connect(insertLiquids))
        SettingsUtil.SettingMaid:GiveTask(liquidFolder.ChildRemoved:Connect(insertLiquids))
    end
end

return Data
