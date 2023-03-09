local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)
local Util = require(Package.Util)
local PlguinSoundManager = require(Package.Util.PluginSoundManager)
local GitUtil = require(Package.GitUtil)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Ref = Fusion.Ref
local Observer = Fusion.Observer
local Spring = Fusion.Spring

local frame = {}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local AbsSize = Value()
local ITEMS_PER_PAGE = Computed(function()
    return AbsSize:get() and math.floor((AbsSize:get().Y + 32) / 40) or 12
end)
local CURRENT_PAGE_COUNT = Value(0)
local TOTAL_PAGE_COUNT = Value(0)

local CURRENT_FETCH_STATUS = Value("Fetching")

local FETCHED_AUDIO_DATA = Value({})
local CURRENT_AUDIO_DATA = Value({})

local STATUS_ERRORS = {
    ["Fetching"] = "Currently fetching the latest audio...",
    ["HTTPDisabled"] = "Failed to fetch audio library due to HTTP requests being disabled. You can change this in the \"Plugin Settings\" tab.",
    ["HTTPError"] = "A network error occured while trying to get the latest audio. Please try again later.",
    ["JSONDecodeError"] = "A JSON Decoding error occured, please report this to the plugin developers as this needs to be manually fixed."
}

local currentAudio = Value(nil)

local lastFetchTime = 0
local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local oldUniverseId = game.GameId
local oldPlaceId = game.PlaceId

local function toggleAudioPerms(enabled: boolean)
    game:SetUniverseId(enabled and 2330396164 or oldUniverseId) 
    game:SetPlaceId(enabled and 6311279644 or oldPlaceId)
end

local function fade(sound: Sound, direction: string)
    local tween = TweenService:Create(sound, fadeInfo, {Volume = (direction == "In" and 1 or 0)})
    tween:Play()

    if direction == "Out" then
        tween.Completed:Connect(function()
            sound:Stop()
        end)
    end
end

