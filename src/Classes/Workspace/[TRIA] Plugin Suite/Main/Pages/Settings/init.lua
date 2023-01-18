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

local SettingTypes = require(script:WaitForChild("SettingTypes"))
local SettingData = require(script:WaitForChild("SettingData"))
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local settingConnections = {}

local directories = {
    Main = {
        Default = true,
        Display = "Main",
        LayoutOrder = 1,
        Items = Value({})
    },
    Skills = {
        Default = true,
        Display = "Skills and Features",
        LayoutOrder = 2,
        Items = Value({})
    },
    Lighting = {
        Default = true,
        Display = "Lighting",
        LayoutOrder = 3,
        Items = Value({})
    },
    Liquids = {
        Default = true,
        Display = "Liquids and Gas",
        LayoutOrder = 5,
        Items = Value({})
    }
}

function modifyStateTable(state, action, ...)
    local newTbl = state:get(false)
    local args = {...}

    if action == "insert" then
        table.insert(newTbl, args[1])
    elseif action == "set" then
        newTbl[args[1]] = args[2]
    end
    state:set(newTbl, true)
end

local function settingOption(optionType, optionData): Instance
    if optionData.Modifiable == nil then
        optionData.Modifiable = Value(true)
    end
    if optionData.Errored == nil then
        optionData.Errored = Value(false)
    end
    
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

local function hookAttributeChanged(parent, attribute, callback)
    local conn; conn = parent:GetAttributeChangedSignal(attribute):Once(function()
        conn:Disconnect()
        task.defer(callback)
    end)
    table.insert(settingConnections, conn)
end

local function updateStateValue(currentValue, newValue, tbl)
    local acceptedValues = {
        ["String"] = {"string", "number"},
        ["Number"] = {"string", "number"},
        ["Checkbox"] = {"boolean"},
        ["Color"] = {"Color3"},
        ["Time"] = {"string"}
    }

    if currentValue then
        currentValue = newValue
    end
    if not table.find(acceptedValues[tbl.Type], typeof(currentValue)) and tbl.Modifiable:get(false) then
        tbl.Errored:set(true)
        tbl.Value:set(if tbl.Fallback then tbl.Fallback else "")
        Util.prefixWarn(("'%s' values aren't accepted for %s objects (%s)"):format(typeof(currentValue), tbl.Type, tbl.Text))
    else
        tbl.Errored:set(false)
        tbl.Value:set(if currentValue ~= nil then currentValue elseif tbl.Fallback ~= nil then tbl.Fallback else "")
    end
end

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
                Modifiable = Value(true), 
                Attribute = "Color", 
                Fallback = Color3.new(1, 1, 1), 
                Value = Value(Color3.new(1, 1, 1)),
                Tooltip = {Text = "The color of this liquid/gas."}
            },
            {
                Text = "Oxygen Depletion", 
                Type = "Number", 
                Modifiable = Value(true), 
                Attribute = "OxygenDepletion", 
                Fallback = 1, 
                Value = Value(1),
                Tooltip = {Text = "How fast the oxygen will deplete when a player is inside this liquid/gas."}
            },
            {
                Text = "Splash Sound", 
                Type = "Number", 
                Modifiable = Value(true), 
                Attribute = "SplashSound", 
                Fallback = "water", 
                Value = Value(""),
                Tooltip = {Text = "The assetID of the sound that will play when entering/exiting this liquid/gas. Defaults to 'water'"}
            }
        }

        for _, tbl in ipairs(liquidData) do
            tbl.Directory = "Liquids." .. liquid.Name
        end

        for _, liquidSetting in ipairs(liquidData) do
            local currentValue = liquid:GetAttribute(liquidSetting.Attribute)
            
            local function updateConnection()
                if tbl.Modifiable:get(false) then
                    updateStateValue(currentValue, liquid:GetAttribute(liquidSetting.Attribute), liquidSetting)
                else
                    updateStateValue(nil, nil, liquidSetting)
                    Util.updateMapSetting(liquidSetting.Directory, liquidSetting.Attribute, liquidSetting.Fallback)
                end
                hookAttributeChanged(liquid, liquidSetting.Attribute, updateConnection)
            end
            updateConnection()
        end

        table.insert(settingConnections, liquid:GetPropertyChangedSignal("Name"):Connect(onMapChanged))
        modifyStateTable(directories.Liquids.Items, "insert", {Name = liquid.Name, Data = liquidData})
    end
end

function onMapChanged()
    -- Disconnect old connections
    for _, conn in ipairs(settingConnections) do
        conn:Disconnect()
    end

    do
        insertLiquids()
        local liquidFolder = Util.getDirFolder("Liquids")
        if liquidFolder then
            table.insert(settingConnections, liquidFolder.ChildAdded:Connect(insertLiquids))
            table.insert(settingConnections, liquidFolder.ChildRemoved:Connect(insertLiquids))
        end
    end
    
    -- Setup properties
    for _, tbl in ipairs(SettingData) do
        local dirFolder = Util.getDirFolder(tbl.Directory)
        if not dirFolder then
            continue
        end

        -- Initially retrieve setting value
        local currentValue = dirFolder:GetAttribute(tbl.Attribute)

        local originalModifiableState = tbl.Modifiable:get(false)
        local changeConnection

        local function updateConnection()
            if tbl.Modifiable:get(false) then
                updateStateValue(currentValue, dirFolder:GetAttribute(tbl.Attribute), tbl)
            else
                updateStateValue(nil, nil, tbl)
                Util.updateMapSetting(tbl.Directory, tbl.Attribute, tbl.Fallback)
            end
            hookAttributeChanged(dirFolder, tbl.Attribute, updateConnection)
        end
        updateConnection()
    end
end

