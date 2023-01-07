local Fusion = require(script.Parent.Fusion)
local Theme = require(script.Parent.Themes)
local Util = require(script.Parent.Parent.Util)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local State = Fusion.State
local OnEvent = Fusion.OnEvent

local components = {
    Constraints = require(script.Constraints)
}



function components.TextButton(data)
    return New "TextButton" {
        BackgroundColor3 = data.BackgroundColor3 or Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        AutomaticSize = data.AutomaticSize,
        BorderSizePixel = data.BorderSizePixel or 1,
        AnchorPoint = data.AnchorPoint,
        Size = data.Size,
        Font = data.Font, 
        Position = data.Position,
        Visible = data.Visible or true,
        TextSize = data.TextSize,
        Text = data.Text,
        TextColor3 = data.TextColor3 or Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,
        AutoButtonColor = true,

        [OnEvent "Activated"] = data.Callback
    }
end

function components.ImageButton(data)
    return New "ImageButton" {
        BackgroundColor3 = data.BackgroundColor3 or Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = data.BorderSizePixel or 1,
        AnchorPoint = data.AnchorPoint,
        Size = data.Size,
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
        AutoButtonColor = true,
        BackgroundColor3 = Computed(function()
            Theme.Button.Hover:get()
            Theme.Titlebar.Default:get()
            return if data.Visible:get() then Theme.Button.Hover:get() else Theme.Titlebar.Default:get()
        end),
        Text = "",
        Size = UDim2.new(.167, 0, 1, 0),
        
        [OnEvent "Activated"] = function()
            if not Util._Topbar.FreezeFrame:get() then
             Pages:ChangePage(data.Name)
            end
        end,

        [Children] = {
            New "Frame" {
                Name = "Enabled",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = data.Visible,

                [Children] = {
                    New "Frame" {
                        BackgroundColor3 = Theme.Border.Default,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, 0, 0, 0),
                        BackgroundColor3 = Theme.Border.Default,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" {
                        AnchorPoint = Vector2.new(.5, 0),
                        Position = UDim2.new(.5, 0, 0, 0),
                        BackgroundColor3 = Theme.MainButton.Default,
                        Size = UDim2.new(1, -4, 0, 2),
                    },
                }
            },
            New "Frame" {
                Name = "Disabled",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = Computed(function()
                    return not data.Visible:get()
                end),

                [Children] =  New "Frame" {
                    AnchorPoint = Vector2.new(.5, 1),
                    Position = UDim2.new(.5, 0, 1, 0),
                    BackgroundColor3 = Theme.Border.Default,
                    Size = UDim2.new(1, 0, 0, 2),
                },
            },
            New "ImageLabel" {
                ImageColor3 = Theme.BrightText.Default,
                AnchorPoint = Vector2.new(.5, .5),
                BackgroundTransparency = 1,
                Position = UDim2.new(.5, 0, .5, 0),
                Size = UDim2.new(1, 0, .7, 0),
                Image = data.Icon,

                [Children] = components.Constraints.UIAspectRatio(1),
            }
        }
    }
end

function components.PageHeader(Name: string)
    return  New "TextLabel" {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Theme.Button.Hover,
        TextColor3 = Theme.TitlebarText.Default,
        Text = Name,
        AnchorPoint = Vector2.new(0, 1),

        [Children] = New "Frame" {
            BackgroundColor3 = Theme.Border.Default,
            Position = UDim2.new(0, 0, 1, 0),
            AnchorPoint = Vector2.new(0, .5),
            Size = UDim2.new(1, 0, 0, 2)
        }
    }
end

function components.MiniTopbar(data)
  return New "Frame" { --// Topbar
        BackgroundColor3 = Theme.CategoryItem.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, 24),
    
        [Children] = {
            components.ImageButton({
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, 0, 0, 0),
                Image = "rbxassetid://6031094678",
                ImageColor3 = Theme.ErrorText.Default,
                BorderMode = Enum.BorderMode.Outline,
                Callback = data.Callback
            }),
            New "TextLabel" {
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

function components.TwoOptions(option1Data, option2Data)
    return New "Frame" { --// Buttons
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 24),

        [Children] = {
            components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, UDim.new(0, 6), Enum.VerticalAlignment.Center),
            components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 3)),
            components.TextButton({ --// Option 1
                    LayoutOrder = 1,
                    BackgroundColor3 = Theme.Button.Selected,
                    Size = UDim2.new(0, 56, 0, 18),
                    Text = option1Data.Text, 
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextColor3 = Theme.BrightText.Default,
                    Font = Enum.Font.SourceSansSemibold,
                    BorderMode = Enum.BorderMode.Outline,
                    Callback = option1Data.Callback
                }),
             components.TextButton({ --// Option 2
                LayoutOrder = 2,
                BackgroundColor3 = Theme.Button.Default,
                Size = UDim2.new(0, 56, 0, 18),
                Text = option2Data.Text,
                Visible = option2Data.Visible or true,
                AutomaticSize = Enum.AutomaticSize.X,
                TextColor3 = Theme.ButtonText.Default,
                BorderMode = Enum.BorderMode.Outline,
                Callback = option2Data.Callback
            })
        },
    }
end


return components
