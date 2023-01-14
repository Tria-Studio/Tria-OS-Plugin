local Resources = script.Parent
local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Util = require(Resources.Parent.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

local components = {
    Constraints = require(script.Constraints),
}

function components.TextButton(data)
    return New "TextButton" {
        Active = data.Active,
        AutoButtonColor = data.AutoButtonColor or true,
        BackgroundColor3 = data.BackgroundColor3 or Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        AutomaticSize = data.AutomaticSize,
        BorderSizePixel = data.BorderSizePixel or 1,
        AnchorPoint = data.AnchorPoint,
        Size = data.Size,
        Font = data.Font, 
        FontFace = data.FontFace,
        Position = data.Position,
        Visible = data.Visible or true,
        TextSize = data.TextSize,
        Text = data.Text,
        TextColor3 = data.TextColor3 or Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,

        [OnEvent "Activated"] = data.Callback,

        [Children] = data.Children
    }
end

function components.ImageButton(data)
    return New "ImageButton" {
        BackgroundColor3 = data.BackgroundColor3 or Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = data.BorderSizePixel or 1,
        AnchorPoint = data.AnchorPoint,
        Size = data.Size,
        ZIndex = data.ZIndex,
        Position = data.Position,
        Image = data.Image,
        ImageColor3 = data.ImageColor3 or Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,
        AutoButtonColor = true,

        [OnEvent "Activated"] = data.Callback
    }
end

function components.TopbarButton(data)
    local Pages = require(script.Pages)
    data.Visible = Pages.pageData.pages[data.Name].Visible

    return New "TextButton" {
        Active = Util.buttonsActive,
        AutoButtonColor = Util.buttonsActive,
        BackgroundColor3 = Computed(function()
            local hoverColor = Theme.RibbonButton.Hover:get()
            local titlebarColor = Theme.RibbonButton.Default:get()
            return if data.Visible:get() then hoverColor else titlebarColor
        end),
        Text = "",
        Size = UDim2.fromScale(0.167, 1),
        
        [OnEvent "Activated"] = function()
            if not Util._Topbar.FreezeFrame:get() then
             Pages:ChangePage(data.Name)
            end
        end,

        [Children] = {
            New "Frame" {
                Name = "Enabled",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = data.Visible,

                [Children] = {
                    New "Frame" {
                        BackgroundColor3 = Theme.Border.Default,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1, 0),
                        BackgroundColor3 = Theme.Border.Default,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" {
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        BackgroundColor3 = Theme.MainButton.Default,
                        Size = UDim2.new(1, -4, 0, 2),
                    },
                }
            },
            New "Frame" {
                Name = "Disabled",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = Computed(function()
                    return not data.Visible:get()
                end),

                [Children] =  New "Frame" {
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.fromScale(0.5, 1),
                    BackgroundColor3 = Theme.Border.Default,
                    Size = UDim2.new(1, 0, 0, 2),
                },
            },
            New "ImageLabel" {
                ImageColor3 = Theme.BrightText.Default,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, 0, 0.7, 0),
                Image = data.Icon,

                [Children] = components.Constraints.UIAspectRatio(1),
            }
        }
    }
end

function components.PageHeader(Name: string)
    return  New "TextLabel" {
        ZIndex = 2,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Theme.Titlebar.Default,
        TextColor3 = Theme.TitlebarText.Default,
        Text = Name,
        AnchorPoint = Vector2.new(0, 1),

        [Children] = New "Frame" {
            BackgroundColor3 = Theme.Border.Default,
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(1, 0, 0, 2),
            ZIndex = 2
        }
    }
end

function components.MiniTopbar(data)
  return New "Frame" { --// Topbar
        BackgroundColor3 = Theme.CategoryItem.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        ZIndex = 2,
        Size = UDim2.new(1, 0, 0, 24),
    
        [Children] = {
            components.ImageButton({
                ZIndex = 2,
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.fromOffset(24, 24),
                Position = UDim2.fromScale(1, 0),
                Image = "rbxassetid://6031094678",
                ImageColor3 = Theme.ErrorText.Default,
                BorderMode = Enum.BorderMode.Outline,
                Callback = data.Callback
            }),
            New "TextLabel" {
                ZIndex = 2,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 1, 0),
                Text = data.Text,
                TextColor3 = Theme.MainText.Default,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = components.Constraints.UIPadding(nil, nil, UDim.new(0, 8))
            }
        }
    }
