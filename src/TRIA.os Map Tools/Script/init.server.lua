--[[

	TRIA.os Map Making Companion Plugin by grif_0.
	
	Enables a quick + efficient workflow when creating maps. Allows you to add BtnFuncs onto parts + groups of parts effortlessly, and change stuff 
	like its Button # and delay time, or other tag-specific data.
	
	This plugin inclued two bonus features: View Modes + Settings Editor.
	
	Settings Editor allows you to easily edit the settings of your map, without needing to scroll through the explorer looking for the right properties.
	
	View Modes gives you ways to visualise your maps objects, allowing you to see yout BtnFunc tagged parts, Objects like wallruns, start, end, and 
	buttons, and eventually _Detail parts.
	
	
	Please do not resell or reupload or claim you created this. Feel free to use this, no need to give me credit for using this.
	Please report any bugs + suggestions to me! 
	
	Thanks!
	 - grif_0


		Changelog
	
	 V 2.2
		
		BUGS
		- fixed 0.6 mapkits not working
		- other bug fixes i forgot
		- Tag can be clicked when no parts are visible
		- Tag menu wouldnt show if a part was a kill part
		
		CHANGES
		- Plugin now supports TRIA.os v0.6
		- Added notices for users using old mapkit versions encouraging them to update their map
		- Settings page will now tell you if a setting cannot be found
		- Adjusted the insert page to be more helpful
		- Added notices to the insert page
		- Added 'Texture Kit' by Phexonia to the insert page
		- Added the new 0.6 map settings to the Settings page
		- Added the abillity to edit the oxygen inside of an air tank
		- Buttons are new easier to select
		- Insert page will now use the latest versions of the mapkits automatically
		- Added dropdown menus to some setting objects
		- Added low detail mode tag
		- Added Speed + Jump booster tags
		- Improved security for non TRIA.os maps (FE2, FP275, D2)
		
	V 2.1
		- Bug: Colorwheel not working
		- Bug: Colorwheel not respecting undo/redo
		- Bug: Last selected map not loading at the start of a new session
		- Bug: notification screen was huge sometimes
		- _Kill tag support
		- Added a new Insert tab to insert the map kits, map addons, and map components to your map
	
	V 2.0.1
	  - Updated difficulty tooltip
	  - New 'Export to Lighting' option

	V 2.0
		 - Changed from a FE2 Map Making Companion to a TRIA.os Map Making Companion.
		 - Removed all FE2 references and FE2 specific items.
		 - UI overhaul
		 - Rewritten to be modular, organized, efficient
		 - Selected map saves between sessions
		 - Many map selecting improvements
		 - Fixed Undo/Redo
		 - Important feedback will now appear in the widget along with the output
		 - You can now alter the Button# and delay, ot other data per indivijual tag
		 - New map settings editor

	V 1.2
	 - Add Ziplines to Object View
	 - Add Rescue point to Object View [DONE]
	 - Maybe add some sorta Variation View
	 - Model inserter tab: Insert Slide wall, walljump, air tank, zipline, etc.

	V 1.1
	 - Proper light/dark theme support [DONE]
	 - Fix bugs [DONE]
	 - Intro view mode [DONE]
	 
	V 1.0
	 - Edit _Delay [DONE]
	 - Edit _Sound SoundId [DONE]
	 - Detail mode [DONE]
	 - _Detail + _Wall selector [DONE]
	 - Bugtest [DONE]
	 - Release [DONE]
]]

local ServerStorage = game:GetService("ServerStorage")
local StudioService = game:GetService("StudioService")

local VERSION = 2.2

local PluginBar = plugin:CreateToolbar("TRIA.os Map tools")
local OpenButton = PluginBar:CreateButton("TRIA.os Tools", "Tools to help map making!", "rbxassetid://6924807717", "Map Creation Tools")
local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 200, 250)
local Widget = plugin:CreateDockWidgetPluginGui("TRIA.osTools", WidgetInfo)

local Util = require(script.Modules.UtilFuncs)
local SelectMap = require(script.Modules.SelectMap)
local SettingsMod = require(script.Modules.Settings)
local BtnController = require(script.Modules.Button)
local MaidMod = require(script.Modules.Other.Maid)

local StudioTheme = settings().Studio.Theme
local ChosenFrame = Util.UI.Frames.Tags
local UI = Util.UI
local Maid = MaidMod.new()



-- ======== WIDGET HANDLER ======== --





Widget.Title = "TRIA.os Map Maker Companion"
Util.Widget = Widget
UI.Parent = Widget
UI.Size = UDim2.new(1, 0, 1, 0)


