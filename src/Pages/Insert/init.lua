-- Copyright (C) 2026 TRIA
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. 
-- If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.

--< Package >--
local Package = script.Parent.Parent

--< Services >--
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

--< Imports >--
local Fusion = require(Package.Packages.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)
local MapComponents = require(script.MapComponents)
local SelectMap = require(Package.MapSelect)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

--< Variables >--
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues

local frame = {}


--< Main >--

local function attemptToInsertModel(assetID: number)
    if assetID == 0 then
        return
    end

    local result = nil
    local success = pcall(function()
        result = game:GetObjects(`rbxassetid://{assetID}`)
    end)

    if not success or not result or #result == 0 then 
        Util:ShowMessage("Unable to Insert Model", "Roblox failed to insert the model, please try again. If this continues, try purchasing the MapKit from the TRIA group in the Toolbox.")
        return
    end

    result = result[1]
    local recording = ChangeHistoryService:TryBeginRecording("insertPluginResource", string.format('Inserted model "%s"', result.Name))

    if recording then
        Util.debugWarn(("Successfuly inserted %s!"):format(result.Name))
        result.Name = "[INSERTED] - " .. result.Name

        local _Pos, Size = result:GetBoundingBox()
        local XYPosition = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -Size.Magnitude * 1.125 + 20) ).Position * Vector3.new(1, 0, 1)
        local RaycastResult = workspace:Raycast(XYPosition + Vector3.new(0, 30, 0), Vector3.new(0, -60, 0), RaycastParams.new())
        local NewPos = XYPosition + Vector3.new(0, RaycastResult and RaycastResult.Position.Y or workspace.CurrentCamera.CFrame.Position.Y, 0)

        result:PivotTo(CFrame.new(NewPos))
        Selection:Set({result})

        if not SelectMap:AutoSelect(true) then
            result.Parent = workspace
            SelectMap:SetMap(result)
        else
            result.Parent = workspace
        end

        for _, thing in pairs(result:GetDescendants()) do
            thing.Sandboxed = false
        end

        ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
    end
end