end

function optionButtonComponent(data)
    return components.TextButton({
        LayoutOrder = 1,
        BackgroundColor3 = Theme.Button.Selected,
        Size = UDim2.fromOffset(56, 18),
        Text = data.Text, 
        AutomaticSize = Enum.AutomaticSize.X,
        TextColor3 = Theme.BrightText.Default,
        Font = Enum.Font.SourceSansSemibold,
        BorderMode = Enum.BorderMode.Outline,
        Callback = data.Callback
    }),
end

function components.TwoOptions(option1Data, option2Data)
    return New "Frame" { --// Buttons
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 24),

        [Children] = {
            components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, UDim.new(0, 6), Enum.VerticalAlignment.Center),
            components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 3)),
            optionButtonComponent(option1Data),
            optionButtonComponent(option2Data),
        },
    }
end

function components.ScrollingFrameHeader(text: string, layoutOrder: number, color: any?, size: number?)
    return New "TextLabel" {
        BackgroundColor3 = color or Theme.HeaderSection.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        LayoutOrder = layoutOrder,
        BorderMode = Enum.BorderMode.Middle,
        Size = UDim2.new(1, 0, 0, size or 28),
        Font = Enum.Font.SourceSansBold,
        Text = text,
        TextColor3 = Theme.MainText.Default,
        TextSize = 17,
    }
end

function components.ScrollingFrame(data)
    return New "ScrollingFrame" {
        BorderColor3 = Theme.Border.Default,
        CanvasSize = UDim2.fromScale(0, 0),
        BorderSizePixel = 1,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        BackgroundColor3 = data.BackgroundColor3 or Theme.ScrollBarBackground.Default,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageColor3 = Theme.ScrollBar.Default,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",

        Size = data.Size,
        Visible = data.Visible or true,

        [Children] = data.Children
    }
end

function components.Dropdown(data)
    local dropdownVisible = Value(data.DefaultState)

   return New "Frame" {
        Size = UDim2.fromScale(1, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = data.LayoutOrder,

        [Children] = {
            components.TextButton({
                Active = Computed(Util.buttonActiveFunc),
                AutoButtonColor = Computed(Util.buttonActiveFunc),

                FontFace = Font.new("SourceSans", Enum.FontWeight.Bold),
                TextSize = 16,
                Text = data.Header,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Theme.Button.Default,

                Callback = function()
                    dropdownVisible:set(not dropdownVisible:get())
                end,
        
                Children = {
                    components.Constraints.UIPadding(nil, nil, UDim.new(0, 12), UDim.new(0, 12)),
                    New "ImageLabel" {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(1, 0.5),
                        Size = UDim2.fromScale(1.25, 1.25),
                        Image = Computed(function()
                            return if dropdownVisible:get() then "rbxassetid://6031091004" else "rbxassetid://6031090990"
                        end),
        
                        [Children] = components.Constraints.UIAspectRatio(1)
                    }
                }
            }),
            New "TextLabel" {
                AutomaticSize = Computed(function()
                    return if dropdownVisible:get() then Enum.AutomaticSize.Y else Enum.AutomaticSize.None   
                 end),
                 BackgroundColor3 = Theme.Notification.Default,
                 BorderColor3 = Theme.Border.Default,
                 TextColor3 = Theme.MainText.Default,
                 BorderSizePixel = 1,
                 Visible = dropdownVisible,
                 Size = UDim2.fromScale(1, 0),
                 Position = UDim2.fromOffset(0, 24),
                 Text = data.Text,
                 RichText = true,
                 TextWrapped = true
            }
        }
    }
end

return components
