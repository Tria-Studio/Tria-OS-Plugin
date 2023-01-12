local Fusion = require(script.Parent.Fusion)

local State = Fusion.State

local StudioTheme = settings().Studio.Theme
local GuideColor = Enum.StudioStyleGuideColor
local GuideModifier = Enum.StudioStyleGuideModifier

local themes = {
    Titlebar = {
        Default = State(StudioTheme:GetColor(GuideColor.Titlebar)),
    },
    Border = {
        Default = State(StudioTheme:GetColor(GuideColor.Border))
    },
    Button = {
        Default = State(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Default)),
        Hover = State(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Hover)),
        Selected = State(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Selected))
    },
    MainText = {
        Default = State(StudioTheme:GetColor(GuideColor.MainText))
    },
    MainButton = {
        Default = State(StudioTheme:GetColor(GuideColor.MainButton))
    },
    BrightText = {
        Default = State(StudioTheme:GetColor(GuideColor.BrightText))
    },
    MainBackground = {
        Default = State(StudioTheme:GetColor(GuideColor.MainBackground))
    },
    TitlebarText = {
        Default = State(StudioTheme:GetColor(GuideColor.TitlebarText))
    },
    ErrorText = {
        Default = State(StudioTheme:GetColor(GuideColor.ErrorText))
    },
    InputFieldBackground = {
        Default = State(StudioTheme:GetColor(GuideColor.InputFieldBackground))
    },
    DimmedText = {
        Default = State(StudioTheme:GetColor(GuideColor.DimmedText))
    },
    SubText = {
        Default = State(StudioTheme:GetColor(GuideColor.SubText))
    },
    Notification = {
        Default = State(StudioTheme:GetColor(GuideColor.Notification))
    },
    CategoryItem = {
        Default = State(StudioTheme:GetColor(GuideColor.CategoryItem))
    },
    ButtonText = {
        Default = State(StudioTheme:GetColor(GuideColor.ButtonText))
    },
    ColorPickerFrame = {
        Default = State(StudioTheme:GetColor(GuideColor.ColorPickerFrame))
    },
    ScrollBarBackground = {
        Default = State(StudioTheme:GetColor(GuideColor.ScrollBarBackground))
    },
    ScrollBar = {
        Default = State(StudioTheme:GetColor(GuideColor.ScrollBar))
    },
    HeaderSection = {
        Default = State(StudioTheme:GetColor(GuideColor.HeaderSection))
    },
    Dropdown = {
        Default = State(StudioTheme:GetColor(GuideColor.Dropdown))
    },
    RibbonButton = {
        Default = State(StudioTheme:GetColor(GuideColor.RibbonButton)),
        Hover = State(StudioTheme:GetColor(GuideColor.RibbonButton, GuideModifier.Hover))
    },
    Item = {
        Default = State(StudioTheme:GetColor(GuideColor.Item)),
    },
    CheckedFieldBackground = {
        Default = State(StudioTheme:GetColor(GuideColor.CheckedFieldBackground))
    },
    CheckedFieldBorder = {
        Default = State(StudioTheme:GetColor(GuideColor.CheckedFieldBorder))
    },
    CheckedFieldIndicator = {
        Default = State(StudioTheme:GetColor(GuideColor.CheckedFieldIndicator))
    },
}

settings().Studio.ThemeChanged:Connect(function()
    StudioTheme = settings().Studio.Theme
    --TODO this doesnt work
    for Name, Value in pairs(themes) do
        for Theme, _ in pairs(Value) do
            themes[Name][Theme]:set(StudioTheme:GetColor(GuideColor[Name], GuideModifier[Theme]))
        end
    end
end)

return themes
