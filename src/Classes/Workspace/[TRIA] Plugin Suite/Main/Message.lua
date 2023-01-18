local Fusion = require(script.Parent.Resources.Fusion)
local Components = require(script.Parent.Resources.Components)
local Theme = require(script.Parent.Resources.Themes)
local Util = require(script.Parent.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

return New "Frame" { --// Message
	BackgroundTransparency = 0.75,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0),
	Visible = Computed(function()
		return Util._Message.Text:get() ~= ""
	end),

	[Children] = {
		New "ImageLabel" {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -12, 0, 152),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://8697780388",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.5,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(200, 200, 300, 300),
			SliceScale = 0.075
		},

		New "Frame" {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Notification.Default,
			BorderColor3 = Theme.Border.Default,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -36, 0, 0),

			[Children] = {
				Components.MiniTopbar({
					Text = Util._Message.Header,
					Callback = Util.CloseMessage,
				}),

				New "TextLabel" { --// Body
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 24),
					Size = UDim2.fromScale(1, 0),
					Text = Util._Message.Text,
					TextColor3 = Theme.MainText.Default,
					TextSize = 14,
					TextWrapped = true,
					RichText = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,

					[Children] = Components.Constraints.UIPadding(UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 4))
				},

				Components.TwoOptions({
					Text = Computed(function()
						return string.format("%s", Util._Message.Option1:get().Text or "")
					end),

					Callback = function()
						Util._Message.Option1:get().Callback()
						Util:CloseMessage()
					end,

					BackgroundColor3 = Computed(function()
						return Util._Message.Option1:get() and Util._Message.Option1:get().BackgroundColor3 or Theme.Button.Selected
					end)
				}, {
					Text = Computed(function()
						return Util._Message.Option2:get() and Util._Message.Option2:get().Text or ""
					end),
					
					Visible = Computed(function()
						Util._Message.Text:get()
						return Util._Message.Option2:get().Text ~= nil
					end),

					Callback = function()
						if Util._Message.Option2:get() and Util._Message.Option2:get().Callback then 
							Util._Message.Option2:get().Callback()
						end
						Util:CloseMessage()
					end,

					BackgroundColor3 = Computed(function()
						return Util._Message.Option2:get() and Util._Message.Option2:get().BackgroundColor3 or Theme.Button.Default
					end)
				})
			}
		}
	}
}
