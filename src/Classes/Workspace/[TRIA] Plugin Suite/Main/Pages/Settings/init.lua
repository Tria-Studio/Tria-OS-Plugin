local Lighting = game:GetService("Lighting")
local Package = script.Parent.Parent
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

local frame = {}

local SettingTypes = require(script:WaitForChild("SettingTypes"))
local SettingData = require(script:WaitForChild("SettingData"))
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local settingConnections = {}

local function settingOption(optionType, optionData): Instance
    optionData.Modifiable:set(if optionData.Modifiable:get() == nil then false else optionData.Modifiable:get())
    
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

function onMapChanged()
    for _, conn in ipairs(settingConnections) do
        conn:Disconnect()
    end
    for _, tbl in ipairs(SettingData) do
        local dirFolder = Util.getDirFolder(tbl.Directory)
        if not dirFolder then
            continue
        end

        -- Initially retrieve setting value
        local currentValue = dirFolder:GetAttribute(tbl.Attribute)
        local acceptedValues = {
            ["String"] = {"string", "number"},
            ["Number"] = {"string", "number"},
            ["Checkbox"] = {"boolean"},
            ["Color"] = {"Color3"},
            ["Time"] = {"string"}
        }

        local originalModifiableState = tbl.Modifiable:get()
        local changeConnection

        local function updateStateValue()
            currentValue = dirFolder:GetAttribute(tbl.Attribute)
            if not table.find(acceptedValues[tbl.Type], typeof(currentValue)) then
                tbl.Modifiable:set(false)
                tbl.Value:set(if tbl.Fallback then tbl.Fallback else "")
                Util.prefixWarn(("'%s' values aren't accepted for %s objects (%s)"):format(typeof(currentValue), tbl.Type, tbl.Text))
            else
                if originalModifiableState ~= tbl.Modifiable:get() then
                    tbl.Modifiable:set(originalModifiableState)
                end
                tbl.Value:set(if currentValue ~= nil then currentValue elseif tbl.Fallback ~= nil then tbl.Fallback else "")
            end
        end

        local function hookConnection()
            changeConnection = dirFolder:GetAttributeChangedSignal(tbl.Attribute):Once(function()
                changeConnection:Disconnect()
                task.defer(function()
                    updateStateValue()
                    task.defer(hookConnection)
                end)
            end)
            table.insert(settingConnections, changeConnection)
        end
        
        task.defer(function()
            updateStateValue()
            task.defer(hookConnection)
        end)
    end
end

local directories = {
    Main = {
        Default = true,
        Display = "Main",
        LayoutOrder = 1
    },
    Skills = {
        Default = true,
        Display = "Skills and Features",
        LayoutOrder = 2
    },
    Lighting = {
        Default = true,
        Display = "Lighting",
        LayoutOrder = 3
    }
}

for _, tbl in ipairs(SettingData) do
    for k, v in pairs(directories) do
        if not v.Items then
            v.Items = {}
        end
        if tbl.Directory == k then
            table.insert(v.Items, tbl)
        end
    end
end
for _, t in ipairs(directories) do
    table.sort(t.Items, function(a, b)
        return a.Text < b.Text
    end)
end

function ExportButton(props)
    return Hydrate(Components.TextButton {
        Active = true,
        AutoButtonColor = true,
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BackgroundTransparency = 0,
        BorderColor3 = Color3.fromRGB(53, 53, 53),
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 3,
        Size = UDim2.new(1, 0, 0, 22),
        TextColor3 = Color3.fromRGB(204, 204, 204),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })(props)
end

function exportLighting()
    for _, item in ipairs(directories.Lighting.Items) do
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
    for _, item in ipairs(directories.Lighting.Items) do
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

function frame:GetFrame(data)
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
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromScale(1, 1),
                TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                Visible = data.Visible,
                VerticalScrollBarInset = Enum.ScrollBarInset.None,

                Children = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),
                    ForPairs(directories, function(dirKey, dirData)
                        return dirKey, Components.Dropdown({
                            DefaultState = dirData.Default, 
                            Header = dirData.Display, 
                            LayoutOrder = dirData.LayoutOrder
                        }, function(visible)
                            return Components.DropdownHolderFrame {
                                DropdownVisible = visible,
                                Children = {
                                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),
                                    
                                    ForValues(dirData.Items, function(data)
                                        return settingOption(data.Type, data)
                                    end, Fusion.cleanup)
                                }
                            }
                        end)
                    end, Fusion.cleanup),

                    New "Frame" {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 1,
                        LayoutOrder = 4,
                        Size = UDim2.new(1, 0, 0, 50),

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

-- TODO:
-- > Export lighting frame
-- > Liquids

-- GRIF TODO:
-- I'm putting this here because I don't know how but when you can, could you:
-- > Fix all the colors to be Theme indexes (like subtext, border etc)
-- > Make the properties non editable when the ui is frozen (no map is selected.)

onMapChanged()
Util.MapChanged:Connect(function()
    onMapChanged()
end)

plugin.Unloading:Connect(function()
    warn("Unloading")
    for _, conn in ipairs(settingConnections) do
        conn:Disconnect()
    end
end)

return frame
