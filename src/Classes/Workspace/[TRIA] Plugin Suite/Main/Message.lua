local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Components = require(Resources.Components)
local Theme = require(Resources.Themes)

local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local Out = Fusion.Out

local messageFrameSize = Value()

return New "Frame" { --// Message
	BackgroundTransparency = 0.625,
	BackgroundColor3 = Color3.new(0, 0, 0),
	Size = UDim2.fromScale(1, 1),
	Visible = Computed(function(): boolean
		return Util._Message.Text:get() ~= ""
	end),
	Name = "Message",
	ZIndex = 10,

	[Children] = {
		New "ImageLabel" {
			BackgroundTransparency = 1,
			Size = Computed(function(): UDim2
				local frameSize = messageFrameSize:get() or Vector2.new()
				return UDim2.new(0, frameSize.X + 24, 0, frameSize.Y + 24)
			end),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://8697780388",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.75,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(200, 200, 300, 300),
			ZIndex = 10,
			SliceScale = 0.075
		},

		New "Frame" {
			[Out "AbsoluteSize"] = messageFrameSize,

			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Notification.Default,
			BorderColor3 = Theme.Border.Default,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(1, -36, 0, 0),
			ZIndex = 10,

			[Children] = {
				Components.MiniTopbar {
					ZIndex = 10,
					Text = Util._Message.Header,
					Callback = Util.CloseMessage,
				},

				New "TextLabel" { --// Body
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 24),
					Size = UDim2.fromScale(1, 0),
					Text = Computed(function(): string
						local message = Util._Message.Text:get()
						if typeof(message) == "table" then
							message = message:get()
						end
						return message
					end),
					TextColor3 = Theme.MainText.Default,
					TextWrapped = true,
					RichText = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					ZIndex = 10,

					[Children] = Components.Constraints.UIPadding(UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 8), UDim.new(0, 8))
				},

				Components.TwoOptions({
					Text = Computed(function(): string
						return string.format("%s", Util._Message.Option1:get().Text or "")
					end),

					Callback = function()
						Util._Message.Option1:get().Callback()
						Util:CloseMessage()
					end,

					BackgroundColor3 = Computed(function(): Color3
						return Util._Message.Option1:get() and Util._Message.Option1:get().BackgroundColor3 or Theme.Button.Selected
					end),

				}, {
					Text = Computed(function(): string
						return Util._Message.Option2:get() and Util._Message.Option2:get().Text or ""
					end),
					
					Visible = Computed(function(): boolean
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
				}, 10)
			}
		}
	}
}