local function AudioButton(data: PublicTypes.Dictionary, holder): Instance
    local timePosition = Value(0)

    local previewSound = PlguinSoundManager:QueueSound(data.ID)
    previewSound.Name = data.Name

    local soundLength = Value(1)
    local isPlaying = false

    previewSound.Loaded:Connect(function()
        soundLength:set(previewSound.TimeLength)
    end)
    previewSound.Resumed:Connect(function()
        isPlaying = true
    end)
    previewSound.Paused:Connect(function()
        isPlaying = false
    end)
    previewSound.Stopped:Connect(function()
        timePosition:set(0)
        isPlaying = false
    end)
    previewSound.Ended:Connect(function()
        timePosition:set(0)
        currentAudio:set(nil)
        isPlaying = false
    end)

    RunService.Heartbeat:Connect(function(deltaTime)
        if 
            isPlaying 
            and previewSound.IsLoaded 
            and previewSound == currentAudio:get(false) 
            and not Util._Slider.isUsingSlider:get(false) 
        then
            timePosition:set(timePosition:get(false) + deltaTime)
        end
    end)

    Observer(timePosition):onChange(function()
        if Util._Slider.isUsingSlider:get(false) then
            previewSound.TimePosition = timePosition:get(false)
        end
    end)

    return New "Frame" {
        BackgroundColor3 = Theme.CategoryItem.Default,
        Size = Computed(function()
            return UDim2.new(1, 0, 0, 36)
        end),
        
        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.4, 1),
                Position = UDim2.fromScale(.005, 0),
                Text = ("<b>%s</b>\n%s"):format(data.Artist, data.Name),
                TextColor3 = Theme.MainText.Default,
                LineHeight = 1.1,
                RichText = true,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), nil)
            },

            Components.TextButton {
                Size = UDim2.new(0, 32, 0.6, 0),
                Position = UDim2.new(1, -8, 0.5, 0),
                AnchorPoint = Vector2.new(1, .5),
                Text = "Use",
                Font = Enum.Font.SourceSansBold,
                BackgroundColor3 = Theme.MainButton.Default,
                TextSize = 15,
                TextColor3 = Theme.BrightText.Default,

                [Children] = {
                    Components.Constraints.UICorner(0, 6),
                    Components.Constraints.UIPadding(UDim.new(0, 2), UDim.new(0, 2), UDim.new(0, 2), UDim.new(0, 2))
                },

                [OnEvent "Activated"] = function()
                    Util:ShowMessage("Update map BGM?", "This will update the map BGM to '" .. ("%s - %s"):format(data.Artist, data.Name) .. "', press 'Update' to confirm.", {
                        Text = "Update",
                        Callback = function()
                            Util.debugWarn("Updated map music!")
                            Util.updateMapSetting("Main", "Music", data.ID)
                            ChangeHistoryService:SetWaypoint("Updated map music")
                        end
                    })
                end
            },

            New "Frame" {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.425, 0.8),
                Position = UDim2.new(0.7, 0, 0.2, 0),

                [Children] = {
                    Components.Slider {
                        Value = timePosition,
                        Min = Value(0),
                        Max = soundLength,
                        Position = UDim2.fromScale(0.5, 0.225),
                        Size = UDim2.fromScale(0.7, 0.25),
                        Increment = 1,
                    },

                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.15, 0, 0.5, 1),
                        Size = UDim2.fromScale(0.7, 0.25),
                        TextSize = 14,
                        Text = Computed(function()
                            return Util.secondsToTime(timePosition:get()) .. "/" .. Util.secondsToTime(soundLength:get())
                        end),
                        TextColor3 = Theme.MainText.Default,
                    },

                    New "ImageButton" {
                        Image = Computed(function()
                            return currentAudio:get() == previewSound and "rbxassetid://6026663701" or "rbxassetid://6026663726"
                        end),
                        HoverImage = Computed(function()
                            return currentAudio:get() == previewSound and "rbxassetid://6026663718" or "rbxassetid://6026663705"
                        end),
                        BackgroundTransparency = 1,
                        ImageColor3 = Computed(function()
                            return currentAudio:get() == previewSound and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                        end),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(-.01, 0.175),
                        Size = UDim2.fromScale(0.7, 0.7),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        
                        [Children] = Components.Constraints.UICorner(1, 0),
                        [OnEvent "Activated"] = function()
                            local playing = currentAudio:get(false)
                            if playing ~= previewSound then
                                if playing then
                                    fade(playing, "Out")
                                end

                                previewSound.Volume = 0
                                previewSound.TimePosition = timePosition:get(false)
                                previewSound:Resume()
                                currentAudio:set(previewSound)
                                fade(previewSound, "In")
                            else
                                if not playing then
                                    return
                                end
                                playing:Pause()
                                currentAudio:set(nil)
                            end
                        end
                    },
                }
            }
        }
    }
end

local function getAudioChildren(): {Instance}
    local children = {}

    local assets = CURRENT_AUDIO_DATA:get()
    local itemsPerPage = ITEMS_PER_PAGE:get()

    local totalAssets = #assets
    local totalPages = math.ceil(totalAssets / itemsPerPage)

    local assetsRemaining = totalAssets

    for index = 1, totalPages do
        local pageAssetCount = assetsRemaining > itemsPerPage and itemsPerPage or assetsRemaining

		local startIndex = ((index - 1) * itemsPerPage) + 1
		local endIndex = (startIndex + pageAssetCount) - 1

        table.insert(children, New "Frame" {
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, nil, UDim.new(0, 4)),
                (function()
                    local pageChildren = {}
                    for count = startIndex, endIndex do
                        table.insert(pageChildren, AudioButton(assets[count]))
                    end
                    return pageChildren
                end)()
            }
        })

        assetsRemaining -= itemsPerPage
    end

    TOTAL_PAGE_COUNT:set(totalPages)
    return children
end

