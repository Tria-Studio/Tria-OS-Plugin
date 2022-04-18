local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")
local StudioService = game:GetService("StudioService")

local Maid = require(script.Parent.Other.Maid)
local Signal = require(script.Parent.Other.Signal)

local UtilModule = require(script.Parent.UtilFuncs)

local UI = UtilModule.UI
local StudioTheme = settings().Studio.Theme

local module = {}

module.Maid = Maid.new()
module.MapChanged = Signal.new()

function module.SelectMap(Map)
	local Selected = Selection:Get()

	local function Reset()
		if UtilModule.Map then 
			UI.ChosenMap.SelectMap.Text = UtilModule.Map.Settings.Main:GetAttribute("Name")
			UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
			UI.NoMapSelected.Visible = false
			ServerStorage.TRIAosTools_Plugin[StudioService:GetUserId()].Map.Value = UtilModule.Map

			module.MapChanged:Fire(UtilModule.Map)
		else
			UI.ChosenMap.SelectMap.Text = "No map selected"
			UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ErrorText)
			UI.NoMapSelected.Visible = true
			ServerStorage.TRIAosTools_Plugin[StudioService:GetUserId()].Map.Value = nil
			module.Maid:DoCleaning()
			module.MapChanged:Fire(nil)
		end
		Selection:Set(Selected)
	end

	if not Map then
		UI.ChosenMap.SelectMap.Text = "Click model to select"
		UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DimmedText)

		Selection:Remove(Selection:Get())
		Selection.SelectionChanged:Wait()
	end
	local Model = Map and {Map} or Selection:Get()

	if #Model == 1 then
		Model = Model[1]

		-- Check if its a FE2 map / FP275 (they use the same map kit?)

		local IsFE2 = false
		local IsD2 = false

		local EventScript = Model:FindFirstChild("EventScript")

		if EventScript and string.find(EventScript.Source, "workspace.Multiplayer.GetMapVals:Invoke()", 1, true) then
			IsFE2 = true
		end

		local Variants = Model:FindFirstChild("_Variants")
		local Variant = Variants and Variants:FindFirstChild("Variant")
		if Variants and Variant and Variant:IsA("Model") then
			IsFE2 = true
		end

		local Rope = Model:FindFirstChild("_Rope", true)
		if Rope and Rope:FindFirstChild("Point1") then
			IsFE2 = true
		end

		local Settings = Model:FindFirstChild("Settings")
		local Setting = Settings and (Settings:FindFirstChild("BGM") or Settings:FindFirstChild("Creator") or Settings:FindFirstChild("Difficulty") or Settings:FindFirstChild("MapImage") or Settings:FindFirstChild("MapName") or Settings:FindFirstChild("MaxTime"))

		if Model:FindFirstChild("_Rescue") and Setting and Settings:FindFirstChild("Rescue") then
			IsFE2 = true
		end

		if Setting and Setting:IsA("ValueBase") then
			IsFE2 = true
		end

		-- Check if its a D2 map

		local Wall = Model:FindFirstChild("ExitWall")
		if Wall and not Wall.CanCollide then
			IsD2 = true
		end

		local EventScript = Model:FindFirstChild("EventScript")

		if EventScript and string.find(EventScript.Source, "local D2, Map = workspace.MapTest.GetMapFunctions:Invoke(), script.Parent", 1, true) then
			IsD2 = true
		end




		if IsFE2 then
			UtilModule.Warn("FE2 map detected. This plugin only supports TRIA.os maps. Use the TRIA.os converter plugin by TRIA to convert this to a TRIA.os map.", nil, nil, true)
			warn("FE2 map detected. This plugin only supports TRIA.os maps. Use the TRIA.os converter plugin by TRIA to convert this to a TRIA.os map.")
			Reset()
			return
		end
		if IsD2 then
			UtilModule.Warn("D2 map detected. This plugin only supports TRIA.os maps. Use the TRIA.os converter plugin by TRIA to convert this to a TRIA.os map.", nil, nil, true)
			warn("D2 map detected. This plugin only supports TRIA.os maps. Use the TRIA.os converter plugin by TRIA to convert this to a TRIA.os map.")
			Reset()
			return
		end

		if not Model:IsA("Model") then
			UtilModule.Warn("Map must be a model.")
			warn("Map must be a model.")
			Reset()
			return
		end
		if not Model:FindFirstChild("Spawn") then
			UtilModule.Warn("Cannot select map: Map is missing a Spawn.")
			warn("Cannot select map: Map is missing a Spawn.")
			Reset()
			return
		end
		if not Model:FindFirstChild("ExitRegion") then
			UtilModule.Warn("Cannot select map: Map is missing an ExitRegion.")
			warn("Cannot select map: Map is missing an ExitRegion.")
			Reset()
			return
		end
		if not Model:FindFirstChild("MapScript") then
			UtilModule.Warn("Cannot select map: Map is missing a MapScript.")
			warn("Cannot select map: Map is missing a MapScript.")
			Reset()
			return
		end
		local Settings = Model:FindFirstChild("Settings")

		local LiquidSetting = Settings:FindFirstChild("Liquids")
		local LightingSetting = Settings:FindFirstChild("Lighting")
		local MainSetting = Settings:FindFirstChild("Main")
		local ButtonsSetting = Settings:FindFirstChild("Buttons")

		local CustomLiquidSetting = LiquidSetting and LiquidSetting:FindFirstChild("custom") or true

		--local DefaultButtonSetting = ButtonsSetting and ButtonsSetting:FindFirstChild("Default")
		--local GroupButtonSetting = ButtonsSetting and ButtonsSetting:FindFirstChild("Group")
		if not Settings or not LiquidSetting or not LightingSetting or not MainSetting or not (ButtonsSetting or Settings:FindFirstChild("Button")) or not CustomLiquidSetting then
			UtilModule.Warn("Cannot select map: Map is missing its Settings. Possibly missing the Settings folder, Liquids, Button, Lighting, Main.")
			warn("Cannot select map: Map is missing its Settings. Possibly missing the Settings folder, Liquids, Button, Lighting, Main.")
			Reset()
			return
		end

		Selection:Set(Selected)
		module.MapChanged:Fire(Model)
		module.Maid:DoCleaning()
		UtilModule:Cleanup()
		UtilModule.Map = Model
		ServerStorage.TRIAosTools_Plugin[StudioService:GetUserId()].Map.Value = Model
		UI.ChosenMap.SelectMap.Text = Model.Settings.Main:GetAttribute("Name")
		UI.NoMapSelected.Visible = false
		UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)

		local function NameChanged()
			UI.ChosenMap.SelectMap.Text = Model.Settings.Main:GetAttribute("Name")
		end
		module.Maid:GiveTask(Model.Settings.Main:GetAttributeChangedSignal("Name"):Connect(NameChanged))

		local function MapRemoved()
			if not UtilModule.Map or not UtilModule.Map.Parent then
				module.ClearMap()
			end 
		end

		if not Model.Settings.Main:GetAttribute("_KitVersion") then
			UtilModule.Warn("[NOTICE] This map is using a pre V0.6 MapKit version.\n\n Some features may not work or be supported because this plugin only supports the most recent version of the MapKit.\n\n It is reccomended that you convert your map over to the newest MapKit version.\n", true, "I understand", true)
		end
		module.Maid:GiveTask(Model.AncestryChanged:Connect(MapRemoved))
	end
end

function module.ClearMap(store)
	UtilModule.Map = nil
	UI.NoMapSelected.Visible = true
	UI.ChosenMap.SelectMap.Text = "No map selected"
	UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ErrorText)

	module.Maid:DoCleaning()
	module.MapChanged:Fire(nil)
	if not store then
		ServerStorage.TRIAosTools_Plugin[StudioService:GetUserId()].Map.Value = nil
	end
end

settings().Studio.ThemeChanged:Connect(function()
	StudioTheme = settings().Studio.Theme
end)



return module
