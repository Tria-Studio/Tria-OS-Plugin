local PluginBar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local OpenButton = PluginBar:CreateButton("TRIA.os Companion Plugin", "Tools to help map making easier!", "rbxassetid://12032105372", "Mapmaking Companion")
local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 300, 300)
local Widget = plugin:CreateDockWidgetPluginGui("TRIA.os Tools", WidgetInfo)

local Fusion = require(script.Resources.Fusion)
local Components = require(script.Resources.Components)
local Theme = require(script.Resources.Themes)
local Pages = require(script.Resources.Components.Pages)
local SelectMap = require(script.SelectMap)
local Util = require(script.Util)
local ColorWheel = require(script.Colorwheel)
local Message = require(script.Message)
local TopbarButtons = require(script.TopbarButtons)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local OnEvent = Fusion.OnEvent
local ForValues = Fusion.ForValues

Widget.Title = "[TRIA] Plugin Suite"
Util.Widget = Widget

New "Frame" {
	Name = "TRIA.os Plugin",
	Parent = Widget,
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.MainBackground.Default,

	[Children] = {
		New "Frame" { -- Pages
			Name = "Pages",
			Size = UDim2.new(1, 0, 1, -76),
			Position = UDim2.fromOffset(0, 52),
			BackgroundTransparency = 1,

			[Children] = {
				Pages:NewPage({Name = "ObjectTags", Default = true}),
				Pages:NewPage({Name = "ViewModes"}),
				Pages:NewPage({Name = "Settings"}),
				Pages:NewPage({Name = "Compatibility"}),
				Pages:NewPage({Name = "Publish"}),
				Pages:NewPage({Name = "Insert"}),
				Pages:NewPage({Name = "PluginSettings"}),

				New "TextLabel" {
					Active = Computed(function()
						return Util.isPluginFrozen()
					end),
					AnchorPoint = Vector2.new(0.5, 0.5),

					BackgroundTransparency = Spring(Computed(function()
						return Util.isPluginFrozen() and 0.5 or 1
					end), 18),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),

					Font = Enum.Font.SourceSansBold,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					Text = "Select a map to continue.",
					TextColor3 = Color3.new(1, 1, 1),
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

			[Children] = {
				Components.Constraints.UIGridLayout(UDim2.new(1 / #TopbarButtons, 0, 1, 0), UDim2.new(), Enum.FillDirection.Horizontal),
				ForValues(TopbarButtons, function(data)
					return Components.TopbarButton(data)
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
					Text = SelectMap.selectTextState,
					TextColor3 = SelectMap.selectTextColor,
					BackgroundColor3 = Theme.InputFieldBackground.Default,

					[OnEvent "Activated"] = function()
						SelectMap:StartMapSelection()
					end
				}),
				Components.ImageButton({
					AnchorPoint = Vector2.new(1, 0.5),
					Size = UDim2.fromOffset(20, 20),
					Position = UDim2.new(1, -2, 0.5, 0),
					Image = SelectMap.selectCancelImage,
					ImageColor3 = SelectMap.selectCancelColor,
					BorderSizePixel = 1,
					BorderColor3 = Theme.Border.Default,

					[OnEvent "Activated"] = function()
						if SelectMap.selectingMap:get(false) then
							SelectMap:StopManualSelection()
						else
							SelectMap:SetMap(nil)
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


local function onOpen()
	SelectMap:AutoSelect()
end

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled

	if Widget.Enabled then
		onOpen()
	end
end)

if Widget.Enabled then
	onOpen()
end
