
local InsertService = game:GetService("InsertService")

local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local Util = require(Package.Util)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local frame = {}

local function attemptTask(functionName: string, ...): (boolean, any)
    local MAX_ATTEMPTS = 5

    local attemptCount = 0
    local success, result

    repeat
        attemptCount += 1
        print(("Calling '%s', attempt %d/%d"):format(functionName, attemptCount, MAX_ATTEMPTS))
        success, result = pcall(InsertService[functionName], InsertService, ...)
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
    local success, result

    success, result = attemptTask("GetLatestAssetVersionAsync", assetID)
    if not success then return end

    success, result = attemptTask("LoadAssetVersion", result)
    if not success then return end

    result = result:GetChildren()[1]
    result.Name = "[INSERTED] - " .. result.Name
    result.Parent = workspace --Util.mapModel:get(false)
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
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        Size = data.BoxSize,

        [OnEvent "Activated"] = function()
            attemptToInsertModel(data.AssetID)
        end,

        [Children] = {
            Components.Constraints.UICorner(0, 6),
            Components.Constraints.UIGradient(data.GradientColor, NumberSequence.new(0), 0),

            New "ImageLabel" {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.8, 1),
                Image = data.Image,
                ImageTransparency = 0.5
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 2,
                Text = data.Text,
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 16
            }
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
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 6), Enum.VerticalAlignment.Top),
                    HeaderText({Text = "Map Kits", LayoutOrder = 1, Tooltip = "Tooltip here"}),

                    New "Frame" {
                        BackgroundTransparency = 1,
                        Name = "MapKitFrame",
                        LayoutOrder = 2,
                        Size = UDim2.new(1, 0, -0.1, 180),
                        [Children] = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 8), Enum.VerticalAlignment.Top),
                            KitInsertButton({
                                BoxSize = UDim2.new(1, -24, 0, 64),
                                GradientColor = ColorSequence.new(Color3.fromRGB(255, 93, 0), Color3.fromRGB(255, 0, 230)),
                                Image = "rbxassetid://9441561539",
                                Text = "Official TRIA.OS Map Kit",
                                AssetID = 6404661021
                            })
                        }
                    },
                }
            }
        }
    }
end

return frame
