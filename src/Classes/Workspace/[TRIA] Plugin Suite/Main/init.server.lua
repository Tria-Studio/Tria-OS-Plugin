local PluginBar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local OpenButton = PluginBar:CreateButton("TRIA.os Companion Plugin", "Tools to help map making easier!", "rbxassetid://12032105372", "Mapmaking Companion")
local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 225, 250)
local Widget = plugin:CreateDockWidgetPluginGui("TRIA.os Tools", WidgetInfo)


local Fusion = require(script.Resources.Fusion)
local Components = require(script.Resources.Components)
local Theme = require(script.Resources.Themes)
local Pages = require(script.Resources.Components.Pages)
local SelectMap = require(script.SelectMap)
local Util = require(script.Util)

local New = Fusion.New
local Children = Fusion.Children

Widget.Title = "[TRIA] Plugin Suite"
Util.Widget = Widget



New "Frame" {
	Name = "TRIA.os Plugin",
	Parent = Widget,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Theme.MainBackground.Default,

	[Children] = {
		New "Frame" { -- Pages
			Name = "Pages",
			Size = UDim2.new(1, 0, 1, -76),
			Position = UDim2.new(0, 0, 0, 52),
			BackgroundTransparency = 1,

			[Children] = {
				Pages:NewPage({
					Name = "ObjectTags",
					Default = true,
				}),
				Pages:NewPage({Name = "ViewModes"}),
				Pages:NewPage({Name = "Settings"}),
				Pages:NewPage({Name = "Compatibility"}),
				Pages:NewPage({Name = "Publish"}),
				Pages:NewPage({Name = "Insert"}),
			}
		},
		New "Frame" { -- Topbar
			Name = "Topbar",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Titlebar.Default,

			[Children] = {
				Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal),
				Components.TopbarButton({
					Name = "ObjectTags",
					Icon = "rbxassetid://6031079158",
				}),
				Components.TopbarButton({
					Name = "ViewModes",
					Icon = "rbxassetid://6031260793",
				}),
				Components.TopbarButton({
					Name = "Settings",
					Icon = "rbxassetid://6031280882",
				}),
				Components.TopbarButton({
					Name = "Compatibility",
					Icon = "rbxassetid://6022668955",
				}),
				Components.TopbarButton({
					Name = "Publish",
					Icon = "rbxassetid://6034973085",
				}),
				Components.TopbarButton({
					Name = "Insert",
					Icon = "rbxassetid://6035047391",
				})
			},
		},
		New "Frame" { -- Bottom bar
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundColor3 = Theme.Titlebar.Default,
			BorderColor3 = Theme.Border.Default,
			BorderSizePixel = 1,

			[Children] = {
				New "TextLabel" {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0, .5),
					Size = UDim2.new(0, 70, 1, -4),
					Position = UDim2.new(0, 4, .5, 0),
					Text = "Selected Map:",
					TextColor3 = Theme.TitlebarText.Default,
				},
				Components.TextButton({
					Size = UDim2.new(1, -100, 1, -6),
					Position = UDim2.new(0, 76, 0, 3),
					Text = SelectMap.selectTextState,
					TextColor3 = SelectMap.selectTextColor,
					BackgroundColor3 = Theme.InputFieldBackground.Default,
					Callback = function()
						SelectMap:StartMapSelection()
					end
				}),
				Components.ImageButton({
					AnchorPoint = Vector2.new(1, .5),
					Size = UDim2.new(0, 20, 0, 20),
					Position = UDim2.new(1, -2, .5, 0),
					Image = SelectMap.selectCancelImage,
					ImageColor3 = SelectMap.selectCancelColor,
					BackgroundColor3 = Theme.Button.Default,
					Callback = function()
						if SelectMap.selectingMap:get() then
							SelectMap:StopManualSelection()
						else
							SelectMap:SetMap(nil)
						end
					end
				})
			}
		},
		require(script.Message), --// Message
		require(script.Colorwheel):GetUI(), --// Color wheel
	}
}

local function OnOpen()
	SelectMap:AutoSelect()
	task.wait(2)
	require(script.Colorwheel):GetColor()
end

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled

	if Widget.Enabled then
		OnOpen()
	end
end)
if Widget.Enabled then
	OnOpen()
end
