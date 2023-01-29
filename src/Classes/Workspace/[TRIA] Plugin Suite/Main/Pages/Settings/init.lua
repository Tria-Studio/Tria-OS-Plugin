local Lighting = game:GetService("Lighting")

local Package = script.Parent.Parent
local SelectMap = require(Package.SelectMap)
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Hydrate = Fusion.Hydrate
local ForValues = Fusion.ForValues
local ForPairs = Fusion.ForPairs
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Out = Fusion.Out

local frame = {}

local SettingData = require(script:WaitForChild("SettingData"))
local SettingsUtil = require(script:WaitForChild("SettingsUtil"))
local LightingExport = require(script:WaitForChild("LightingExport"))

local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local directories = SettingsUtil.Directories

function onMapChanged()
    -- Disconnect old connections
    SettingsUtil.SettingMaid:DoCleaning()
    
    local function updateNormalDataModule(module)
        for _, tbl in ipairs(module.Items) do
            local dirFolder = Util.getDirFolder(module.Directory)
            if not dirFolder then
                continue
            end
    
            -- Initially retrieve setting value
            local currentValue = dirFolder:GetAttribute(tbl.Attribute)
            local function updateConnection()
                SettingsUtil.updateStateValue(currentValue, dirFolder:GetAttribute(tbl.Attribute), tbl)
                SettingsUtil.hookAttributeChanged(dirFolder, tbl.Attribute, updateConnection)
            end
            updateConnection()
        end
    end

    -- Setup properties
    for directory, data in pairs(directories) do
        local dataModule = SettingData[directory]
        if dataModule then
            if not dataModule.Dynamic then
                updateNormalDataModule(dataModule)
            else
                dataModule:init()
            end
        end
    end
end

function getStandardDropdown(dirKey, dirData, visible)
    return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForValues(dirData.Items, function(data)
                return SettingsUtil.settingOption(data.Type, data)
            end, Fusion.cleanup)
        }
    }
end

function frame:GetFrame(data)
    local lightingDropdownVisible = Value(true)

    return New "Frame" {
        BackgroundTransparency = 0,
        Name = "Settings",
        Size = UDim2.fromScale(1, 1),
        Visible = data.Visible,

        [Children] = {
            Components.PageHeader("Map Settings"),

            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                Name = "Settings",
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                Visible = data.Visible,
                VerticalScrollBarInset = Enum.ScrollBarInset.None,

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),

                    ForPairs(directories, function(dirKey, dirData)
                        local dirDropdown = SettingsUtil.DirectoryDropdown(dirData, function(visible)
                            local dropdown
                            local dataModule = SettingData[dirKey]

                            dirData.Visible = visible
                            if dataModule then
                                if not dataModule.Dynamic then
                                    dropdown = getStandardDropdown(dirKey, dataModule, visible)
                                    return dropdown
                                else
                                    dropdown = dataModule:getDropdown(visible)
                                    return dropdown
                                end
                            end
                        end)

                        return dirKey, dirDropdown
                    end, Fusion.cleanup),

                    LightingExport
                }
            }
        }
    }
end

local function handleFolderRemoval()
    local map = Util.mapModel:get(false)
    if not map then
        return
    end

    local settingsFolder = map:FindFirstChild("Settings")

    -- Make sure we update when a major folder is deleted.
    SettingsUtil.SettingMaid:GiveTask(settingsFolder.ChildAdded:Connect(onMapChanged))
    SettingsUtil.SettingMaid:GiveTask(settingsFolder.ChildRemoved:Connect(onMapChanged))
end

for directory, data in pairs(directories) do
    local dataModule = SettingData[directory]
    if dataModule then
        for _, tbl in ipairs(dataModule.Items) do
            tbl.Errored = Value(false)
            SettingsUtil.modifyStateTable(data.Items, "insert", tbl)
        end
    end
end

-- insertLiquids()
onMapChanged()
handleFolderRemoval()

Util.MapChanged:Connect(function()
    -- insertLiquids()
    onMapChanged()
    handleFolderRemoval()
end)

plugin.Unloading:Connect(function()
    SelectMap._Maid:DoCleaning()
    Util.MainMaid:DoCleaning()
    SettingsUtil.SettingMaid:DoCleaning()
end)

return frame
