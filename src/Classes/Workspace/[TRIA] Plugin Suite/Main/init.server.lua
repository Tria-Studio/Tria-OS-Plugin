local PluginBar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local OpenButton = PluginBar:CreateButton("TRIA.os Companion Plugin", "Tools to help map making easier!", "rbxassetid://12032105372", "Mapmaking Companion")
local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 200, 250)
local Widget = plugin:CreateDockWidgetPluginGui("TRIA.os Tools", WidgetInfo)


local Fusion = require(script.Resources.Fusion)
local Components = require(script.Resources.Components)
local Theme = require(script.Resources.Themes)
local Pages = require(script.Resources.Components.Pages)

local New = Fusion.New
local Children = Fusion.Children
local ComputedPairs = Fusion.ComputedPairs
local State = Fusion.State
local StudioTheme = settings().Studio.Theme



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
					Icon = "rbxassetid://6034687957",
				}),
				Components.TopbarButton({
					Name = "ViewModes",
					Icon = "rbxassetid://6031763426",
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
					Icon = "rbxassetid://6035047377",
				})
			},
		},
		-- Colorwheel
		
		-- Message
		
		
		
		-- Bottom bar (map frame)
	}
}

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)