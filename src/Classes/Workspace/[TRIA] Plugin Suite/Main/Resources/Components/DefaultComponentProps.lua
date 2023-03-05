local Package = script.Parent.Parent.Parent
local Resources = Package.Resources
local Theme = require(Resources.Themes)

return {
	TextButton = {
        AutoButtonColor = true,
        BackgroundColor3 = Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset
    },

	ImageButton = {
        BackgroundColor3 = Theme.Button.Default,
        BorderSizePixel = 1,
        ImageColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,
        AutoButtonColor = true
    },

	TextBox = {
        PlaceholderColor3 = Theme.DimmedText.Default,
        BackgroundColor3 = Theme.InputFieldBackground.Default,
        BorderColor3 = Theme.InputFieldBorder.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.SubText.Default,
    },

	ScrollingFrame = {
        BorderColor3 = Theme.Border.Default,
        CanvasSize = UDim2.fromScale(0, 0),
        BorderSizePixel = 1,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        BackgroundColor3 = Theme.ScrollBarBackground.Default,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageColor3 = Theme.CurrentMarker.Default,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    },

	
}