local function fetchApi()
    if os.clock() - lastFetchTime < 120 and CURRENT_FETCH_STATUS:get(false) == "Success" then
        return;
    end
    
    lastFetchTime = os.clock()
    CURRENT_FETCH_STATUS:set("Fetching")
    task.wait(0.5)

    local fired, result, errorCode, errorDetails = GitUtil:Fetch(URL)
    
    CURRENT_FETCH_STATUS:set(if not fired then errorCode else "Success")
    
    if fired then
        local newData = {}

        for key, tbl in pairs(result) do
            table.insert(newData, {
                ["Name"] = tbl.name or "N/A", 
                ["ID"] = tbl.id or 0, 
                ["Artist"] = tbl.artist or "N/A"
            })
        end

        table.sort(newData, function(a, b)
            if a.Artist:lower() == b.Artist:lower() then
                return a.Name:lower() < b.Name:lower()
            else
                return a.Artist:lower() < b.Artist:lower()
            end
        end)

        CURRENT_PAGE_COUNT:set(#newData > 0 and 1 or 0)
        FETCHED_AUDIO_DATA:set(newData)
        CURRENT_AUDIO_DATA:set(newData)
    end
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local pageLayout = Value()
    
    local LeftSpring
    
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library"),
            New "TextBox" {
                Size = UDim2.new(1, 0, 0, 30),
                TextColor3 = Theme.MainText.Default,
                Font = Enum.Font.SourceSansSemibold,
                PlaceholderColor3 = Theme.DimmedText.Default,
                PlaceholderText = "Search Artist & Titles",
                BackgroundColor3 = Theme.InputFieldBackground.Default,
                BorderColor3 = Theme.InputFieldBorder.Default,
                BorderMode = Enum.BorderMode.Inset,
                BorderSizePixel = 2,

                [Children] = {
                    Components.Constraints.UIPadding(nil, nil, nil, UDim.new(0, 30)),
                    New "ImageButton" {
                        Image = "rbxassetid://6031154871",
                        BackgroundTransparency = 1,
                        ImageColor3 = Theme.SubText.Default,
                        ZIndex = 2,
                        Size = UDim2.fromOffset(30, 30),
                        Position = UDim2.new(1, 0, 0, 0)
                    }
                }
            },
            New "Frame" { -- Page Cycler
                BackgroundColor3 = Theme.RibbonTab.Default,
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(1, 0, 0, 36),
                Position = UDim2.fromScale(0, 1),

                [Children] = {
                    Components.ImageButton { -- Skip to first page
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Active = Util.interfaceActive,
                        BackgroundTransparency = 1,
                        LayoutOrder = 1,
                        ImageColor3 = Computed(function()
                            return CURRENT_PAGE_COUNT:get() == 1 and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Image = "rbxassetid://4458877936",
                        Rotation = 180,
                        Position = UDim2.fromScale(0.1, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),
                        
                        [Children] = Components.Constraints.UIAspectRatio(1),
                        [OnEvent "Activated"] = function()
                            pageLayout:get(false):JumpToIndex(0)
                            CURRENT_PAGE_COUNT:set(1)
                        end
                    },
                    
                    Components.ImageButton { -- Skip one page left
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Active = Util.interfaceActive,
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://6031094687",
                        LayoutOrder = 2,
                        Rotation = 90,
                        ImageColor3 = Computed(function()
                            return CURRENT_PAGE_COUNT:get() == 1 and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Position = UDim2.fromScale(0.3, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),

                        [Children] = Components.Constraints.UIAspectRatio(1),
                        [OnEvent "Activated"] = function()
                            local currentPage = CURRENT_PAGE_COUNT:get(false)

                            if currentPage - 1 >= 1 then
                                pageLayout:get(false):Previous()
                                CURRENT_PAGE_COUNT:set((currentPage - 1))
                            end
                        end
                    },
                    
                    New "TextLabel" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        LayoutOrder = 3,
                        Text = Computed(function()
                            return ("Page %d/%d"):format(CURRENT_PAGE_COUNT:get(), TOTAL_PAGE_COUNT:get())
                        end),
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextSize = 16,
                        Font = Enum.Font.SourceSansSemibold,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),
                    },

                    Components.ImageButton { -- Skip one page right
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Active = Util.interfaceActive,
                        BackgroundTransparency = 1,
                        LayoutOrder = 4,
                        Image = "rbxassetid://6031094687",
                        ImageColor3 = Computed(function()
                            return CURRENT_PAGE_COUNT:get() == TOTAL_PAGE_COUNT:get() and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Rotation = -90,
                        Position = UDim2.fromScale(0.7, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),

                        [Children] = Components.Constraints.UIAspectRatio(1),
                        [OnEvent "Activated"] = function()
                            local currentPage = CURRENT_PAGE_COUNT:get(false)

                            if currentPage + 1 <= TOTAL_PAGE_COUNT:get(false) then
                                pageLayout:get(false):Next()
                                CURRENT_PAGE_COUNT:set(currentPage + 1)
                            end
                        end
                    },

                    Components.ImageButton { -- Skip to end page
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Active = Util.interfaceActive,
                        BackgroundTransparency = 1,
                        LayoutOrder = 5,
                        Image = "rbxassetid://4458877936",
                        Position = UDim2.fromScale(0.9, 0.5),
                        ImageColor3 = Computed(function()
                            return CURRENT_PAGE_COUNT:get() == TOTAL_PAGE_COUNT:get() and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Size = UDim2.new(0.2, -5, 1, -5),

                        [Children] = Components.Constraints.UIAspectRatio(1),
                        [OnEvent "Activated"] = function()
                            pageLayout:get(false):JumpToIndex(TOTAL_PAGE_COUNT:get(false) - 1)
                            CURRENT_PAGE_COUNT:set(TOTAL_PAGE_COUNT:get(false))
                        end
                    },

                    New "Frame" { -- Line
                        BackgroundColor3 = Theme.Border.Default,
                        Position = UDim2.new(0, 0, 0, -2),
                        Size = UDim2.new(1, 0, 0, 2)
                    },
                }
            },

            New "Frame" { -- Holder
                BackgroundColor3 = Theme.TableItem.Default,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 1, -68),
                LayoutOrder = 2,

                [Children] = {
                    New "Frame" { -- Status Message
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.95),
                        Visible = Computed(function()
                            return CURRENT_FETCH_STATUS:get() ~= "Success"
                        end),

                        [Children] = {
                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, UDim.new(0, 2), Enum.VerticalAlignment.Center),
                            New "ImageLabel" {
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(24, 24),
                                Image = "rbxasset://textures/ui/ErrorIcon.png",
                            },
                            New "TextLabel" {
                                AutomaticSize = Enum.AutomaticSize.Y,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(0.75, 0),
                                Text = Computed(function()
                                    local fetchStatus = CURRENT_FETCH_STATUS:get()
                                    return STATUS_ERRORS[fetchStatus] or "N/A"
                                end),
                                TextSize = 18,
                                TextWrapped = true,
                                TextColor3 = Theme.SubText.Default,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                TextYAlignment = Enum.TextYAlignment.Top
                            },
                            Components.TextButton {
                                Active = Util.interfaceActive,
                                Size = UDim2.fromScale(0.5, 0.05),
                                BackgroundColor3 = Theme.Button.Default,
                                Text = "Retry",

                                [Children] = {
                                    Components.Constraints.UICorner(0, 8),
                                    Components.Constraints.UIStroke(1, Color3.new(), Enum.ApplyStrokeMode.Border)
                                },

                                [OnEvent "Activated"] = function()
                                    if not table.find({"Fetching", "Success"}, CURRENT_FETCH_STATUS:get(false)) then
                                        task.spawn(fetchApi)
                                    end
                                end
                            }
                        }
                    },

                    New "Frame" { -- Audio Library
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Visible = Computed(function()
                            return CURRENT_FETCH_STATUS:get() == "Success"
                        end),

                        [Children] = {
                            New "Frame" { -- Main
                                [Fusion.Out "AbsoluteSize"] = AbsSize, 

                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.925),

                                [Children] = {
                                    Hydrate(Components.Constraints.UIPageLayout(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, UDim.new(0, 4), Computed(function()
                                        return TOTAL_PAGE_COUNT:get() > 1
                                    end))) {
                                        [Ref] = pageLayout
                                    },

                                    Computed(getAudioChildren)
                                }
                            },
                        }
                    }
                }
            },
        }
    }
end

function frame.OnClose()
    task.spawn(fetchApi)
    local playing = currentAudio:get(false)
    if not playing then
        return
    end
    fade(playing, "Out")
    currentAudio:set(nil)
end

task.spawn(toggleAudioPerms, true)
task.spawn(fetchApi)
return frame
