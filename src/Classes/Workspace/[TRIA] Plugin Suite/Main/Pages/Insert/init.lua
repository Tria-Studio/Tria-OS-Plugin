
local InsertService = game:GetService("InsertService")
local Selection = game:GetService("Selection")

local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed

local frame = {}

local function attemptTask(service, functionName: string, ...): (boolean, any)
    local MAX_ATTEMPTS = 5

    local attemptCount = 0
    local success, result

    repeat
        attemptCount += 1
        print(("Calling '%s', attempt %d/%d"):format(functionName, attemptCount, MAX_ATTEMPTS))
        success, result = pcall(service[functionName], service, ...)
        if not success then
            warn(("Attempt to call '%s' failed, attempt %d/%d"):format(functionName, attemptCount, MAX_ATTEMPTS))
            task.wait(1)
        else
            break
        end
    until attemptCount >= MAX_ATTEMPTS

    if not success then
        warn(("Process '%s' failed after %d attempt(s)"):format(functionName, MAX_ATTEMPTS))
    end
    return success, result
end

function attemptToInsertModel(assetID: number)
    if assetID == 0 then
        return
    end
    local success, result

    success, result = attemptTask(InsertService, "GetLatestAssetVersionAsync", assetID)
    if not success then return end

    success, result = attemptTask(InsertService, "LoadAssetVersion", result)
    if not success then return end

    result = result:GetChildren()[1]
    result.Name = "[INSERTED] - " .. result.Name
    result:PivotTo(CFrame.new())
    result.Parent = workspace
    Selection:Set({result})
end

function HeaderText(data)
    return New "TextLabel" {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Theme.Titlebar.Default,
        FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
        LayoutOrder = data.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 32),
        TextColor3 = Theme.TitlebarText.Default,
        Text = data.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextSize = 16,

        [Children] = {
            Components.Constraints.UIPadding(nil, nil, UDim.new(0, 12), nil),
            Components.TooltipImage {
                Header = data.Text,
                Tooltip = data.Tooltip,
                Position = UDim2.new(1, -12, 0.5, 0)
            }
        }
    }
end

function KitInsertButton(data)
    return Components.ImageButton {
        BackgroundColor3 = data.BackgroundColor or Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        LayoutOrder = data.LayoutOrder,
        Size = data.BoxSize,

        [OnEvent "Activated"] = function()
            attemptToInsertModel(data.AssetID)
        end,

        [Children] = {
            Components.Constraints.UICorner(0, 6),
            Components.Constraints.UIGradient(
                data.GradientColor,
                NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.25),
                    NumberSequenceKeypoint.new(0.75, 0),
                    NumberSequenceKeypoint.new(1, 0.75)
                }),
                90
            ),

            New "ImageLabel" {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.8, 1),
                Image = data.Image,
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Crop
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 24),
                Text = data.Text,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 16,
                TextTruncate = Enum.TextTruncate.AtEnd,
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                Position = UDim2.fromScale(0, 0.65),
                Size = UDim2.new(1, 0, -0.325, 24),
                Text = "by @" .. tostring(data.Creator),
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,

                Visible = Computed(function()
                    return data.Creator ~= nil
                end):get()
            }
        }
    }
end

function SubFrame(data)
    return New "Frame" {
        BackgroundTransparency = 1,
        LayoutOrder = data.LayoutOrder,
        Size = UDim2.new(1, 0, 0, 64),

        [Children] = {
            Components.Constraints.UIListLayout(Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, UDim.new(0, 8), Enum.VerticalAlignment.Top),
            data.Children
        }
    }
end

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Insert",

        [Children] = {
            Components.PageHeader("Map Addons, Kits, Components"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 0,
                ClipsDescendants = true,
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 6), Enum.VerticalAlignment.Top),
                    HeaderText({Text = "Map Kits", LayoutOrder = 1, Tooltip = "Tooltip here"}),

                    KitInsertButton({
                        BoxSize = UDim2.new(1, -24, 0, 64),
                        LayoutOrder = 2,
                        GradientColor = ColorSequence.new(Color3.fromRGB(255, 93, 0), Color3.fromRGB(255, 0, 230)),
                        Image = "rbxassetid://9441561539",
                        Text = "Official TRIA.OS Map Kit",
                        AssetID = 6404661021
                    }),

                    -- SubFrame({
                    --     LayoutOrder = 3,
                    --     Children = {
                    --         KitInsertButton({
                    --             BackgroundColor = Color3.fromRGB(43, 124, 255),
                    --             BoxSize = UDim2.new(0.5, -16, 0, 64),
                    --             GradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
                    --             Image = "rbxassetid://9441689114",
                    --             Text = "Map Textures Kit",
                    --             Creator = "Phexonia",
                    --             AssetID = 0
                    --         }),
                
                    --         KitInsertButton({
                    --             BackgroundColor = Color3.fromRGB(58, 220, 0),
                    --             BoxSize = UDim2.new(0.5, -16, 0, 64),
                    --             GradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
                    --             Image = "rbxassetid://9441751309",
                    --             Text = "TRIA.OS Jump Kit",
                    --             Creator = "epicflamingo100",
                    --             AssetID = 0
                    --         })
                    --     },
                    -- }),

                    HeaderText({Text = "Map Modifications", LayoutOrder = 4, Tooltip = "Tooltip here"}),
                    SubFrame({
                        LayoutOrder = 5,
                        Children = {
                            KitInsertButton({
                                BackgroundColor = Color3.fromRGB(229, 0, 3),
                                BoxSize = UDim2.new(0.5, -16, 0, 64),
                                GradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
                                Image = "rbxassetid://0",
                                Text = "EasyTP",
                                Creator = "grif_0",
                                AssetID = 0
                            }),

                            KitInsertButton({
                                BackgroundColor = Color3.fromRGB(24, 214, 167),
                                BoxSize = UDim2.new(0.5, -16, 0, 64),
                                GradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
                                Image = "rbxassetid://0",
                                Text = "Liquid Jetstreams",
                                Creator = "grif_0",
                                AssetID = 0
                            })
                        },
                    }),

                    HeaderText({Text = "Map Components", LayoutOrder = 6, Tooltip = "Tooltip here"}),
                }
            }
        }
    }
end

return frame
