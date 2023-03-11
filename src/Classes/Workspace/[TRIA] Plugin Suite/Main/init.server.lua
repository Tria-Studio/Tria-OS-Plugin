local ContentProvider = game:GetService("ContentProvider")
local PathfindingService = game:GetService("PathfindingService")
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

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 300, 300)
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
local Spring = Fusion.Spring
local OnEvent = Fusion.OnEvent
local ForValues = Fusion.ForValues
local ForPairs = Fusion.ForPairs
local Value = Fusion.Value

widget.Title = "TRIA.os Mapmaker"
Util.Widget = widget
Util.attemptScriptInjection()

local debugMenu = plugin:CreatePluginMenu(math.random(), "Debug Menu")
debugMenu.Name = "Debug Menu"
debugMenu:AddNewAction("ShowDebug", "Show Debug Menu", "rbxassetid://6022668961")

local function showDebug()
	local selectedAction = debugMenu:ShowAsync()
	if selectedAction then
		if selectedAction.ActionId:find("ShowDebug") then
			Util:ShowMessage(Util._Headers.DEBUG_HEADER, Computed(function(): string
				return ([[<font color='rgb(120, 120, 120)'><b>Debug Information</b></font>
<b>Version</b>: 0.5-dev
<b>Release</b>: false
<b>Plugin Uptime</b>: %s
<b>Average FPS</b>: %dfps
<b>Average HTTP Response Time</b>: %s,
<b>Average Autocomplete Response Time</b>: %s
<b>Github Status</b>: %s
				]]):format(
					Util.secondsToTime(Util._DEBUG._Uptime:get()),
					Util._DEBUG._Fps:get(), 
					Util._DEBUG._HttpPing:get(),
					Util._DEBUG._SuggesterResponse:get(), 
					Util._DEBUG._GitStatus:get()
				)
			end))
		end
	else
		return;
	end
end

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
		New "Frame" { -- Topbar
			Name = "Topbar",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Titlebar.Default,

			[OnEvent "InputChanged"] = function(InputObject: InputObject)
				if InputObject.UserInputType == Enum.UserInputType.MouseWheel and not Util._Topbar.FreezeFrame:get(false) then
					local newPage = PageHandler._currentPageNum:get(false) - InputObject.Position.Z
					newPage = if newPage < 1 then #PageHandler._PageOrder elseif newPage > #PageHandler._PageOrder then 1 else newPage

					PageHandler._currentPageNum:set(newPage)
					PageHandler:ChangePage(PageHandler._PageOrder[PageHandler._currentPageNum:get(false)])
				end
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

			[Children] = {
				New "TextLabel" {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 70, 1, -4),
					Position = UDim2.new(0, 4, 0.5, 0),
					Text = "Selected Map:",
					TextColor3 = Theme.TitlebarText.Default,
				},
				Components.TextButton {
					Size = UDim2.new(1, -100, 1, -6),
					Position = UDim2.fromOffset(76, 3),
					Text = MapSelect.selectTextState,
					TextColor3 = MapSelect.selectTextColor,
					BackgroundColor3 = Theme.InputFieldBackground.Default,

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

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

if not MapSelect:AutoSelect() then
	PageHandler:ChangePage("Insert")
end

plugin.Unloading:Connect(function()
    MapSelect._Maid:DoCleaning()
    Util.MainMaid:DoCleaning()
    SettingsUtil.SettingMaid:DoCleaning()
end)