local function Startup()
	for _, Button in pairs(UI.Frames.Tags.ButtonTags:GetChildren()) do
		if Button:IsA("TextButton") then
			local Type = Util.GetTagType(Button.Name)

			local Controller = BtnController.new(Button.Name, Type)
			Maid:GiveTask(Controller)
		end
	end

	for _, Button in pairs(UI.Frames.Tags.ObjectTags:GetChildren()) do
		if Button:IsA("TextButton") then
			if Button:IsA("TextButton") then
				local Type = Util.GetTagType(Button.Name)

				local Controller = BtnController.new(Button.Name, Type)
				Maid:GiveTask(Controller)
			end
		end
	end

	--for _, Button in pairs(UI.Frames.View.ButtonTags:GetChildren()) do
	--	if Button:IsA("TextButton") then
	--		if Button:IsA("TextButton") then
	--			local Controller = BtnController.new(Button.Name)
	--			Maid:GiveTask(Controller)
	--		end
	--	end
	--end
end

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled

	if not ServerStorage:FindFirstChild("TRIAosTools_Plugin") then
		local Folder = Instance.new("Folder")
		Folder.Name = "TRIAosTools_Plugin"
		Folder.Parent = ServerStorage
	end
	local UserId = StudioService:GetUserId()
	if not ServerStorage.TRIAosTools_Plugin:FindFirstChild(UserId) then
		local Folder = script.TRIAosTools_Plugin:Clone()
		Folder.Name = UserId
		Folder.Parent = ServerStorage.TRIAosTools_Plugin
		Util.PluginSettings = Folder
	end

	local Map = ServerStorage.TRIAosTools_Plugin:FindFirstChild(StudioService:GetUserId()).Map.Value

	if Map and Map.Parent and not Util.Map then
		SelectMap.SelectMap(Map)
	end
end)

if Widget.Enabled then

	if not ServerStorage:FindFirstChild("TRIAosTools_Plugin") then
		local Folder = Instance.new("Folder")
		Folder.Name = "TRIAosTools_Plugin"
		Folder.Parent = ServerStorage
	end

	local UserId = tostring(StudioService:GetUserId())
	if not ServerStorage.TRIAosTools_Plugin:FindFirstChild(UserId) then
		local Folder = script.TRIAosTools_Plugin:Clone()
		Folder.Name = UserId
		Folder.Parent = ServerStorage.TRIAosTools_Plugin
		Util.PluginSettings = Folder
	end

	local Map = ServerStorage.TRIAosTools_Plugin:FindFirstChild(StudioService:GetUserId()).Map.Value

	if Map and Map.Parent and not Util.Map then
		SelectMap.SelectMap(Map)
	end

	Startup()
end

Util.PluginSettings = ServerStorage:FindFirstChild("TRIAosTools_Plugin"):FindFirstChild(tostring(StudioService:GetUserId()))

if not Util.PluginSettings then
	if not ServerStorage:FindFirstChild("TRIAosTools_Plugin") then
		local Folder = Instance.new("Folder")
		Folder.Name = "TRIAosTools_Plugin"
		Folder.Parent = ServerStorage
	end

	local UserId = tostring(StudioService:GetUserId())
	if not ServerStorage.TRIAosTools_Plugin:FindFirstChild(UserId) then
		local Folder = script.TRIAosTools_Plugin:Clone()
		Folder.Name = UserId
		Folder.Parent = ServerStorage.TRIAosTools_Plugin
		Util.PluginSettings = Folder
	end
end

Widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not Widget.Enabled then
		SelectMap.ClearMap(true)
		Maid:DoCleaning()
	else
		Startup()
	end
end)

local InserterCont = require(script.Modules.ObjectInsert)

-- ======== UI HANDLER ======== --





UI.ChosenMap.Clear.MouseButton1Click:Connect(function()
	SelectMap.ClearMap()
	Util:Cleanup()
end)

UI.ChosenMap.SelectMap.MouseButton1Click:Connect(SelectMap.SelectMap)

for _, Button in pairs(UI.CurrentMode:GetChildren()) do
	if Button:IsA("GuiButton") then
		Button.MouseButton1Click:Connect(function()
			ChosenFrame.Visible = false
			UI.CurrentMode[ChosenFrame.Name].BackgroundColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Titlebar)
			UI.CurrentMode[ChosenFrame.Name].Bars.Visible = false
			UI.CurrentMode[ChosenFrame.Name].ZIndex = 1
			ChosenFrame = UI.Frames[Button.Name]
			ChosenFrame.Visible = true
			UI.CurrentMode[ChosenFrame.Name].BackgroundColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
			UI.CurrentMode[ChosenFrame.Name].Bars.Visible = true
			UI.CurrentMode[ChosenFrame.Name].ZIndex = 2

			if ChosenFrame.Name == "Insert" and not Util.PluginSettings:GetAttribute("UserAgreedToInsertInjection") then
				Util.Warn("[NOTICE] You need to give this plugin script injection permissions otherwise some features on this page may not work.", true, "I understand", true)
				Util.PluginSettings:SetAttribute("UserAgreedToInsertInjection", true)
			end
		end)
	end
