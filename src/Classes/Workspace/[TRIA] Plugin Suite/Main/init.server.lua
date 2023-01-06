local TextService = game:GetService("TextService")
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
local State = Fusion.State
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

Widget.Title = "[TRIA] Plugin Suite"



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
				}),
				Components.ImageButton({
					AnchorPoint = Vector2.new(1, .5),
					Size = UDim2.new(0, 20, 0, 20),
					Position = UDim2.new(1, -2, .5, 0),
					Image = "rbxassetid://6022668885",
					ImageColor3 = State(Theme.SubText.Default):get(),
					BackgroundColor3 = Theme.Button.Default,
				})
			}
		},
		New "Frame" { --// Message
			BackgroundTransparency = .75,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Visible = Computed(function()
				return Util._Message.Text:get() ~= ""
			end),

			[Children] = {
				New "ImageLabel" {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -12, 0, 152),
					Position = UDim2.new(.5, 0, .5, 0),
					AnchorPoint = Vector2.new(.5, .5),
					Image = "rbxassetid://8697780388",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = .5,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(200, 200, 300, 300),
					SliceScale = 0.075
				},
				New "Frame" {
					BackgroundColor3 = Theme.Notification.Default,
					BorderColor3 = Theme.Border.Default,
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.new(.5, 0, .5, 0),
					Size = UDim2.new(1, -36, 0, 128),

					[Children] = {
						New "Frame" { --// Topbar
							BackgroundColor3 = Theme.CategoryItem.Default,
							BorderColor3 = Theme.Border.Default,
							BorderSizePixel = 1,
							Size = UDim2.new(1, 0, 0, 24),
						
							[Children] = {
								Components.ImageButton({
									AnchorPoint = Vector2.new(1, 0),
									Size = UDim2.new(0, 24, 0, 24),
									Position = UDim2.new(1, 0, 0, 0),
									Image = "rbxassetid://6031094678",
									ImageColor3 = Theme.ErrorText.Default,
									BorderMode = Enum.BorderMode.Outline,
									Callback = Util.CloseMessage
								}),
								New "TextLabel" {
									BackgroundTransparency = 1,
									Size = UDim2.new(1, -24, 1, 0),
									Text = Util._Message.Header,
									TextColor3 = Theme.TitlebarText.Default,
									Font = Enum.Font.SourceSansBold,
									TextXAlignment = Enum.TextXAlignment.Left,

									[Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8))
								}
							}
						},
						New "TextLabel" { --// Body
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0, 24),
							Size = UDim2.new(1, 0, 1, -48),
							Text = Util._Message.Text,
							TextColor3 = Theme.MainText.Default,
							TextSize = 13,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,

							[Children] = Components.Constraints.UIPadding(UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
						} ,
						New "Frame" { --// Buttons
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 1, 0),
							Size = UDim2.new(1, 0, 0, 24),

							[Children] = {
								Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, UDim.new(0, 8)),
								Components.TextButton({ --// Option 1
									LayoutOrder = 1,
									BackgroundColor3 = Theme.Button.Selected,
									Size = UDim2.new(0, 56, 0, 18),
									Text = Computed(function()
										return Util._Message.Option1:get().Text or ""
									end),
									TextColor3 = Theme.BrightText.Default,
									BorderMode = Enum.BorderMode.Outline,
									Callback = function()
										Util._Message.Option1:get().Callback()
									end
								}),
								Components.TextButton({ --// Option 2
									LayoutOrder = 2,
									BackgroundColor3 = Theme.Button.Default,
									Size = UDim2.new(0, 56, 0, 18),
									Text = Computed(function()
										return Util._Message.Option2:get() and Util._Message.Option2:get().Text or ""
									end),
									Visible = Computed(function()
										Util._Message.Text:get()
										return Util._Message.Option2:get().Text ~= nil
									end),
									TextColor3 = Theme.ButtonText.Default,
									BorderMode = Enum.BorderMode.Outline,
									Callback = function()
										if Util._Message.Option2:get() then 
											Util._Message.Option2:get().Callback()
										end
									end
								})
							}
						}
					}
				}
			}
		}

		-- Colorwheel
		
		-- Message
		
		
		
		
	}
}

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled

	if Widget.Enabled then
		Util:ShowMessage("Test Message", "This is a test you idiot")
	end
end)

SelectMap:AutoSelect()
