local PluginBar = plugin:CreateToolbar("[TRIA] Plugin Suite")
local OpenButton = PluginBar:CreateButton("TRIA.os Companion Plugin", "Tools to help map making easier!", "rbxassetid://12032105372", "Mapmaking Companion")
local WidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 250, 450, 200, 250)
local Widget = plugin:CreateDockWidgetPluginGui("TRIA.os Tools", WidgetInfo)


local Fusion = require(script.Resources.Fusion)
local Components = require(script.Resources.Components)
local Theme = require(script.Resources.Themes)

local New = Fusion.New
local Children = Fusion.Children
local ComputedPairs = Fusion.ComputedPairs
local State = Fusion.State
local StudioTheme = settings().Studio.Theme

local states = {
	ObjectTags = State(true),
	ViewModes = State(false),
	Compatibility = State(false),
	Settings = State(false),
	Publish = State(false),
	Insert = State(false),
}

Widget.Title = "[TRIA] Plugin Suite"


New "Frame" {
	Name = "TRIA.os Plugin",
	Parent = Widget,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Theme.MainBackground.Default,

	[Children] = {
		New "Frame" {
			Name = "Topbar",
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = Theme.Titlebar.Default,

			[Children] = {
				Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal),
				Components.TopbarButton({
					Visible = states.ObjectTags,
					Icon = "rbxassetid://6034687957",
				}),
				Components.TopbarButton({
					Visible = states.ViewModes,
					Icon = "rbxassetid://6031763426",
				}),
				Components.TopbarButton({
					Visible = states.Settings,
					Icon = "rbxassetid://6031280882",
				}),
				Components.TopbarButton({
					Visible = states.Compatibility,
					Icon = "rbxassetid://6022668955",
				}),
				Components.TopbarButton({
					Visible = states.Publish,
					Icon = "rbxassetid://6034973085",
				}),
				Components.TopbarButton({
					Visible = states.Insert,
					Icon = "rbxassetid://6035047377",
				})
			},
		}
		,-- Topbar

		-- Colorwheel
		
		-- Message
		
		
		
		-- Bottom bar (map frame)
		
		-- Pages
	}
}

OpenButton.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)