end

for _, Button in pairs(UI:GetDescendants()) do
	if Button:IsA("GuiButton") and Button.Name == "Tip" then
		Button.MouseButton1Click:Connect(function()
			Button.Tooltip.Visible = not Button.Tooltip.Visible
		end)
	end
end

local function Draw()
	StudioTheme = settings().Studio.Theme

	for _, Button in pairs(UI.CurrentMode:GetChildren()) do
		if Button:IsA("TextButton") then
			local Color = ChosenFrame.Name == Button.Name and StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground) or StudioTheme:GetColor(Enum.StudioStyleGuideColor.Titlebar)
			Button.BackgroundColor3 = Color
		end
	end

	if Util.Map then
		UI.ChosenMap.SelectMap.TextColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
	end

	for _, Frame in pairs(UI:GetDescendants()) do
		if Frame:GetAttribute("Theme") or Frame:GetAttribute("TextTheme") or Frame:GetAttribute("BorderTheme") then
			local Color = Frame:GetAttribute("Theme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("Theme")])
			local TextColor  = Frame:GetAttribute("TextTheme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("TextTheme")])
			local TextStrokeColor  = Frame:GetAttribute("TextStrokeTheme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("TextStrokeTheme")])

			if Frame:IsA("TextBox") then
				if TextColor and not Frame:GetAttribute("BlockTextColor") then
					Frame.TextColor3 = TextColor
				end
				if Color then
					Frame.BackgroundColor3 = Color
				end
				if TextStrokeColor and not Frame:GetAttribute("BlockTextColor") then
					Frame.TextStrokeColor3 = TextStrokeColor
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("TextLabel") then
				if TextColor then
					Frame.TextColor3 = TextColor
				end
				if Color then
					Frame.BackgroundColor3 = Color
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("ImageLabel") then
				if Color then
					if Frame:GetAttribute("ThemeMode") == "BackgroundColor3" then
						Frame.BackgroundColor3 = Color
					else
						Frame.ImageColor3 = TextColor
					end
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("ViewportFrame") then
				if Color then
					Frame.BackgroundColor3 = Color
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("ImageButton") then
				if TextColor then
					Frame.ImageColor3 = TextColor
				end
				if Color then
					Frame.BackgroundColor3 = Color
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("Frame") then
				if Color then
					Frame.BackgroundColor3 = Color
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("ScrollingFrame") then
				if Color then
					Frame.BackgroundColor3 = Color
				end
				Frame.ScrollBarImageColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar)
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			elseif Frame:IsA("TextButton") then
				if Color then
					Frame.BackgroundColor3 = Color
				end
				if TextColor then
					Frame.TextColor3 = TextColor
				end
				Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
			end
		end
	end
end

Draw()
settings().Studio.ThemeChanged:Connect(Draw)

Util.Warn("[NOTICE]: THIS PLUGIN IS IN BETA!\n\nPlease report all bugs and any feature suggestions. Thanks!\n")

if Util.PluginSettings:GetAttribute("VersionWhenLastOpened") ~= VERSION then
	local ChangelogText = [[
		This plugin has been updated since you last used it!
		
		[CHANGELOG] V 2.2
		
		BUGS
		- fixed 0.6 mapkits not working
		- other bug fixes i forgot
		- Tag can be clicked when no parts are visible
		- Tag menu wouldnt show if a part was a kill part
		
		CHANGES
		- Plugin now supports TRIA.os v0.6
		- Added notices for users using old mapkit versions encouraging them to update their map
		- Settings page will now tell you if a setting cannot be found
		- Adjusted the insert page to be more helpful
		- Added notices to the insert page
		- Added 'Texture Kit' by Phexonia to the insert page
		- Added the new 0.6 map settings to the Settings page
		- Added the abillity to edit the oxygen inside of an air tank
		- Buttons are new easier to select
		- Insert page will now use the latest versions of the mapkits automatically
		- Added dropdown menus to some setting objects
		- Added low detail mode tag
		- Added Speed + Jump booster tags
		- Improved security for non TRIA.os maps (FE2, FP275, D2)
	]]
	Util.Warn(ChangelogText, true, "Awesome!", true)
	Util.PluginSettings:SetAttribute("VersionWhenLastOpened", VERSION)
end