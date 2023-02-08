local HttpService = game:GetService("HttpService")
local Package = script.Parent.Parent.Parent.Parent.Parent

local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)
local Components = require(Package.Resources.Components)

local SettingsUtil = require(script.Parent.Parent.Parent.SettingsUtil)

local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues

local Data = {
	Directory = "Button",
	Dynamic = true,
	Items = {},
}

local directories = SettingsUtil.Directories

local buttonTypes = {"Default", "Group"}

function setupButtonFolder(folder: Instance)
	local buttonProperties = {
		{
			Text = "Activated Color",
			Type = "Color",
	
			Directory = "",
			Attribute = "ActivatedColor",
			Fallback = Util.colorToRGB(Color3.new(1, 0, 0)),
	
			Value = Value(Color3.new()),
			Tooltip = {
				Text = "The color of activated/pressed buttons",
			},
		},
	
		{
			Text = "Activated Sound",
			Type = "String",
	
			Directory = "",
			Attribute = "ActivatedSound",
			Fallback = "default",
	
			Value = Value("default"),
			Tooltip = {
				Text = "The sound buttons make when they are activated",
			},
		},
	
		{
			Text = "Active Color",
			Type = "Color",
	
			Directory = "",
			Attribute = "ActiveColor",
			Fallback = Util.colorToRGB(Color3.new(0, 1, 0)),
	
			Value = Value(Color3.new()),
			Tooltip = {
				Text = "The color of active buttons",
			},
		},
	
		{
			Text = "Inactive Color",
			Type = "Color",
	
			Directory = "",
			Attribute = "InactiveColor",
			Fallback = Util.colorToRGB(Color3.new(1, 1, 0)),
	
			Value = Value(Color3.new()),
			Tooltip = {
				Text = "The color of inactive buttons",
			},
		},
	
		{
			Text = "Locator Image",
			Type = "String",
	
			Directory = "",
			Attribute = "LocatorImage",
			Fallback = "default",
	
			Value = Value("default"),
			Tooltip = {
				Text = "The image ID used for the button locators",
			},
		},
	}

	local folderId = HttpService:GenerateGUID(false)

    for _, tbl in ipairs(buttonProperties) do
        tbl.Directory = "Button." .. folder.Name
        tbl.Errored = Value(false)
    end

    for _, buttonSetting in ipairs(buttonProperties) do
        SettingsUtil.connectValue(folder, buttonSetting)
    end

    local function update()
        SettingsUtil.modifyStateTable(directories.Buttons.Items, "set", folder, {
            Name = folder.Name, 
            Data = buttonProperties,
			ID = folderId
        })
    end
    update()
end

function insertButtonFolders()
	local buttonFolder = Util.getDirFolder("Button")
    if not buttonFolder then
        return
    end

    directories.Buttons.Items:set({})
    for _, v in ipairs(buttonTypes) do
        local folder = buttonFolder:FindFirstChild(v)
		if folder then
			setupButtonFolder(folder)
		end
    end
end

local buttonVisibleMap = {}
function Data:getDropdown(visible)
	return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForPairs(directories.Buttons.Items, function(folder, data)
                local itemName = data.Name
                local itemData = data.Data

                local liquidDropdown = SettingsUtil.DirectoryDropdown({
                    Default = true, 
					IsSecondary = true,
                    Display = itemName, 
                    LayoutOrder = data.Name == "Default" and 1 or data.Name == "Group" and 2 or 3,
					HeaderEditable = data.Name ~= "Default" and data.Name ~= "Group",
                    OnHeaderChange = function(newHeader)
						if not table.find(buttonTypes, newHeader) then
							return
						end
                        folder.Name = newHeader
                    end

                }, function(isSectionVisible)
                    if buttonVisibleMap[data.ID] then
                        isSectionVisible:set(buttonVisibleMap[data.ID])
                    else
                        buttonVisibleMap[data.ID] = isSectionVisible:get(false)
                    end
                    return Components.DropdownHolderFrame {
                        DropdownVisible = isSectionVisible,
                        Children = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
                            ForValues(itemData, function(tbl)
                                return SettingsUtil.settingOption(tbl.Type, tbl)
                            end, Fusion.cleanup)
                        }
                    }
                end)
                return folder, liquidDropdown
            end, Fusion.doNothing)
        }
    }
end

function Data:getHeaderChildren()
	return {}
end

function Data:init()
    insertButtonFolders()

	local function updateFolder(child)
		if table.find(buttonTypes, child.Name) then
			setupButtonFolder(child)
		end
	end

    local buttonFolder = Util.getDirFolder("Button")
    if buttonFolder then
        SettingsUtil.SettingMaid:GiveTask(buttonFolder.ChildAdded:Connect(function(child)
            updateFolder(child)
			SettingsUtil.SettingMaid:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(function()
				updateFolder(child)
			end))
        end))

        SettingsUtil.SettingMaid:GiveTask(buttonFolder.ChildRemoved:Connect(function(child)
            local items = directories.Buttons.Items
            if items:get(false)[child] then
                SettingsUtil.modifyStateTable(items, "set", child, nil)
            end
        end))
    end
end

return Data
