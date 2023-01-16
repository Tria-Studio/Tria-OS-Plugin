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
    ["String"] = function(str)
        return str:match("%w")
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
        if tbl.Type == "String" and settingTypeToMatchStringMap[tbl.Type](tostring(currentValue)) == false then
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
        Name = "MainDropdown",
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        [Children] = data.Children
    }
end

local directories = {
    {
        Name = "Main",
        Default = true,
        Display = "Main"
    },
    {
        Name = "Skills",
        Default = true,
        Display = "Skills and Features"
    },
    {
        Name = "Lighting",
        Default = true,
        Display = "Lighting"
    }
}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Settings",

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

                                    ForValues(SettingData, function(data)
                                        if data.Directory == dirData.Name then
                                            return settingOption(data.Type, data)
                                        end
                                    end, Fusion.cleanup),
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
