local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Hydrate = Fusion.Hydrate
local ForValues = Fusion.ForValues
local OnChange = Fusion.OnChange

local frame = {}

local SettingTypes = require(script:WaitForChild("SettingTypes"))
local SettingsData = require(script:WaitForChild("settingsData"))

function settingOption(optionType, optionData): Instance
    optionData.Modifiable = if optionData.Modifiable == nil then false else optionData.Modifiable
    
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

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
                    Components.Dropdown({
                        DefaultState = true,
                        Header = "Main",
                        LayoutOrder = 1
                    }, function(visible)
                        local baseFrame = Components.DropdownHolderFrame({DropdownVisible = visible})
                        return Hydrate(baseFrame) {
                            Name = "MainDropdown",
                            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
                            VerticalScrollBarInset = Enum.ScrollBarInset.None,

                            [Children] = {
                                Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, nil, Enum.VerticalAlignment.Top)
                            }
                        }
                    end)
                }
            }
        }
    }
end

return frame
