local Fusion = require(script.Parent.Fusion)
local Util = require(script.Parent.Parent.Util)

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
        Pressed = Value(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Pressed)),
        Selected = Value(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Selected))
    },
    ButtonBorder = {
        Default = Value(StudioTheme:GetColor(GuideColor.ButtonBorder)),
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
    WarningText = {
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
    DiffTextDeletionBackground = {
        Default = Value(StudioTheme:GetColor(GuideColor.DiffTextDeletionBackground))
    },
    CurrentMarker = {
        Default = Value(StudioTheme:GetColor(GuideColor.CurrentMarker)),
        Selected = Value(StudioTheme:GetColor(GuideColor.CurrentMarker, GuideModifier.Selected)),
    },
    Mid = {
        Default = Value(StudioTheme:GetColor(GuideColor.Mid)),
    },
    RibbonTab = {
        Default = Value(StudioTheme:GetColor(GuideColor.RibbonTab)),
    },
    Tooltip = {
        Default = Value(StudioTheme:GetColor(GuideColor.Tooltip))
    },
    Light = {
        Default = Value(StudioTheme:GetColor(GuideColor.Light))
    }
}

settings().Studio.ThemeChanged:Connect(function()
    StudioTheme = settings().Studio.Theme
    for name, data in pairs(themes) do
        for key, _ in pairs(data) do
            themes[name][key]:set(StudioTheme:GetColor(GuideColor[name], GuideModifier[key]))
        end
    end
    Util.ThemeChanged:Fire()
    Util._ThemeUpdate:set(Util._ThemeUpdate:get() + 1)
end)

return themes