local function GetAssetButton(data: PublicTypes.Dictionary): Instance
    local imageColor = Value(Color3.new(1, 1, 1))

    return Components.ImageButton {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = data.BackgroundColor or Color3.new(1, 1, 1),
        BackgroundTransparency = data.FullSize and 1 or 0,
        LayoutOrder = data.LayoutOrder or 2,
        Size = UDim2.new(1, -16, 0, data.FullSize and 95 or 80),

        [OnEvent "MouseButton1Down"] = function()
            if data.FullSize and not Util.interfaceActive:get(false) then
                return
            end
            if imageColor:get(false) == Color3.new(0.8, 0.8, 0.8) then
                imageColor:set(Color3.new(0.99,0.99,0.99))
            end
        end,
        [OnEvent "MouseButton1Up"] = function()
            if data.FullSize and not Util.interfaceActive:get(false) then
                return
            end
            if imageColor:get(false) ~= Color3.new(1, 1, 1) then
                imageColor:set(Color3.new(0.8,0.8,0.8))
            end
        end,

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
                    if data.FullSize and not Util.interfaceActive:get(false) then
                        return
                    end
                    if imageColor:get(false) == Color3.new(1, 1, 1) then
                        imageColor:set(Color3.new(0.8, 0.8, 0.8))
                    end
                end,
                [OnEvent "MouseLeave"] = function()
                    if data.FullSize and not Util.interfaceActive:get(false) then
                        return
                    end
                    if imageColor:get(false) ~= Color3.new(1, 1, 1) then
                        imageColor:set(Color3.new(1, 1, 1))
                    end
                end,

                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ImageColor3 = Computed(function(): Color3
                    return data.FullSize and imageColor:get() or Color3.new(1, 1, 1)
                end),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(data.FullSize and 1 or 0.8, 1),
                Image = data.OverlayImage,
                ImageTransparency = data.OverlayImageTransparency,
                ScaleType = data.ImageCrop,

                [Children] = Components.Constraints.UICorner(0, 6),
            },

            New "TextLabel" {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
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
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
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

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "Insert",

        [Children] = {
            Components.PageHeader("Map Resources"),
            Components.ScrollingFrame ({
                BackgroundColor3 = Theme.TableItem.Default,
                BackgroundTransparency = 0,
                ClipsDescendants = true,
                Size = UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, nil, Enum.VerticalAlignment.Top),
                    Components.FrameHeader("Map Kits", 1, nil, nil, "Get the TRIA.os Map Kit here to start making maps!"),
                    Components.Spacer(false, 1, 6, nil),

                    New "Frame" {
                        LayoutOrder = 2,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = Theme.TableItem.Default,

                        [Children] = {

                            Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 8)),

                            GetAssetButton {
                                ModelId = 93671903447129,
                                LayoutOrder = 2,
                                BackgroundGradient = ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(195, 0, 133)),
                                OverlayImage = "rbxassetid://80938683090696",
                                OverlayImageTransparency = 0.5,
                                ZIndex = 5,
                                Name = "TRIA.os Map Kit",
                                Creator = "TRIA",
                                ImageCrop = Enum.ScaleType.Crop,
                                Tooltip = {
                                    Header = "Map Kit",
                                    Tooltip = "The latest version of the TRIA.os MapKit",
                                }
                            },

                        }
                    },

                    Components.Spacer(false, 3, 6, nil),
                    New "Frame" {
                        LayoutOrder = 7,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundColor3 = Theme.TableItem.Default,

                        [Children] = {
                            Components.Constraints.UIListLayout(),
                            Components.FrameHeader("Map Components", 3, nil, nil, "These are common map components which can be found in most maps.", 2),
                            New "Frame" {
                                Size = UDim2.new(1, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                LayoutOrder = 4,
                                BackgroundTransparency = 1,
                                
                                [Children] = {
                                    Components.GradientTextLabel(Computed(function(): boolean
                                        return Util.mapModel:get() == nil
                                    end), {
                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                        Position = UDim2.fromScale(0.5, 0.5),
                                        Size = UDim2.fromScale(1, 1),
                                        Text = "Select a map to continue.",
                                        ZIndex = 5,
                                    }),

                                    New "Frame" {
                                        Size = UDim2.fromScale(1, 1),
                                        BackgroundTransparency = 1,
                                        AutomaticSize = Enum.AutomaticSize.Y,

                                        [Children] = {
                                            Components.Constraints.UIListLayout(),
                                            ForValues(MapComponents.Components, function(data: PublicTypes.Dictionary): Instance
                                                return Components.TextButton {
                                                    Active = Util.interfaceActive,
                                                    AutoButtonColor = Util.interfaceActive,
                                                    Size = UDim2.new(1, 0, 0, 30),
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
                                                        else
                                                            Util:ShowMessage("Cannot insert map components", "Please select a map to continue inserting map components. \n\nHowever, you can insert a map kit whenever!")
                                                        end
                                                    end,
                
                                                    [Children] = {
                                                        Components.Constraints.UIPadding(nil, nil, UDim.new(0, 34)),
                                                        New "ImageLabel" {
                                                            Image = data.Icon,
                                                            Size = UDim2.new(0, 26, 0, 26),
                                                            AnchorPoint = Vector2.new(1, 0.5),
                                                            Position = UDim2.new(0, -4, 0.5, 0),
                                                            BackgroundColor3 = Theme.InputFieldBackground.Default,
                                                        },
                                                        Components.TooltipImage {
                                                            Position = UDim2.new(1, -4, 0, 7),
                                                            Header = data.Tooltip.Header,
                                                            Tooltip = data.Tooltip.Tooltip,
                                                        }
                                                    }
                                                }
                                            end, Fusion.cleanup)
                                        }
                                    }
                                },
                            },
                            Components.Spacer(false, 6, 45, 1)
                        }
                    },
                }
            }, true)
        }
    }
end

function frame.OnClose()
end


return frame
