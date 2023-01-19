local Resources = script.Parent
local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Util = require(Resources.Parent.Util)
local Pages = require(script.Pages)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Spring = Fusion.Spring
local ForValues = Fusion.ForValues

local Components = {
    Constraints = require(script.Constraints),
}

function Components.TextButton(data)
    return Hydrate(New "TextButton" {
        AutoButtonColor = true,
        BackgroundColor3 = Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset
    })(data)
end

function Components.ImageButton(data)
    return Hydrate(New "ImageButton" {
        BackgroundColor3 = Theme.Button.Default,
        BorderSizePixel = 1,
        ImageColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,
        AutoButtonColor = true
    })(data)
end

function Components.TextBox(data)
    return Hydrate(New "TextBox" {
        PlaceholderColor3 = Theme.DimmedText.Default,
        BackgroundColor3 = Theme.InputFieldBackground.Default,
        BorderColor3 = Theme.InputFieldBorder.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.SubText.Default,
    })(data)
end

function Components.TopbarButton(data)
    data.Visible = Pages.pageData.pages[data.Name].Visible

    return New "TextButton" {
        Active = true, --Util.interfaceActive,
        AutoButtonColor = true, --Util.interfaceActive,
        BackgroundColor3 = Spring(Computed(function()
            local hoverColor = Theme.RibbonButton.Hover:get()
            local titlebarColor = Theme.RibbonButton.Default:get()
            return if data.Visible:get() then hoverColor else titlebarColor
        end), 20),
        Text = "",
        Size = UDim2.fromScale(0.167, 1),
        
        [OnEvent "Activated"] = function()
            if not Util._Topbar.FreezeFrame:get(false) or table.find(Pages.pageData.bypassedPages, data.Name) ~= nil then
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

                [Children] = Components.Constraints.UIAspectRatio(1),
            }
        }
    }
end

function Components.PageHeader(Name: string)
    return New "TextLabel" {
        ZIndex = 2,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Theme.Titlebar.Default,
        TextColor3 = Theme.TitlebarText.Default,
        Text = Name,
        AnchorPoint = Vector2.new(0, 1),

        [Children] = {
            New "Frame" {
                BackgroundColor3 = Theme.Border.Default,
                Position = UDim2.fromScale(0, 1),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                ZIndex = 2
            }
        }
    }
end

function Components.MiniTopbar(data)
  return New "Frame" { --// Topbar
        BackgroundColor3 = Theme.CategoryItem.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        ZIndex = 2,
        Size = UDim2.new(1, 0, 0, 24),
    
        [Children] = {
            Components.ImageButton({
                ZIndex = 2,
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.fromOffset(24, 24),
                Position = UDim2.fromScale(1, 0),
                Image = "rbxassetid://6031094678",
                ImageColor3 = Theme.ErrorText.Default,
                BorderMode = Enum.BorderMode.Outline,

                [OnEvent "Activated"] = data.Callback
            }),
            New "TextLabel" {
                ZIndex = 2,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 1, 0),
                Text = data.Text,
                RichText = true,
                TextColor3 = Theme.MainText.Default,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 8))
            }
        }
    }
end

function optionButtonComponent(data)
    return Components.TextButton({
        LayoutOrder = 1,
        BackgroundColor3 = data.BackgroundColor3:get(),
        Size = UDim2.fromOffset(56, 18),
        Text = data.Text, 
        AutomaticSize = Enum.AutomaticSize.X,
        TextColor3 = Theme.BrightText.Default,
        Font = Enum.Font.SourceSansSemibold,
        BorderMode = Enum.BorderMode.Outline,
        Visible = Computed(function()
            if typeof(data.Text) == "table" then
                return data.Text:get() ~= ""
            end
            return true
        end),
        [OnEvent "Activated"] = data.Callback
    })
end

function Components.TwoOptions(option1Data, option2Data)
    return New "Frame" { --// Buttons
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 24),

        [Children] = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, UDim.new(0, 6), Enum.VerticalAlignment.Center),
            Components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 3)),
            optionButtonComponent(option1Data),
            optionButtonComponent(option2Data),
        },
    }
