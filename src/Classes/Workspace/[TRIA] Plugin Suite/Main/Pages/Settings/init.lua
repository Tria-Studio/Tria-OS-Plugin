local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local ForValues = Fusion.ForValues
local ForPairs = Fusion.ForPairs
local Value = Fusion.Value

local frame = {}

local SettingData = require(script:WaitForChild("SettingData"))
local SettingsUtil = require(script:WaitForChild("SettingsUtil"))

local directories = SettingsUtil.Directories
for directory, data in pairs(directories) do
    data.Visible = Value(true)
end

local LightingExport = require(script:WaitForChild("LightingExport"))

local function onMapChanged()
    -- Disconnect old connections
    SettingsUtil.SettingMaid:DoCleaning()
    
    local function updateNormalDataModule(module: PublicTypes.Dictionary)
        for _, tbl in ipairs(module.Items) do
            if tbl._Dynamic then
                continue
            end

            local dirFolder = Util.getDirFolder(module.Directory)
            if not dirFolder then
                continue
            end
    
            -- Initially retrieve setting value
            SettingsUtil.connectValue(dirFolder, tbl)
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
                updateNormalDataModule(dataModule)
            end
        end
    end
end

local function getStandardDropdown(dirKey: string, dirData: PublicTypes.Dictionary, visible: Fusion.StateObject<boolean>): Instance
    return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForValues(dirData.Items, function(data: PublicTypes.Dictionary): Instance
                return SettingsUtil.settingOption(data.Type, data)
            end, Fusion.cleanup)
        }
    }
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
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
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                Visible = data.Visible,
                VerticalScrollBarInset = Enum.ScrollBarInset.None,

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),

                    Components.Spacer(false, 10, 5, 0),

                    ForPairs(directories, function(dirKey: string, dirData: PublicTypes.Dictionary): (string, Instance)
                        local dataModule = SettingData[dirKey]
                        dirData.HeaderChildren = if dataModule.Dynamic then dataModule:getHeaderChildren() else dirData.HeaderChildren

                        local dirDropdown = SettingsUtil.DirectoryDropdown(dirData, function(visible)
                            dirData.Visible = visible

                            if dataModule then
                                if dataModule.Dynamic then
                                    return dataModule:getDropdown(visible)
                                else
                                    return getStandardDropdown(dirKey, dataModule, visible)
                                end
                            end
                        end)

                        return dirKey, dirDropdown
                    end, Fusion.cleanup),

                    LightingExport:GetUI("Lighting"),
                    LightingExport:GetUI("Materials"),
                    LightingExport:GetUI("UI")
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
            tbl.Directory = directory
            tbl.Errored = Value(false)
            SettingsUtil.modifyStateTable(data.Items, "insert", tbl)
        end
    end
end

onMapChanged()
handleFolderRemoval()

Util.MapChanged:Connect(function()
    onMapChanged()
    handleFolderRemoval()
end)

return frame
