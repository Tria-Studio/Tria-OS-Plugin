local Package = script.Parent.Parent.Parent.Parent.Parent

local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)
local Components = require(Package.Resources.Components)

local SettingsUtil = require(script.Parent.Parent.Parent.SettingsUtil)

local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues

local Data = {
	Directory = "Skills",
	Dynamic = true,
	Items = {},
}

local directories = SettingsUtil.Directories

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

        SettingsUtil.SettingMaid:GiveTask(liquid:GetPropertyChangedSignal("Name"):Connect(insertLiquids))
        SettingsUtil.modifyStateTable(directories.Liquids.Items, "insert", {Name = liquid.Name, Data = liquidData})
    end
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
                    LayoutOrder = index
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