function ExportButton(props)
    return Hydrate(Components.TextButton {
        Active = Util.interfaceActive,
        AutoButtonColor = Util.interfaceActive,

        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundColor3 = Theme.Button.Default,
        BackgroundTransparency = 0,
        BorderColor3 = Theme.ButtonBorder.Default,
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 3,
        Size = UDim2.new(1, 0, 0, 22),
        TextColor3 = Theme.MainText.Default,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })(props)
end

function exportLighting()
    for _, item in ipairs(directories.Lighting.Items:get(false)) do
        local settingToChange = if item.ExportAttribute then item.ExportAttribute else item.Attribute
        local settingValue = item.Value:get(false)

        local fired, _ = pcall(function()
            Lighting[settingToChange] = settingValue
        end)

        if not fired then
            Util.prefixWarn(("Failed to set lighting setting '%s'"):format(tostring(settingToChange)))
        end
    end
end

function importLighting()
    for _, item in ipairs(directories.Lighting.Items:get(false)) do
        local settingToRetrieve = if item.ExportAttribute then item.ExportAttribute else item.Attribute

        local fired, settingValue = pcall(function()
            return Lighting[settingToRetrieve]
        end)

        if not fired then
            Util.prefixWarn(("Failed to get lighting setting '%s'"):format(tostring(settingToChange)))
        else
            item.Value:set(settingValue)
        end
    end
end

function DirectoryDropdown(data, childProcessor)
    return Components.Dropdown({
        DefaultState = data.Default, 
        Header = data.Display, 
        LayoutOrder = data.LayoutOrder,
        HeaderColor = data.HeaderColor
    }, childProcessor)
end

function getStandardDropdown(dirKey, dirData, visible)
    return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForValues(dirData.Items, function(data)
                return settingOption(data.Type, data)
            end, Fusion.cleanup)
        }
    }
end

function getLiquidDropdown(dirData, visible)
    return Components.DropdownHolderFrame {
        DropdownVisible = visible,
        Children = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
            ForPairs(dirData.Items, function(index, data)
                local itemName = data.Name
                local itemData = data.Data

                local liquidDropdown = DirectoryDropdown({
                    Default = true, 
                    Display = itemName, 
                    LayoutOrder = index
                }, function(isSectionVisible)
                    return Components.DropdownHolderFrame {
                        DropdownVisible = isSectionVisible,
                        Children = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top, Enum.SortOrder.Name),
                            ForValues(itemData, function(liquidData)
                                return settingOption(liquidData.Type, liquidData)
                            end, Fusion.cleanup)
                        }
                    }
                end)
                return index, liquidDropdown
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
                        local dirDropdown = DirectoryDropdown(dirData, function(visible)
                            local dropdown
                            if dirKey ~= "Liquids" then
                                dropdown = getStandardDropdown(dirKey, dirData, visible)
                                if dirKey == "Lighting" then
                                    dropdown = Hydrate(dropdown) {
                                        [Out "Visible"] = lightingDropdownVisible
                                    }
                                end
                                return dropdown
                            else
                                dropdown = getLiquidDropdown(dirData, visible)
                                return dropdown
                            end
                        end)

                        return dirKey, dirDropdown
                    end, Fusion.cleanup),

                    New "Frame" {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 1,
                        LayoutOrder = 4,
                        Size = UDim2.new(1, 0, 0, 50),
                        Visible = lightingDropdownVisible,

                        [Children] = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, UDim.new(0, 2), Enum.VerticalAlignment.Center),
                            ExportButton {
                                LayoutOrder = 1,
                                Text = "Export to Lighting",

                                [OnEvent "Activated"] = function()
                                    local option1 = {
                                        Text = "Export",
                                        Callback = exportLighting,
                                        BackgroundColor3 = Theme.Button.Selected
                                    }
                            
                                    local option2 = {
                                        Text = "Cancel",
                                        BackgroundColor3 = Theme.Button.Default
                                    }

                                    Util:ShowMessage(
                                        "Export to lighting?", 
                                        "This will export the current lighting settings into your game's lighting system.", 
                                        option1, 
                                        option2
                                    )
                                end
                            },
                            ExportButton {
                                LayoutOrder = 2,
                                Text = "Import from Lighting",
                                [OnEvent "Activated"] = function()
                                    local option1 = {
                                        Text = "Import",
                                        Callback = importLighting,
                                        BackgroundColor3 = Theme.Button.Selected
                                    }
                            
                                    local option2 = {
                                        Text = "Cancel",
                                        BackgroundColor3 = Theme.Button.Default
                                    }

                                    Util:ShowMessage(
                                        "Import from lighting?", 
                                        "This will import the current lighting settings from your game into the map's settings.", 
                                        option1, 
                                        option2
                                    )
                                end
                            }
                        }
                    }
                }
            }
        }
    }
end

function frame:GetDirectories()
    return directories
end

local function handleLiquids()
    local map = Util.mapModel:get(false)
    if not map then
        return
    end

    local settingsFolder = map:FindFirstChild("Settings")

    -- Make sure we update when a major folder is deleted.
    table.insert(settingConnections, settingsFolder.ChildAdded:Connect(onMapChanged))
    table.insert(settingConnections, settingsFolder.ChildRemoved:Connect(onMapChanged))
end

insertLiquids()
for _, tbl in ipairs(SettingData) do
    for k, v in pairs(directories) do
        if tbl.Directory == k then
            modifyStateTable(v.Items, "insert", tbl)
        end
    end
end

onMapChanged()
handleLiquids()
Util.MapChanged:Connect(function()
    onMapChanged()
    handleLiquids()
end)

plugin.Unloading:Connect(function()
    warn("Unloading")
    SelectMap._Maid:DoCleaning()
    for _, conn in ipairs(settingConnections) do
        conn:Disconnect()
    end
end)

return frame