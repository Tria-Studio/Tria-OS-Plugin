local InsertService = game:GetService("InsertService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local MapComponents = require(script.MapComponents)
local SelectMap = require(Package.MapSelect)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local Out = Fusion.Out

local frame = {}

local function attemptTask(service: Instance, functionName: string, ...): (boolean, any)
    local MAX_ATTEMPTS = 5

    local attemptCount = 0
    local success, result

    repeat
        attemptCount += 1
        success, result = pcall(service[functionName], service, ...)
        if success then
            break
        end
        task.wait(0.75)
    until attemptCount >= MAX_ATTEMPTS

    if not success then
        Util.debugWarn(("Process '%s' failed after %d attempt(s)"):format(functionName, MAX_ATTEMPTS))
    end
    return success, result
end

local function attemptToInsertModel(assetID: number)
    if assetID == 0 then
        return
    end
    local success, result

    success, result = attemptTask(InsertService, "GetLatestAssetVersionAsync", assetID)
    if not success then return end


    if script.Mapkits:FindFirstChild(result) then
        success = true
        local clone = script.Mapkits:FindFirstChild(result):Clone()
        result = Instance.new("Model")
        clone.Parent = result
        clone.Name = "1.0 MapKit"
        for _, thing in pairs(clone:GetChildren()) do
            if thing:IsA("LuaSourceContainer") then
                thing.Enabled = true
            end
        end
    else
        success, result = attemptTask(InsertService, "LoadAssetVersion", result)
    end
   
    if not success then 
        Util:ShowMessage("Unable to Insert Model", "Roblox failed to insert the model, please try again.")
        return
    end

    local recording = ChangeHistoryService:TryBeginRecording("insertPluginResource", string.format('Inserted model "%s"', result.Name))

    if recording then
        
        result = result:GetChildren()[1]
        Util.debugWarn(("Successfuly inserted %s!"):format(result.Name))
        result.Name = "[INSERTED] - " .. result.Name

        local Pos, Size = result:GetBoundingBox()
        local XYPosition = (workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -Size.Magnitude * 1.125 + 20) ).Position * Vector3.new(1, 0, 1)
        local RaycastResult = workspace:Raycast(XYPosition + Vector3.new(0, 30, 0), Vector3.new(0, -60, 0), RaycastParams.new())
        local NewPos = XYPosition + Vector3.new(0, RaycastResult and RaycastResult.Position.Y or workspace.CurrentCamera.CFrame.Position.Y, 0)

        result:PivotTo(CFrame.new(NewPos))
        Selection:Set({result})

        if assetID == 6404661021 and not SelectMap:AutoSelect(true) then
            result.Parent = workspace
            SelectMap:SetMap(result)
        else
            result.Parent = workspace
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
    local AddonFrameSize = Value()

    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "Insert",

        [Children] = {
            Components.PageHeader("Resources & Addons"),
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
                                ModelId = 103809693584842,
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
                            -- Components.FrameHeader("Featured Map Addons", 1, nil, nil, "Featured assets created by the community for use in mapmaking.", 2),
                            New "Frame" {
                                [Out "AbsoluteSize"] = AddonFrameSize,
                                Size = UDim2.new(1, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                LayoutOrder = 2,
                                BackgroundTransparency = 1,
                                
                                [Children] = {
                                    New "Frame" {
                                        Size = UDim2.fromScale(1, 1),
                                        BackgroundTransparency = 1,
                                        AutomaticSize = Enum.AutomaticSize.Y,

                                        [Children] = {
                                            Components.Constraints.UIGridLayout(UDim2.new(0, 140, 0, 79), UDim2.new(0, 6, 0, 6), Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center),
                                            Components.Constraints.UIPadding(UDim.new(0, 6), UDim.new(0, 6)),
                                            ForValues(MapComponents.Addons, function(data: PublicTypes.Dictionary): Instance
                                                return GetAssetButton {
                                                    OverlayImage = data.Icon,
                                                    OverlayImageTransparency = 0,
                                                    Name = data.Name,
                                                    Creator = data.Creator,
                                                    FullSize = true,
                                                    Tooltip = data.Tooltip,
                                                    ActivatedFunction = function()
                                                        if Util.mapModel:get(false) then
                                                            data.InsertFunction()
                                                        else
                                                            Util:ShowMessage("Cannot insert map addons", "Please select a map to continue inserting map addons. \n\nHowever, you can insert a map kit whenever!")
                                                        end
                                                    end,
                                                    LayoutOrder = data.LayoutOrder,
                                                }
                                            end, Fusion.cleanup)
                                        }
                                    }
                                },
                            },
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

local function updateMapScriptChildren()
    local newValues = {
        Waterjets = false,
    }

    local currentMap = Util.mapModel:get(false)
    for i, thing in pairs(currentMap and currentMap.MapScript:GetChildren() or {}) do
        if thing:IsA("ModuleScript") then
            local addons = {}

            function addons.Waterjets(): boolean
                local success, module = pcall(function()
                    return thing.Name == "Waterjets" and require(thing)
                end)
                return success and module and module.SetFanEnabled == 0 and thing:FindFirstChild("WaterjetClient")
            end

            if addons[thing.Name] then
                newValues[thing.Name] = addons[thing.Name]()
            end
        end
    end

    if Util._Addons.hasWaterjet:get() and not newValues.Waterjets then
        Util._Addons.AddonRemoved:Fire("_Waterjet")
    end
    Util._Addons.hasWaterjet:set(newValues.Waterjets)
    Util._Addons.hasAddonsWithObjectTags:set(newValues.Waterjets)
end

function frame.OnClose()
    updateMapScriptChildren()
end

Util.MapChanged:Connect(function()
    local currentMap = Util.mapModel:get(false)
    if currentMap then
        task.wait()
        Util.MapMaid:GiveTask(currentMap.MapScript.ChildAdded:Connect(updateMapScriptChildren))
        Util.MapMaid:GiveTask(currentMap.MapScript.ChildRemoved:Connect(updateMapScriptChildren))
        updateMapScriptChildren()
    end
end)

return frame
