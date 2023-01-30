local Lighting = game:GetService("Lighting")

local Package = script.Parent.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Util = require(Package.Util)
local SettingsUtil = require(script.Parent.SettingsUtil)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Hydrate = Fusion.Hydrate

local directories = SettingsUtil.Directories

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
            Util.debugWarn(("Failed to set lighting setting '%s'"):format(tostring(settingToChange)))
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
            Util.debugWarn(("Failed to get lighting setting '%s'"):format(tostring(settingToRetrieve)))
        else
            item.Value:set(settingValue)
        end
    end
end

local frame = {}

function frame:GetUI()
	return New "Frame" {
		BackgroundTransparency = 1,
		BorderSizePixel = 1,
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 50),
		Visible = directories.Lighting.Visible,
	
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
end

return frame
