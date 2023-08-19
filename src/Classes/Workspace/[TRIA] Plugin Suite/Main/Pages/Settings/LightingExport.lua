local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

local Package = script.Parent.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local SettingsUtil = require(script.Parent.SettingsUtil)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Hydrate = Fusion.Hydrate

local directories = SettingsUtil.Directories
 
local function ExportButton(props: PublicTypes.Dictionary): Instance
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

local function exportLighting()
	local recording = ChangeHistoryService:TryBeginRecording("ExportLighting", "Export lighting from map to game.Lighting")
	if recording then
		
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
	
		for _, LightObject in pairs(Lighting:GetChildren()) do
			if LightObject:IsA("PostEffect") or LightObject:IsA("Atmosphere") or LightObject:IsA("Sky") then
				LightObject.Parent = nil
			end
		end
		for _, LightObject in pairs(workspace.Terrain:GetChildren()) do
			if LightObject:IsA("Clouds") then
				LightObject.Parent = nil
			end
		end
	
		for _, NewLighting in pairs(Util.mapModel:get().Settings.Lighting:GetChildren()) do
			local Clone = NewLighting:Clone()
			Clone.Parent = NewLighting:IsA("Clouds") and workspace.Terrain or Lighting
		end

		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

local function importLighting()
	local recording = ChangeHistoryService:TryBeginRecording("ImportLighting", "Import lighting from game.Lighting to map")
	if recording then

		for _, item in ipairs(directories.Lighting.Items:get(false)) do
			local settingToRetrieve = if item.ExportAttribute then item.ExportAttribute else item.Attribute
	
			local fired, settingValue = pcall(function()
				return Lighting[settingToRetrieve]
			end)
	
			if not fired then
				Util.debugWarn(("Failed to get lighting setting '%s'"):format(tostring(settingToRetrieve)))
			else
				item.Value:set(settingValue)
				Util.updateMapSetting(item.Directory, item.Attribute, item.Value:get(false), true)
			end
		end
		
		for _, LightObject in pairs(Util.mapModel:get().Settings.Lighting:GetChildren()) do
			if LightObject:IsA("PostEffect") or LightObject:IsA("Atmosphere") or LightObject:IsA("Sky") or LightObject:IsA("Clouds") then
				LightObject.Parent = nil
			end
		end
	
		for _, NewLighting in pairs(Lighting:GetChildren()) do
			local Clone = NewLighting:Clone()
			Clone.Parent = Util.mapModel:get().Settings.Lighting
		end
	
		for _, NewLighting in pairs(workspace.Terrain:GetChildren()) do
			if NewLighting:IsA("Clouds") then
				local Clone = NewLighting:Clone()
				Clone.Parent = Util.mapModel:get().Settings.Lighting
			end
		end

		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

local function importMaterials()
	local recording = ChangeHistoryService:TryBeginRecording("ImportMaterials", "Import materials from game.MaterialService to map")
	if recording then

		for _, MaterialObject in pairs(Util.mapModel:get().Settings.Lighting:GetChildren()) do
			if MaterialObject:IsA("MaterialVariant") then
				MaterialObject.Parent = nil
			end
		end
	
		for _, NewMaterial in pairs(MaterialService:GetChildren()) do
			local Clone = NewMaterial:Clone()
			Clone.Parent = Util.mapModel:get().Settings.Materials
		end

		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

local function exportMaterials()
	local recording = ChangeHistoryService:TryBeginRecording("ExportMaterials", "Export materials from map to game.MaterialService")
	if recording then

		for _, MaterialObject in pairs(MaterialService:GetChildren()) do
			if MaterialObject:IsA("MaterialVariant") then
				MaterialObject.Parent = nil
			end
		end
	
		for _, NewMaterial in pairs(Util.mapModel:get().Settings.Materials:GetChildren()) do
			local Clone = NewMaterial:Clone()
			Clone.Parent = MaterialService
		end

		ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
	end
end

local frame = {}

function frame:GetUI(type): Instance
	return New "Frame" {
		BackgroundTransparency = 1,
		BorderSizePixel = 1,
		LayoutOrder = type == "Lighting" and 4 or 8,
		Size = UDim2.new(1, 0, 0, 50),
		Visible = type == "Lighting" and directories.Lighting.Visible or directories.Materials.Visible,
	
		[Children] = {
			Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, UDim.new(0, 2), Enum.VerticalAlignment.Center),
			ExportButton {
				LayoutOrder = 1,
				Text = `Export to {type}`,
	
				[OnEvent "Activated"] = function()
					local option1 = {
						Text = "Export",
						Callback = type == "Lighting" and exportLighting or exportMaterials,
						BackgroundColor3 = Theme.Button.Selected
					}
			
					local option2 = {
						Text = "Cancel",
						BackgroundColor3 = Theme.Button.Default
					}
	
					Util:ShowMessage(
						`Export to {type:lower()}?`, 
						`This will export the current {type} settings into your game's {type} service, and override all {type} instances.`, 
						option1, 
						option2
					)
				end
			},
			ExportButton {
				LayoutOrder = 2,
				Text = `Import from {type}`,
				[OnEvent "Activated"] = function()
					local option1 = {
						Text = "Import",
						Callback = type == "Lighting" and importLighting or importMaterials,
						BackgroundColor3 = Theme.Button.Selected
					}
			
					local option2 = {
						Text = "Cancel",
						BackgroundColor3 = Theme.Button.Default
					}
	
					Util:ShowMessage(
						`Import from {type}?`, 
						`This will import the current {type} settings from your game into the map's settings and override all {type} instances.`, 
						option1, 
						option2
					)
				end
			}
		}
	}
end

return frame
