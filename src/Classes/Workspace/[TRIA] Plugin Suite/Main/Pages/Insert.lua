
local InsertService = game:GetService("InsertService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed

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

function SubFrame(data: PublicTypes.propertiesTable): Instance
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

function frame:GetFrame(data: PublicTypes.propertiesTable): Instance
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
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 6), Enum.VerticalAlignment.Top),
                    Components.FrameHeader("Map Kits", 1, nil, nil, "Toolttip  Here"),

                    Components.ImageButton {
                        BackgroundColor3 = data.BackgroundColor or Color3.new(1, 1, 1),
                        BackgroundTransparency = 0,
                        LayoutOrder = 2,
                        Size = UDim2.new(1, -24, 0, 84),
                
                        [OnEvent "Activated"] = function()
                            attemptToInsertModel(6404661021)
                        end,
                
                        [Children] = {
                            Components.Constraints.UICorner(0, 6),
                            Components.Constraints.UIGradient(ColorSequence.new(Color3.fromRGB(255, 100, 0), Color3.fromRGB(195, 0, 133)), nil, nil),
                
                            New "ImageLabel" {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.8, 1),
                                Image = "rbxassetid://9441561539",
                                ImageTransparency = 0.5,
                                ScaleType = Enum.ScaleType.Crop
                            },
                
                            New "TextLabel" {
                                AnchorPoint = Vector2.new(0, 1),
                                BackgroundTransparency = 1,
                                FontFace = Font.new("SourceSansPro", Enum.FontWeight.Bold),
                                Position = UDim2.fromScale(0, 1),
                                Size = UDim2.new(1, 0, 0, 24),
                                Text = "Official TRIA.OS Map Kit",
                                TextColor3 = Theme.BrightText.Default,
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
                                TextColor3 = Theme.BrightText.Default,
                                TextSize = 12,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                
                                Visible = Computed(function()
                                    return data.Creator ~= nil
                                end):get()
                            }
                        }
                    },

                    Components.FrameHeader("Map Components", 6, nil, nil, "Toolttip  Here")
                }
            }, true)
        }
    }
end

return frame