end

function Components.ScrollingFrameHeader(text: string, layoutOrder: number, color: any?, size: number?)
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
        TextSize = 14,
    }
end

function Components.ScrollingFrame(data)
    return Hydrate(New "ScrollingFrame" {
        ScrollingEnabled = Util.interfaceActive,
        BorderColor3 = Theme.Border.Default,
        CanvasSize = UDim2.fromScale(0, 0),
        BorderSizePixel = 1,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        BackgroundColor3 = Theme.ScrollBarBackground.Default,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageColor3 = Theme.ScrollBar.Default,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    })(data)
end

function Components.Dropdown(data, childrenProcessor)
    local dropdownVisible = Value(data.DefaultState)
    local headerColor = Value(Theme.Button.Default)

    local dropdown = New "Frame" {
        Size = UDim2.fromScale(1, 0),
        BackgroundColor3 = Computed(function()
            return headerColor:get():get()
        end),
        BackgroundTransparency = 0,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border.Default,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = data.LayoutOrder,

        [OnEvent "MouseEnter"] = function()
            if Util.interfaceActive:get(false) then
                headerColor:set(Theme.Button.Pressed)
            end
        end,
        [OnEvent "MouseLeave"] = function()
            headerColor:set(Theme.Button.Default)
        end,
        
        [Children] = {
            Components.TextButton({
                Active = Util.interfaceActive,
                AutoButtonColor = Util.interfaceActive,
                BackgroundTransparency = 1,

                FontFace = Font.new("SourceSans", Enum.FontWeight.Bold),
                Size = UDim2.new(1, -20, 0, 24),
                Position = UDim2.fromOffset(24, 0),

                TextSize = 14,
                Text = data.Header,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = true,

                [OnEvent "Activated"] = function()
                    dropdownVisible:set(not dropdownVisible:get(false))
                end
            }),

            New "ImageButton" {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(20, 2),
                Size = UDim2.fromOffset(20, 20),
                Image = "rbxassetid://6031094687",

                Rotation = Spring(Computed(function()
                    return dropdownVisible:get() and 0 or 180
                end), 20),

                [Children] = Components.Constraints.UIAspectRatio(1),
                [OnEvent "Activated"] = function()
                    dropdownVisible:set(not dropdownVisible:get(false))
                end
            },

            childrenProcessor(dropdownVisible)
        }
    }
    return dropdown
end

function Components.DropdownTextlabel(data)
    return New "TextLabel" {
        TextXAlignment = data.TextXAlignment,
        BackgroundColor3 = Theme.Notification.Default,
        TextColor3 = Theme.MainText.Default,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
        Position = UDim2.fromOffset(0, 24),
        Text = data.Text,
        RichText = true,
        TextWrapped = true,

        AutomaticSize = Computed(function()
           return if data.DropdownVisible:get() then Enum.AutomaticSize.Y else Enum.AutomaticSize.None   
        end),
        Visible = data.DropdownVisible
   }
end

function Components.DropdownHolderFrame(data)
    return New "Frame" {
        AutomaticSize = Computed(function()
            return if data.DropdownVisible:get() then Enum.AutomaticSize.Y else Enum.AutomaticSize.None
        end),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 24),
        Size = UDim2.fromScale(1, 0),
        Visible = data.DropdownVisible,

        [Children] = data.Children
    }
end

function Components.TooltipImage(data)
    return New "ImageButton" {
        Active = Util.interfaceActive,
        AutoButtonColor = Util.interfaceActive,

        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme.CurrentMarker.Default,
        BackgroundTransparency = 0,
        BorderColor3 = Theme.Border.Default,
        BorderMode = Enum.BorderMode.Inset,
        BorderSizePixel = 1,
        Name = "Tooltip",
        Position = data.Position,
        Size = UDim2.fromOffset(16, 16),
        Image = "rbxassetid://6034281900",
        ImageColor3 = Theme.SubText.Default,

        [OnEvent "Activated"] = function()
            Util:ShowMessage(tostring(data.Header), tostring(data.Tooltip))
        end,
    }
end

return Components
