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
        Hover = State(StudioTheme:GetColor(GuideColor.Button, GuideModifier.Hover))
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
}

settings().Studio.ThemeChanged:Connect(function(a)
    StudioTheme = settings().Studio.Theme
    --TODO this doesnt work
    for Name, Value in pairs(themes) do
        for Theme, _ in pairs(Value) do
            print(themes[Name][Theme]:get())
            themes[Name][Theme]:set(StudioTheme:GetColor(GuideColor[Name], GuideModifier[Theme]))
            print(themes[Name][Theme]:get())
        end
    end
end)

return themes