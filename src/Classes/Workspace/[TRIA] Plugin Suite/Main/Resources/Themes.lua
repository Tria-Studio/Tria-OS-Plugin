local Fusion = require(script.Parent.Fusion)

local Value = Fusion.Value

local StudioTheme = settings().Studio.Theme
local GuideColor = Enum.StudioStyleGuideColor
local GuideModifier = Enum.StudioStyleGuideModifier

local themes = {
    Titlebar = {
        Default = Value(StudioTheme:GetColor(GuideColor.Titlebar)),
    },
    Border = {
        Default = Value(StudioTheme:GetColor(GuideColor.Border))
    },
    Button = {
        Default = Value(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Default)),
        Hover = Value(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Hover)),
        Selected = Value(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Selected))
    },
    MainText = {
        Default = Value(StudioTheme:GetColor(GuideColor.MainText))
    },
    MainButton = {
        Default = Value(StudioTheme:GetColor(GuideColor.MainButton))
    },
    BrightText = {
        Default = Value(StudioTheme:GetColor(GuideColor.BrightText))
    },
    MainBackground = {
        Default = Value(StudioTheme:GetColor(GuideColor.MainBackground))
    },
    TitlebarText = {
        Default = Value(StudioTheme:GetColor(GuideColor.TitlebarText))
    },
    WarnText = {
        Default = Value(StudioTheme:GetColor(GuideColor.WarningText))
    },
    ErrorText = {
        Default = Value(StudioTheme:GetColor(GuideColor.ErrorText))
    },
    InputFieldBackground = {
        Default = Value(StudioTheme:GetColor(GuideColor.InputFieldBackground))
    },
    InputFieldBorder = {
        Default = Value(StudioTheme:GetColor(GuideColor.InputFieldBorder))
    },
    DimmedText = {
        Default = Value(StudioTheme:GetColor(GuideColor.DimmedText))
    },
    SubText = {
        Default = Value(StudioTheme:GetColor(GuideColor.SubText))
    },
    Notification = {
        Default = Value(StudioTheme:GetColor(GuideColor.Notification))
    },
    CategoryItem = {
        Default = Value(StudioTheme:GetColor(GuideColor.CategoryItem))
    },
    ButtonText = {
        Default = Value(StudioTheme:GetColor(GuideColor.ButtonText))
    },
    ColorPickerFrame = {
        Default = Value(StudioTheme:GetColor(GuideColor.ColorPickerFrame))
    },
    ScrollBarBackground = {
        Default = Value(StudioTheme:GetColor(GuideColor.ScrollBarBackground))
    },
    ScrollBar = {
        Default = Value(StudioTheme:GetColor(GuideColor.ScrollBar))
    },
    HeaderSection = {
        Default = Value(StudioTheme:GetColor(GuideColor.HeaderSection))
    },
    Dropdown = {
        Default = Value(StudioTheme:GetColor(GuideColor.Dropdown))
    },
    RibbonButton = {
        Default = Value(StudioTheme:GetColor(GuideColor.RibbonButton)),
        Hover = Value(StudioTheme:GetColor(GuideColor.RibbonButton, GuideModifier.Hover)),
    },
    Item = {
        Default = Value(StudioTheme:GetColor(GuideColor.Item)),
    },
    TableItem = {
        Default = Value(StudioTheme:GetColor(GuideColor.TableItem)),
    },
    DialogButton = {
        Default = Value(StudioTheme:GetColor(GuideColor.DialogButton)),
    },
    InfoText = {
        Default = Value(StudioTheme:GetColor(GuideColor.InfoText)),
    },
    CheckedFieldBackground = {
        Default = Value(StudioTheme:GetColor(GuideColor.CheckedFieldBackground))
    },
    CheckedFieldBorder = {
        Default = Value(StudioTheme:GetColor(GuideColor.CheckedFieldBorder))
    },
    CheckedFieldIndicator = {
        Default = Value(StudioTheme:GetColor(GuideColor.CheckedFieldIndicator))
    },
}

settings().Studio.ThemeChanged:Connect(function()
    StudioTheme = settings().Studio.Theme
    for Name, Value in pairs(themes) do
        for Theme, _ in pairs(Value) do
            themes[Name][Theme]:set(StudioTheme:GetColor(GuideColor[Name], GuideModifier[Theme]))
        end
    end
end)

return themes
