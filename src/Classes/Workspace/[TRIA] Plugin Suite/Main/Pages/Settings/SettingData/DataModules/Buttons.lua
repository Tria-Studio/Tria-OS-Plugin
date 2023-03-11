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

local Data = {
	Directory = "Button",
	Dynamic = true,
	Items = {},
}

local directories = SettingsUtil.Directories
local buttonTypes = {"Default", "Group"}

local function setupButtonFolder(folder: Instance)
	local buttonProperties = {
		{
			Text = "Activated Color",
			Type = "Color",
	
			Directory = "",
			Attribute = "ActivatedColor",
			Fallback = Util.colorToRGB(Color3.new(1, 0, 0)),
	
			Value = Value(Color3.new()),
			Tooltip = {
				Text = "The color of buttons that have already been pressed.\nSettings set per individual button overwrites these settings.",
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
				Text = "The sound buttons make when they are activated.\nUse \"default\" for default sound or your own assetID.\nSettings set per individual button overwrites these settings.",
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
				Text = "The color of the currently active button.\nSettings set per individual button overwrites these settings.",
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
				Text = "The color of buttons that are yet to be pressed, but not active.\nSettings set per individual button overwrites these settings.",
			},
		},
	
		{
			Text = "Locator Image",
			Type = "Dropdown",
			DropdownArray = "Locators",
	
			Directory = "",
			Attribute = "LocatorImage",
			Fallback = "default",
	
			Value = Value("default"),
			Tooltip = {
				Text = "The image ID used for the button locators.\n Use one of the 4 presets or your own assetID",
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

local function insertButtonFolders()
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
function Data:getDropdown(visible: Fusion.StateObject<boolean>): Instance
	return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForPairs(directories.Buttons.Items, function(folder: Instance, data: PublicTypes.Dictionary): (Instance, Instance)
                local itemName = data.Name
                local itemData = data.Data

                local buttonDropdown = SettingsUtil.DirectoryDropdown({
                    Default = true, 
					IsSecondary = true,
                    Display = itemName, 
                    LayoutOrder = data.Name == "Default" and 1 or data.Name == "Group" and 2 or 3,
					HeaderEditable = data.Name ~= "Default" and data.Name ~= "Group",
                    OnHeaderChange = function(newHeader: string)
						if not table.find(buttonTypes, newHeader) then
							return
						end
                        folder.Name = newHeader
                    end

                }, function(isSectionVisible: Fusion.StateObject<boolean>): Instance
                    if buttonVisibleMap[data.ID] then
                        isSectionVisible:set(buttonVisibleMap[data.ID])
                    else
                        buttonVisibleMap[data.ID] = isSectionVisible:get(false)
                    end
                    return Components.DropdownHolderFrame {
                        DropdownVisible = isSectionVisible,
                        Children = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
                            ForValues(itemData, function(tbl: PublicTypes.Dictionary): Instance
                                return SettingsUtil.settingOption(tbl.Type, tbl)
                            end, Fusion.cleanup)
                        }
                    }
                end)
                return folder, buttonDropdown
            end, Fusion.doNothing)
        }
    }
end

function Data:getHeaderChildren(): {}
	return {}
end

function Data:init()
    insertButtonFolders()

	local function updateFolder(child: Instance)
		if table.find(buttonTypes, child.Name) then
			setupButtonFolder(child)
		end
	end

    local buttonFolder = Util.getDirFolder("Button")
    if buttonFolder then
        SettingsUtil.SettingMaid:GiveTask(buttonFolder.ChildAdded:Connect(function(child: Instance)
            updateFolder(child)
			SettingsUtil.SettingMaid:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(function()
				updateFolder(child)
			end))
        end))

        SettingsUtil.SettingMaid:GiveTask(buttonFolder.ChildRemoved:Connect(function(child: Instance)
            local items = directories.Buttons.Items
            if items:get(false)[child] then
                SettingsUtil.modifyStateTable(items, "set", child, nil)
            end
        end))
    end
end

return Data