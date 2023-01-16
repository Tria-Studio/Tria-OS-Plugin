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

local settingConnections = {}
local settingTypeToMatchStringMap = {
    ["String"] = function(val)
        return val:match("%w") ~= nil
    end,
    ["Number"] = function(val)
        return val:match("%d") ~= nil
    end,
    ["Checkbox"] = function(val)
        return val == "false" or val == "true"
    end,
    ["Color"] = function(val)
        return val:gsub(" ", ""):match("%d+,%d+,%d+") ~= nil
    end
}

local function settingOption(optionType, optionData): Instance
    optionData.Modifiable = if optionData.Modifiable == nil then false else optionData.Modifiable
    
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

function onMapChanged()
    for _, conn in ipairs(settingConnections) do
        conn:Disconnect()
    end
    for _, tbl in ipairs(SettingData) do
        local isUpdating = false

        local dirFolder = Util.getDirFolder(tbl.Directory)
        if not dirFolder then
            return
        end

        -- Initially retrieve setting value
        local currentValue = dirFolder:GetAttribute(tbl.Attribute)
        if settingTypeToMatchStringMap[tbl.Type](tostring(currentValue)) == false then
            return
        end

        tbl.Value:set(if currentValue ~= nil then currentValue elseif tbl.Fallback ~= nil then tbl.Fallback else "")
        
        -- Connect change signal
        table.insert(settingConnections, dirFolder:GetAttributeChangedSignal(tbl.Attribute):Connect(function()
            if isUpdating then
                return
            end
            isUpdating = true
            currentValue = dirFolder:GetAttribute(tbl.Attribute)
            tbl.Value:set(if currentValue ~= nil then currentValue elseif tbl.Fallback ~= nil then tbl.Fallback else "")
            isUpdating = false
        end))
    end
end

function settingDropdownFrame(data)
    local baseFrame = Components.DropdownHolderFrame({DropdownVisible = data.DropdownVisible})
    return Hydrate(baseFrame) {
        [Children] = data.Children
    }
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
    return New "ScrollingFrame" {
        BackgroundColor3 = Theme.MainBackground.Default,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        Name = "Settings",
        Size = UDim2.fromScale(1, 1),
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        Visible = data.Visible,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,

        [Children] = {
            Components.PageHeader("Map Settings"),
            Components.ScrollingFrame{
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.MainBackground.Default,

                Children = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),
                    ForPairs(directories, function(index, dirData)
                        return index, Components.Dropdown({
                            DefaultState = dirData.Default, 
                            Header = dirData.Display, 
                            LayoutOrder = index
                        }, function(visible)
                            return settingDropdownFrame({
                                DropdownVisible = visible,
                                Children = {
                                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top),

                                    ForValues(dirData.Items, function(data)
                                        return settingOption(data.Type, data)
                                    end, Fusion.cleanup),

                                    -- Make export frame but use layoutorder=4 because liquids uses 5
                                }
                            })
                        end)
                    end, Fusion.cleanup)
                }
            }
        }
    }
end


onMapChanged()
Util.MapChanged:Connect(function()
    onMapChanged()
end)

return frame
