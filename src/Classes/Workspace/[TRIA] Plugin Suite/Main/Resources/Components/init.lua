local Resources = script.Parent
local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Util = require(Resources.Parent.Util)
local lerpType = require(Resources.Fusion.Animation.lerpType)
local PublicTypes = require(Resources.Parent.PublicTypes)

local Pages = require(script.Pages)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Spring = Fusion.Spring
local Ref = Fusion.Ref

local Components = {
    Constraints = require(script.Constraints),
}
 
function Components.TextButton(data: PublicTypes.dictionary): Instance
    return Hydrate(New "TextButton" {
        AutoButtonColor = true,
        BackgroundColor3 = Theme.Button.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset
    })(data)
end

function Components.ImageButton(data: PublicTypes.dictionary): Instance
    return Hydrate(New "ImageButton" {
        BackgroundColor3 = Theme.Button.Default,
        BorderSizePixel = 1,
        ImageColor3 = Theme.MainText.Default,
        BorderMode = Enum.BorderMode.Inset,
        AutoButtonColor = true
    })(data)
end

function Components.TextBox(data: PublicTypes.dictionary): Instance
    return Hydrate(New "TextBox" {
        PlaceholderColor3 = Theme.DimmedText.Default,
        BackgroundColor3 = Theme.InputFieldBackground.Default,
        BorderColor3 = Theme.InputFieldBorder.Default,
        BorderSizePixel = 1,
        TextColor3 = Theme.SubText.Default,
    })(data)
end

