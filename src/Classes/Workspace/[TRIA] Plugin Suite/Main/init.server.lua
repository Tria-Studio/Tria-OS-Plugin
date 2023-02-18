local toolbar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local openButton = toolbar:CreateButton(
	"TRIA.os Companion Plugin", 
	"Tools to help map making easier!", 
	"rbxassetid://12032105372", 
	"Mapmaking Companion"
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
local ColorWheel = require(script.Colorwheel)
local Message = require(script.Message)
local MenuData = require(script.MenuData)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local OnEvent = Fusion.OnEvent
local ForValues = Fusion.ForValues
local ForPairs = Fusion.ForPairs

widget.Title = "[TRIA] Plugin Suite"
Util.Widget = widget

New "Frame" {
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
				ForValues(MenuData.Pages, function(data)
					return PageHandler:NewPage(data)
				end, Fusion.cleanup),

				New "TextLabel" {
					Active = Computed(Util.isPluginFrozen),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = Spring(Computed(function()
						return Util.isPluginFrozen() and 0.5 or 1
					end), 18),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),

					Font = Enum.Font.SourceSansBold,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					Text = "Select a map to continue.",
					TextColor3 = Theme.BrightText.Default,
					TextSize = Spring(Computed(function()
						return 28 * (Util.isPluginFrozen() and 1 or 2)
					end), 18),
					TextTransparency = Spring(Computed(function()
						return Util.isPluginFrozen() and 0 or 1
					end), 18),

					[Children] = {
						Components.Constraints.UIGradient(ColorSequence.new(Color3.fromRGB(255, 149, 0), Color3.fromRGB(157, 0, 255))),
						Components.Constraints.UIStroke(nil, Color3.new(), nil, Spring(Computed(function()
							return Util.isPluginFrozen() and 0 or 1
						end), 18))
					}
				}
			}
		},
		New "Frame" { -- Topbar
			Name = "Topbar",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Titlebar.Default,

			[OnEvent "InputChanged"] = function(InputObject: InputObject)
				if InputObject.UserInputType == Enum.UserInputType.MouseWheel then
					local newPage = Util._currentPageNum:get(false) - InputObject.Position.Z
					newPage = if newPage < 1 then #Util._PageOrder elseif newPage > #Util._PageOrder then 1 else newPage

					Util._currentPageNum:set(newPage)
					PageHandler:ChangePage(Util._PageOrder[Util._currentPageNum:get(false)])
				end
			end,
			[Children] = {
				Components.Constraints.UIGridLayout(UDim2.fromScale(1 / #MenuData.Buttons, 1), UDim2.new(), Enum.FillDirection.Horizontal),
				ForPairs(MenuData.Buttons, function(index, data)
					return index, Components.TopbarButton(index, data)
				end, Fusion.cleanup)
			},
		},
		New "Frame" { -- Bottom bar
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 24),
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
				Components.TextButton({
					Size = UDim2.new(1, -100, 1, -6),
					Position = UDim2.fromOffset(76, 3),
					Text = MapSelect.selectTextState,
					TextColor3 = MapSelect.selectTextColor,
					BackgroundColor3 = Theme.InputFieldBackground.Default,

					[OnEvent "Activated"] = function()
						MapSelect:StartMapSelection()
					end
				}),
				Components.ImageButton({
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
					end
				})
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
			Visible = Computed(function()
				return Util.isPluginFrozen()
			end)
		}
	}
}

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

MapSelect:AutoSelect()

plugin.Unloading:Connect(function()
    MapSelect._Maid:DoCleaning()
    Util.MainMaid:DoCleaning()
    SettingsUtil.SettingMaid:DoCleaning()
end)