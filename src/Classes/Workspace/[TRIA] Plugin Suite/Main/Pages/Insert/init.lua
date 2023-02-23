local InsertService = game:GetService("InsertService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Selection = game:GetService("Selection")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local MapComponents = require(script.MapComponents)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues

local frame = {}

local function attemptTask(service: Instance, functionName: string, ...): (boolean, any)
    local MAX_ATTEMPTS = 5

    local attemptCount = 0
    local success, result

    repeat
        attemptCount += 1
        Util.debugWarn(("Calling '%s', attempt %d/%d"):format(functionName, attemptCount, MAX_ATTEMPTS))
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
    ChangeHistoryService:SetWaypoint("Inserted model \"" .. result.Name .. "\"")
end

function SubFrame(data: PublicTypes.dictionary): Instance
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

local function GetAssetButton(data: PublicTypes.dictionary): Instance
    local imageColor = Value(Color3.new(1, 1, 1))

    return Components.ImageButton {
        BackgroundColor3 = data.BackgroundColor or Color3.new(1, 1, 1),
        BackgroundTransparency = data.FullSize and 1 or 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, -24, 0, 95),
        ScaleType = data.ImageCrop,

        [OnEvent "Activated"] = function()
            if data.ActivatedFunction then
                data.ActivatedFunction()
            else
                attemptToInsertModel(data.ModelId)
            end
        end,

        [Children] = {
            Components.Constraints.UICorner(0, 6),
            Components.Constraints.UIGradient(data.BackgroundGradient, nil, nil),

            New "ImageLabel" {
                [OnEvent "MouseEnter"] = function()
                    if imageColor:get(false) == Color3.new(1, 1, 1) then
                        imageColor:set(Color3.new(.875, .875, .875))
                    end
                end,
                [OnEvent "MouseLeave"] = function()
                    if imageColor:get(false) == Color3.new(.875, .875, .875) then
                        imageColor:set(Color3.new(1, 1, 1))
                    end
                end,

                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = Computed(function()
                    return data.FullSize and imageColor:get() or Color3.new(1, 1, 1)
                end),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(data.FullSize and 1 or 0.8, 1),
                Image = data.OverlayImage,
                ImageTransparency = data.OverlayImageTransparency,

                [Children] = Components.Constraints.UICorner(0, 6),
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                Position = UDim2.fromScale(0, data.FullSize and 1.05 or 1),
                Size = UDim2.new(1, 0, 0, 24),
                Text = data.Name,
                TextColor3 = Theme.BrightText.Default,
                TextSize = not data.FullSize and 18 or 16,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextStrokeTransparency = 0.5
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, data.FullSize and 0 or 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                Position = UDim2.fromScale(0, data.FullSize and 0.1 or 0.65),
                Size = UDim2.new(1, 0, -0.325, 24),
                Text = "by " .. tostring(data.Creator),
                TextColor3 = Theme.BrightText.Default,
                TextSize = not data.FullSize and 14 or 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextStrokeTransparency = 0.5
            },

            Components.TooltipImage {
                Position = UDim2.new(1, -4, 1, -36),
                Tooltip = data.Tooltip.Tooltip,
                Header = data.Tooltip.Header
            }
        }
    }
end

function frame:GetFrame(data: PublicTypes.dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Insert",

        [Children] = {
            Components.PageHeader("Map Addons, Kits, & Components"),
            Components.ScrollingFrame ({
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 0,
                ClipsDescendants = true,
                Size = UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 6), Enum.VerticalAlignment.Top),
                    Components.FrameHeader("Map Kits", 1, nil, nil, "Here you can insert Map kits which can help you get started on making a map!"),

                    GetAssetButton {
                        ModelId = 6404661021,
                        BackgroundGradient = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(195, 0, 133)),
                        OverlayImage = "rbxassetid://12537133710",
                        OverlayImageTransparency = 0.5,
                        Name = "Official TRIA.OS Map Kit",
                        Creator = "TRIA",
                        Tooltip = {}
                    },

                    New "Frame" {
                        LayoutOrder = 7,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            Components.FrameHeader("Featured Map Addons", -2, nil, nil, "Featured assets created by the community for use in mapmaking.", 2),
                            New "Frame" {
                                Size = UDim2.new(1, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                LayoutOrder = -1,
                                BackgroundTransparency = 1,

                                [Children] = {
                                    Components.Constraints.UIGridLayout(UDim2.new(0, 140, 0, 79), UDim2.new(0, 6, 0, 6), Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center),
                                    Components.Constraints.UIPadding(UDim.new(0, 6), UDim.new(0, 6)),
                                    ForValues(MapComponents.Addons, function(data: PublicTypes.dictionary): Instance
                                        return GetAssetButton {
                                            OverlayImage = data.Icon,
                                            OverlayImageTransparency = 0,
                                            Name = data.Name,
                                            Creator = data.Creator,
                                            FullSize = true,
                                            Tooltip = data.Tooltip,
                                            ActivatedFunction = data.InsertFunction,
                                            LayoutOrder = data.LayoutOrder,
                                        }
                                    end, Fusion.Cleanup)
                                },
                            },
                            Components.FrameHeader("Map Components", 0, nil, nil, "These are common map components which can be found in most maps.", 2),
                            ForValues(MapComponents.Components, function(data: PublicTypes.dictionary): Instance
                                return Components.TextButton {
                                    Size = UDim2.new(1, 0, 0, 32),
                                    LayoutOrder = data.LayoutOrder,
                                    Text = " " .. data.Name,
                                    TextSize = 17,
                                    BorderSizePixel = 0,
                                    TextColor3 = Theme.BrightText.Default,
                                    Font = Enum.Font.SourceSansSemibold,
                                    TextXAlignment = Enum.TextXAlignment.Left,
        
                                    [OnEvent "Activated"] = function()
                                        if Util.mapModel:get(false) then
                                            data.InsertFunction()
                                        end
                                    end,

                                    [Children] = {
                                        Components.Constraints.UIPadding(nil, nil, UDim.new(0, 34)),
                                        New "ImageLabel" {
                                            Image = data.Icon,
                                            Size = UDim2.new(0, 28, 0, 28),
                                            AnchorPoint = Vector2.new(1, .5),
                                            Position = UDim2.new(0, -4, .5, 0),
                                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                                        },
                                        Components.TooltipImage({
                                            Position = UDim2.new(1, -4, 0, 9),
                                            Header = data.Tooltip.Header,
                                            Tooltip = data.Tooltip.Tooltip,
                                        })
                                    }
                                }
                            end, Fusion.Cleanup)
                        }
                    }
                }
            }, true)
        }
    }
end

return frame