function Components.TopbarButton(index: number, data: PublicTypes.dictionary): Instance
    data.Visible = Pages.pageData.pages[data.Name].Visible

    local startColor = Color3.fromRGB(245, 158, 29)
    local endColor = Color3.fromRGB(247, 0, 255)

    local transparencySpring = Spring(Computed(function()
        return data.Visible:get() and 0 or 1
    end), 20)

    local pageRatio = Computed(function()
        return Util._currentPageNum:get() / #Util._PageOrder
    end)

    local colorSpring = Spring(Computed(function()
        return lerpType(startColor, endColor, pageRatio:get())
    end), 20)

    return New "TextButton" {
        Active = true,
        AutoButtonColor = true,
        BackgroundColor3 = Spring(Computed(function()
            local hoverColor = Theme.RibbonButton.Hover:get()
            local titlebarColor = Theme.RibbonButton.Default:get()
            return if data.Visible:get() then hoverColor else titlebarColor
        end), 20),
        
        [OnEvent "Activated"] = function()
            if not Util._Topbar.FreezeFrame:get(false) or table.find(Pages.pageData.bypassedPages, data.Name) ~= nil then
                Pages:ChangePage(data.Name)
                Util._currentPageNum:set(table.find(Util._PageOrder, data.Name))
            end
        end,

        [Children] = {
            New "Frame" {
                Name = "Enabled",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,

                [Children] = {
                    New "Frame" { -- Left border
                        BackgroundColor3 = Theme.Border.Default,
                        BackgroundTransparency = transparencySpring,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" { -- Right border
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1, 0),
                        BackgroundColor3 = Theme.Border.Default,
                        BackgroundTransparency = transparencySpring,
                        Size = UDim2.new(0, 2, 1, 0),
                    },
                    New "Frame" { -- Top line
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        BackgroundColor3 = colorSpring,
                        BackgroundTransparency = transparencySpring,
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

                [Children] = {
                    Components.Constraints.UIAspectRatio(1),
                    Components.Constraints.UIGradient(Computed(function()
                        local ratio = (index - 1) / #Util._PageOrder

                        local start = lerpType(startColor, endColor, ratio)
                        local finish = lerpType(startColor, endColor, ratio + (1 / #Util._PageOrder))

                        return ColorSequence.new(start, finish)
                    end):get(), NumberSequence.new(0), 0)        
                },
            }
        }
    }
end

function Components.PageHeader(pageName: string): Instance
    return New "TextLabel" {
        ZIndex = 2,
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundColor3 = Theme.Titlebar.Default,
        TextColor3 = Theme.TitlebarText.Default,
        Text = pageName,
        AnchorPoint = Vector2.new(0, 1),
        TextYAlignment = Enum.TextYAlignment.Top,
            
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

function Components.MiniTopbar(data: PublicTypes.dictionary): Instance
  return New "Frame" { --// Topbar
        BackgroundColor3 = Theme.CategoryItem.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        ZIndex = data.ZIndex or 2,
        Size = UDim2.new(1, 0, 0, 24),
    
        [Children] = {
            Components.ImageButton({
                ZIndex = data.ZIndex or 2,
                AnchorPoint = Vector2.new(1, 0),
                Size = UDim2.fromOffset(24, 24),
                Position = UDim2.fromScale(1, 0),
                Image = "rbxassetid://6031094678",
                ImageColor3 = Theme.ErrorText.Default,
                BorderMode = Enum.BorderMode.Outline,
                
                [OnEvent "Activated"] = data.Callback
            }),
            New "TextLabel" {
                ZIndex = data.ZIndex or 2,
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

function optionButtonComponent(data: PublicTypes.dictionary, zIndex: number): Instance
    return Components.TextButton({
        LayoutOrder = 1,
        ZIndex = zIndex,
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

function Components.TwoOptions(option1Data: PublicTypes.dictionary, option2Data: PublicTypes.dictionary, zIndex: number): Instance
    return New "Frame" { --// Buttons
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 24),
        ZIndex = zIndex,

        [Children] = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, UDim.new(0, 6), Enum.VerticalAlignment.Center),
            Components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 3)),
            optionButtonComponent(option1Data, zIndex),
            optionButtonComponent(option2Data, zIndex),
        },
    }
end

function Components.FrameHeader(text: string, layoutOrder: number, color: any?, size: number?, tooltip: any?, ZIndex: number?): Instance
    return New "TextLabel" {
        BackgroundColor3 = color or Theme.HeaderSection.Default,
        BorderColor3 = Theme.Border.Default,
        BorderSizePixel = 1,
        LayoutOrder = layoutOrder,
        BorderMode = Enum.BorderMode.Middle,
        Size = UDim2.new(1, 0, 0, size or 30),
        Font = Enum.Font.SourceSansBold,
        Text = text,
        TextColor3 = Theme.MainText.Default,
        ZIndex = ZIndex,

        [Children] = tooltip and Components.TooltipImage ({
            Header = text,
            Tooltip = tooltip,
            Position = UDim2.new(1, -12, 0, 5),
            ZIndex = ZIndex
        }) or nil
    }
end

function Components.ScrollingFrame(data: PublicTypes.dictionary, bypassRestriction: boolean?): Instance
    return Hydrate(New "ScrollingFrame" {
        ScrollingEnabled = bypassRestriction or Util.interfaceActive,
        BorderColor3 = Theme.Border.Default,
        CanvasSize = UDim2.fromScale(0, 0),
        BorderSizePixel = 1,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        BackgroundColor3 = Theme.ScrollBarBackground.Default,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarImageColor3 = Theme.CurrentMarker.Default,
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
    })(data)
end

function Components.Dropdown(data: PublicTypes.dictionary, childrenProcessor: (boolean) -> Instance | {Instance}, bypassRestriction: boolean?): Instance
    local dropdownVisible = Value(data.DefaultState)
    local headerColor = Value(data.IsSecondary and Theme.CategoryItem.Default or Theme.Button.Default)
    local frame = Value()
    local headerPos = true

    local dropdown = New "Frame" {
        Size = UDim2.fromScale(1, 0),
        BackgroundColor3 = Computed(function()
            return headerColor:get():get()
        end),
        Name = data.Header,
        BackgroundTransparency = 0,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border.Default,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = data.LayoutOrder,

        [Ref] = frame,
        [OnEvent "MouseLeave"] = function()
            headerColor:set(data.IsSecondary and Theme.CategoryItem.Default or Theme.Button.Default)
            headerPos = true
        end,
        [OnEvent "MouseMoved"] = function(_, Ypos)
            Ypos -= frame:get().AbsolutePosition.Y
            if Ypos <= 24 and headerPos then
                headerPos = false
                headerColor:set(data.IsHeader and Theme.CurrentMarker.Default or Theme.Button.Hover)
            elseif Ypos > 24 and not headerPos then
                headerPos = true
                headerColor:set(data.IsSecondary and Theme.CategoryItem.Default or Theme.Button.Default)
            end
        end,

        [Children] = {
            (function()
                local props = {
                    Active = bypassRestriction or Util.interfaceActive,
                    BackgroundTransparency = 1,
    
                    FontFace = Font.new("SourceSans", Enum.FontWeight.Bold),
                    Size = UDim2.new(1, -20, 0, 24),
                    Position = UDim2.fromOffset(24, 0),
    
                    Text = data.Header,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = true,
    
                    [Children] = {
                        data.HeaderChildren,

                        New "ImageLabel" {
                            Image = "rbxassetid://6034328955",
                            AnchorPoint = Vector2.new(1, 0.5),
                            BackgroundTransparency = 1,
                            Visible = data.HeaderEditable or false,
                            Position = UDim2.fromScale(0.85, 0.5),
                            ImageColor3 = Theme.SubText.Default,
                            Size = UDim2.fromOffset(18, 18),
                            ZIndex = 2,
                        }
                    }
                }

                if data.HeaderEditable then
                    local textBox = Components.TextBox(props)
                    return Hydrate(textBox) {
                        [OnEvent "FocusLost"] = function()
                            if data.OnHeaderChange then
                                data.OnHeaderChange(textBox.Text)
                            end
                        end
                    }
                else
                    return Hydrate(Components.TextButton(props)) {
                        TextColor3 = data.IsSecondary and Theme.SubText.Default,
                        AutoButtonColor = bypassRestriction or Util.interfaceActive,
                        [OnEvent "Activated"] = function()
                            dropdownVisible:set(not dropdownVisible:get(false))
                        end,
                    }
                end
            end)(),

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

function Components.DropdownTextlabel(data: PublicTypes.dictionary): Instance
    return New "TextLabel" {
        TextXAlignment = data.TextXAlignment,
        BackgroundColor3 = Theme.Notification.Default,
        TextColor3 = Theme.MainText.Default,
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

function Components.DropdownHolderFrame(data: PublicTypes.dictionary): Instance
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

function Components.TooltipImage(data: PublicTypes.dictionary): Instance
    if not data.Tooltip and not data.Header then
        return
    end
    local isActive = Computed(function()
        return not Util.isPluginFrozen()
    end)
    return New "ImageButton" {
        ZIndex = data.ZIndex,
        Active = isActive,
        Position = data.Position,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Name = "Tooltip",
        Size = UDim2.fromOffset(18, 18),
        Image = "rbxassetid://6026568254",
        HoverImage = "rbxassetid://6026568247",
        ImageColor3 = Theme.SubText.Default,

        [OnEvent "Activated"] = function()
            if not data.Header or not data.Tooltip then
                return
            end
            Util:ShowMessage(tostring(data.Header), tostring(data.Tooltip))
        end,
    }
end

function Components.Checkbox(size: number, position: UDim2, anchorPoint: Vector2?, checkState): Instance
     return New "ImageLabel" { --// Checkbox
        BackgroundTransparency = 0.25,
        BackgroundColor3 = Theme.CheckedFieldBackground.Default,
        BorderColor3 = Theme.CheckedFieldBorder.Default,
        BorderSizePixel = 1,
        AnchorPoint = anchorPoint,
        Position = position,
        Size = UDim2.fromOffset(size, size),
        Image = Computed(function()
            return if checkState:get() == Enum.TriStateBoolean.True or checkState:get() == true
                then "rbxassetid://6031068421" --// Checked
                elseif checkState:get() == Enum.TriStateBoolean.False  or checkState:get() == false
                then "rbxassetid://6031068420" --// Unchecked
                else "rbxassetid://6031068445" --// Unknown
        end),
        ImageColor3 = Theme.CheckedFieldIndicator.Default,
    }
end

function Components.DropdownButton(props: PublicTypes.dictionary): Instance
    local arrowButton = Value()
    local dropdownVisible = Value(false)

    return Components.ImageButton {
        AnchorPoint = Vector2.new(1, 0),
        Active = Util.interfaceActive,
        Position = props.Position,
        Size = props.Size,

        [Ref] = arrowButton,

        [Children] = {
            Components.Constraints.UIAspectRatio(1),
            New "ImageLabel" {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031094687",
                Rotation = Spring(Computed(function()
                    return dropdownVisible:get() and 0 or 180
                end), 20),
                ZIndex = 8,
            }
        },

        [OnEvent "Activated"] = function()
            if not dropdownVisible:get() then
                dropdownVisible:set(true)
                local newData = require(Resources.Parent.Util.Dropdown):GetValue(props.Options, arrowButton:get())
                if newData and props.OnToggle then
                    props.OnToggle(newData)
                end
                dropdownVisible:set(false)
            else
                require(Resources.Parent.Util.Dropdown):Cancel()
            end
        end
    }
end

return Components
