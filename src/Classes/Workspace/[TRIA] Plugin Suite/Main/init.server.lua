--!nocheck
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
	return
end

local toolbar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local openButton = toolbar:CreateButton(
	"TRIA.os Companion Plugin", 
	"Make mapmaking easy!", 
	"rbxassetid://12032105372", 
	"TRIA.os Mapmaker"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 300, 400)
local widget = plugin:CreateDockWidgetPluginGui("TRIA.os Tools", widgetInfo)

local Resources = script.Resources
local Pages = script.Pages

local Fusion = require(Resources.Fusion)
local Components = require(Resources.Components)
local Theme = require(Resources.Themes)
local PageHandler = require(Resources.Components.Pages)

local SettingsUtil = require(Pages.Settings.SettingsUtil)

local MapSelect = require(script.MapSelect)
local Util = require(script.Util)
local ColorWheel = require(script.ColorWheel)
local Message = require(script.Message)
local MenuData = require(script.MenuData)
local PublicTypes = require(script.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local ForValues = Fusion.ForValues
local ForPairs = Fusion.ForPairs
local Value = Fusion.Value
local Out = Fusion.Out

widget.Name = "TRIA_PluginSuite"
widget.Title = "[TRIA] Plugin Suite"
Util.Widget = widget
Util.attemptScriptInjection()

local debugMenu = plugin:CreatePluginMenu(math.random(), "Debug Menu")
debugMenu.Name = "Debug Menu"
debugMenu:AddNewAction("ShowDebug", "Show Debug Menu", "rbxassetid://6022668961")

local function showDebug(bypass)
	local selectedAction
	if bypass ~= true then
		selectedAction = debugMenu:ShowAsync()
	end
	if selectedAction or bypass == true then
		if bypass == true or selectedAction.ActionId:find("ShowDebug") then
			Util:ShowMessage(Util._Headers.DEBUG_HEADER, Computed(function(): string
				return ([[<font color='rgb(120, 120, 120)'><b>Debug Information</b></font>
<b>Version</b>: %s
<b>Release</b>: %s
<b>Plugin Uptime</b>: %s
<b>Average FPS</b>: %dfps
<b>Average HTTP Response Time</b>: %s,
<b>Average Autocomplete Response Time</b>: %s
<b>Github Status</b>: %s
<b>Output Messages</b>: %s
				]]):format(
					Util._DEBUG.PLUGIN_VERSION,
					tostring(Util._DEBUG.IS_RELEASE),
					Util.secondsToTime(Util._DEBUG._Uptime:get()),
					Util._DEBUG._Fps:get(), 
					Util._DEBUG._HttpPing:get(),
					Util._DEBUG._SuggesterResponse:get(), 
					Util._DEBUG._GitStatus:get(),
					tostring(Util.doDebugPrints)
				)
			end), {Text = Util.doDebugPrints and "Disable output prints" or "Enable output prints", Callback = function() 
				Util.doDebugPrints = not Util.doDebugPrints 
				task.delay(0, function() 
					showDebug(true)
				end)
			end}, {Text = "Close", Callback = function() end})
		end
	else
		return;
	end
end


local topbarData = {
	absolutePosition = Value(Vector2.new()),
	absoluteSize = Value(Vector2.new(250, 0)),
	mousePos = Value(Vector2.new()),
	hoverVisible = Value(false),
	hoverSize = Value(Vector2.new(40, 0)),
	hoveredButton = Value(""),
	hoverIcon = Value("")
}

local mainFrame = New "Frame" {
	Name = "TRIA.os Plugin",
	Parent = widget,
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.MainBackground.Default,

	[Children] = {
		New "Frame" { -- Pages
			Name = "Pages",
			Size = UDim2.new(1, 0, 1, -76),
			Position = UDim2.fromOffset(0, 52),
			BackgroundTransparency = 1,

			[Children] = {
				ForValues(MenuData.Pages, function(data: PublicTypes.Dictionary): Instance
					return PageHandler:NewPage(data)
				end, Fusion.cleanup),

				Components.GradientTextLabel(Computed(Util.isPluginFrozen), {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Text = "Select a map to continue.",
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = 5
				})
			}
		},
		New "Frame" { -- Topbar hover
			[Out "AbsoluteSize"] = topbarData.hoverSize,

			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(40, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.Tooltip.Default,
			BackgroundTransparency = 0,
			BorderSizePixel = 1,
			BorderColor3 = Theme.DimmedText.Default,
			Visible = topbarData.hoverVisible,
			ZIndex = 12,

			Position = Computed(function(): UDim2
				local hoverSize = topbarData.hoverSize:get() or Vector2.new(40, 0)
				local absoluteSize = topbarData.absoluteSize:get() or Vector2.new(250, 0)
				local totalPages = #PageHandler._PageOrder
				
				local min = hoverSize.X / 2
				local pos = (topbarData.mousePos:get() or Vector2.new()).X
				
				return UDim2.fromOffset(
					math.clamp(
						(math.floor((pos + absoluteSize.X / (totalPages * 2)) / absoluteSize.X * totalPages + 0.5) - 0.5) * absoluteSize.X / totalPages, 
						min + 1, 
						math.max(min + 3, (absoluteSize.X - min)) - 2
					), 
					46
				) 
			end),

			[Children] = {
				Components.Constraints.UIPadding(nil, nil, UDim.new(0, 1), UDim.new(0, 2)),
				New "ImageLabel" {
					Size = UDim2.fromOffset(20, 20),
					BackgroundTransparency = 1,
					ImageColor3 = Theme.MainText.Default,
					Image = Computed(function(): string
						return topbarData.hoverIcon:get()
					end),
					ZIndex = 12,
				},
				New "TextLabel" {
					BackgroundTransparency = 1,
					TextColor3 = Theme.MainText.Default,
					AutomaticSize = Enum.AutomaticSize.X,
					Text = Computed(function(): string
						return topbarData.hoveredButton:get() or ""
					end),
					Position = UDim2.fromOffset(20, 0),
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.fromScale(0, 1),
					ZIndex = 12,

					[Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 4), nil)
 				}
			}
		},
		New "Frame" { -- Topbar
			Name = "Topbar",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Titlebar.Default,

			[Out "AbsolutePosition"] = topbarData.absolutePosition,
			[Out "AbsoluteSize"] = topbarData.absoluteSize,

			[OnEvent "InputChanged"] = function(inputObject: InputObject)
				if inputObject.UserInputType == Enum.UserInputType.MouseWheel and not Util._Topbar.FreezeFrame:get(false) then
					local newPage = PageHandler._currentPageNum:get(false) - inputObject.Position.Z
					newPage = if newPage < 1 then #PageHandler._PageOrder elseif newPage > #PageHandler._PageOrder then 1 else newPage

					PageHandler._currentPageNum:set(newPage)
					PageHandler:ChangePage(PageHandler._PageOrder[PageHandler._currentPageNum:get(false)])
				end
			end,

			[OnEvent "MouseEnter"] = function()
				topbarData.hoverVisible:set(true)
			end,

			[OnEvent "MouseLeave"] = function()
				topbarData.hoverVisible:set(false)
			end,

			[OnEvent "MouseMoved"] = function()
				local relativePos = widget:GetRelativeMousePosition()
				local mousePos = -(topbarData.absolutePosition:get(false) - relativePos)

				local pages = PageHandler._PageOrder

				local absoluteSize = topbarData.absoluteSize:get(false) or Vector2.new(1, 1)

				local percent = mousePos.X / absoluteSize.X
				local increment = 1 / #pages

				local index = math.ceil((math.ceil(percent / increment) * increment) * #pages)

				local pageNameToDisplay = {
					ObjectTags = "Event & Item Tags",
					DataVisualizer = "Debug View",
					Settings = "Map Settings",
					Scripting = "Scripting",
					Insert = "Resources",
					AudioLibrary = "Audio Library"
				}
				topbarData.hoverIcon:set(MenuData.Buttons[index] and MenuData.Buttons[index].Icon or "")
				topbarData.mousePos:set(Vector2.new(relativePos.X, relativePos.Y))
				topbarData.hoveredButton:set(pageNameToDisplay[pages[index]])
			end,

			[Children] = {
				Components.Constraints.UIGridLayout(UDim2.fromScale(1 / #MenuData.Buttons, 1), UDim2.new(), Enum.FillDirection.Horizontal),
				ForPairs(MenuData.Buttons, function(index: number, data: PublicTypes.Dictionary): (number, Instance)
					return index, Components.TopbarButton(index, data)
				end, Fusion.cleanup)
			},
		},
		New "Frame" { -- Bottom bar
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 24),
			Name = "Bottom",
			BackgroundColor3 = Theme.Titlebar.Default,
			BorderColor3 = Theme.Border.Default,
			BorderSizePixel = 1,
			ZIndex = 2,

			[Children] = {
				New "TextLabel" {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 70, 1, -4),
					Position = UDim2.new(0, 4, 0.5, 0),
					Text = "Selected Map:",
					TextColor3 = Theme.TitlebarText.Default,
					ZIndex = 2,
				},
				Components.TextButton {
					Size = UDim2.new(1, -100, 1, -6),
					Position = UDim2.fromOffset(76, 3),
					Text = MapSelect.selectTextState,
					TextColor3 = MapSelect.selectTextColor,
					BackgroundColor3 = Theme.InputFieldBackground.Default,
					ZIndex = 2,

					[OnEvent "Activated"] = function()
						MapSelect:StartMapSelection()
					end
				},
				Components.ImageButton {
					AnchorPoint = Vector2.new(1, 0.5),
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.new(1, -2, 0.5, 0),
					Image = MapSelect.selectCancelImage,
					ImageColor3 = MapSelect.selectCancelColor,
					BorderSizePixel = 1,
					BorderColor3 = Theme.Border.Default,
					ZIndex = 2,

					[OnEvent "Activated"] = function()
						if MapSelect.selectingMap:get(false) then
							MapSelect:StopManualSelection()
						else
							MapSelect:SetMap(nil)
						end
					end,

					[OnEvent "MouseButton2Down"] = showDebug
				}
			}
		},
		
		Message,
		ColorWheel:GetUI(),

		New "Frame" {
			ZIndex = 4,
			BackgroundTransparency = 0.75,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 0, 1, -76),
			Position = UDim2.fromOffset(0, 52),
			Visible = Computed(Util.isPluginFrozen),
			Name = "Freezer"
		}
	}
}

task.spawn(function()
	local images = {}
	for _, obj in ipairs(mainFrame:GetDescendants()) do
		if not obj:IsA("ImageLabel") then
			continue
		end
		table.insert(images, obj)
	end
	ContentProvider:PreloadAsync(images)
end)

local function createDebugViewFolder()
	local folder = Instance.new("Folder")
	folder.Name = "__debugview_tria_donttouch"
	folder.Archivable = false
	folder.Parent = Util.Widget

	Util._DebugView.debugObjectsFolder = folder
	Util.MainMaid:GiveTask(folder)
end

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	Util.PluginActive:set(widget.Enabled)

	if widget.Enabled then
		MapSelect:AutoSelect()
		createDebugViewFolder()
	end
end)
Util.PluginActive:set(widget.Enabled)

task.wait()
if not MapSelect:AutoSelect() then
	PageHandler:ChangePage("Insert")
end
createDebugViewFolder()

function unloadPlugin()
	widget.Enabled = false
	Util.toggleAudioPerms(nil)
	Util.PluginActive:set(false)
    MapSelect._Maid:DoCleaning()
    Util.MainMaid:DoCleaning()
    SettingsUtil.SettingMaid:DoCleaning()
end

widget:BindToClose(unloadPlugin)
plugin.Unloading:Connect(unloadPlugin)
