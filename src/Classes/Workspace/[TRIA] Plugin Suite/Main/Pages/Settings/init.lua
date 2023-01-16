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
    {
        Name = "Main",
        Default = true,
        Display = "Main",
        LayoutOrder = 1
    },
    {
        Name = "Skills",
        Default = true,
        Display = "Skills and Features",
        LayoutOrder = 2
    },
    {
        Name = "Lighting",
        Default = true,
        Display = "Lighting",
        LayoutOrder = 3
    }
}

for _, tbl in ipairs(SettingData) do
    for _, v in ipairs(directories) do
        if not v.Items then
            v.Items = {}
        end
        if tbl.Directory == v.Name then
            table.insert(v.Items, tbl)
        end
    end
end
for _, t in ipairs(directories) do
    table.sort(t.Items, function(a, b)
        return a.Text < b.Text
    end)
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
                    ForPairs(directories, function(index, dirData)
                        return index, Components.Dropdown({
                            DefaultState = dirData.Default, 
                            Header = dirData.Display, 
                            LayoutOrder = index
                        }, function(visible)
                            return Components.DropdownHolderFrame {
                                DropdownVisible = visible,
                                Children = {
                                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),
                                    ForValues(dirData.Items, function(data)
                                        return settingOption(data.Type, data)
                                    end, Fusion.cleanup),

                                    --Make export frame but use layoutorder=4 because liquids uses 5
                                }
                            }
                        end)
                    end, Fusion.cleanup)
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
