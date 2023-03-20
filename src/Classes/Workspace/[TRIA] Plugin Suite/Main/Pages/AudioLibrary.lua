local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ContentProvider = game:GetService("ContentProvider")
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
local Out = Fusion.Out
local Cleanup = Fusion.Cleanup

local SoundMaid = Util.Maid.new()

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local frame = {}

local frameAbsoluteSize = Value()
local pageLayout = Value()

local searchData = {
    name = Value(""),
    artist = Value("")
}

local pageData = {
    current = Value(0),
    total = Value(0)
}

local currentSongData = {
    currentAudio = Value(nil),
    currentTween = Value(nil),

    songData = Value({Name = "", Artist = ""}),

    timePosition = Value(0),
    timeLength = Value(0)
}

local songLoadData = {
    loaded = Value(0),
    total = Value(1)
}

local loadedSongs = {}

local lastFetchTime = 0
local lastItemsPerPage = 0
local audioChildrenCache = {}

local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local ITEMS_PER_PAGE = Computed(function(): number
    return frameAbsoluteSize:get() and math.max(1, math.floor((frameAbsoluteSize:get().Y + 32) / 40)) or 12
end)

local CURRENT_FETCH_STATUS = Value("Fetching")
local FETCHED_AUDIO_DATA = Value({})
type audioTableFormat = {Name: string, Artist: string, ID: number}

local STATUS_ERRORS = {
    ["Fetching"] = "Currently fetching the latest audio...",
    ["HTTPDisabled"] = "Failed to fetch audio library due to HTTP requests being disabled. You can change this in the \"Plugin Settings\" tab.",
    ["HTTPError"] = "A network error occured while trying to get the latest audio. Please try again later.",
    ["JSONDecodeError"] = "A JSON Decoding error occured, please report this to the plugin developers as this needs to be manually fixed."
}

local PLAY_IMAGE = {
    normal = "rbxassetid://6026663726",
    hover = "rbxassetid://6026663705"
}

local PAUSE_IMAGE = {
    normal = "rbxassetid://6026663701",
    hover = "rbxassetid://6026663718"
}

local function fadeSound(sound: Sound, direction: string)
    if not sound then
        return
    end
    local tween = TweenService:Create(sound, fadeInfo, {Volume = (direction == "In" and 1 or 0)})
    tween:Play()
    currentSongData.currentTween:set(tween)

    if direction == "Out" then
        tween.Completed:Connect(function()
            if tween.PlaybackState ~= Enum.PlaybackState.Cancelled then
                sound:Stop()
            end
        end)
    end
end

local function jumpToPage(pageNumber: number)
    local newPage = math.clamp(pageNumber, 1, math.max(1, pageData.total:get(false)))
    local uiLayout = pageLayout:get(false)

    if uiLayout then
        uiLayout:JumpToIndex(newPage - 1)
        pageData.current:set(newPage)
    end
end

local function incrementPage(increment: number)
    jumpToPage(pageData.current:get(false) + increment)
end

local function stopSong()
    local currentlyPlaying = currentSongData.currentAudio:get(false)
    if not currentlyPlaying then
        return
    end
    fadeSound(currentlyPlaying, "Out")
    Util.toggleAudioPerms(false)
    currentSongData.currentAudio:set(nil)
end

local function pauseSong(soundData: audioTableFormat)
    local currentlyPlaying = currentSongData.currentAudio:get(false)
    if not currentlyPlaying then
        return
    end
    currentlyPlaying:Pause()
    currentSongData.currentAudio:set(currentlyPlaying, true)
end

local function resumeSong(soundData: audioTableFormat)
    local currentlyPlaying = currentSongData.currentAudio:get(false)
    if not currentlyPlaying then
        return
    end
    currentlyPlaying.Volume = 0
    currentlyPlaying:Resume()
    currentSongData.currentAudio:set(currentlyPlaying, true)
    fadeSound(currentlyPlaying, "In")
end

local function playSong(newSound: Sound, soundData: audioTableFormat)
    SoundMaid:DoCleaning()
    Util.toggleAudioPerms(true)
    newSound.SoundId = "rbxassetid://" .. soundData.ID
    SoundMaid:GiveTask(newSound)

    local function updateLoaded()
        loadedSongs[soundData.ID]:set(true)
        task.delay(1, function()
            Util.toggleAudioPerms(false)
        end)
    end

    if newSound.Loaded then
        updateLoaded()
    else
        SoundMaid:GiveTask(newSound.Loaded:Connect(updateLoaded))
    end

    newSound.Volume = 0
    newSound.TimePosition = 0
    newSound:Resume()
    fadeSound(newSound, "In")

    currentSongData.timePosition:set(0)
    currentSongData.songData:set(soundData)
    currentSongData.currentAudio:set(newSound)

    SoundMaid:GiveTask(newSound.Ended:Connect(function()
        currentSongData.timePosition:set(0)
        currentSongData.currentAudio:set(nil)
        Util._Slider.isUsingSlider:set(false)
    end))

    SoundMaid:GiveTask(newSound:GetPropertyChangedSignal("TimeLength"):Connect(function()
        currentSongData.timeLength:set(math.max(newSound.TimeLength, 0.1))
    end))
end

local function stopCurrentTween()
    local tween = currentSongData.currentTween:get(false)
    if tween then
        tween:Cancel()
        currentSongData.currentTween:set(nil)
    end
end

local function updatePlayingSound(newSound: Sound, soundData: audioTableFormat)
    local currentAudioData = currentSongData.songData:get(false)
    local currentAudio = currentSongData.currentAudio:get(false)

    if not currentAudio then -- No song playing
        stopCurrentTween()
        playSong(newSound, soundData)
    elseif currentAudioData.ID == soundData.ID then -- Song being paused/resumed
        if currentAudio.IsPaused then
            resumeSong(soundData)
        else
            pauseSong(soundData)
        end
    else -- Song switched while playing
        fadeSound(currentAudio, "Out")
        playSong(newSound, soundData)
    end
end

local function SongPlayButton(data: PublicTypes.Dictionary): Instance
    return Hydrate(Components.ImageButton {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 3,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        [Children] = Components.Constraints.UICorner(1, 0),
    })(data)
end

local function AudioButton(data: audioTableFormat): Instance
    local sound = PlguinSoundManager:CreateSound()

    local isSongPlaying = Computed(function(): boolean
        local currentSong = currentSongData.currentAudio:get()
        return currentSong and currentSong == sound and currentSong.IsPlaying 
    end)

    return New "Frame" {
        BackgroundColor3 = Theme.CategoryItem.Default,
        Size = UDim2.new(1, 0, 0, 36),

        Visible = Computed(function(): boolean
            local searchedArtist = searchData.artist:get()
            local searchedName = searchData.name:get()
            
            return 
                if searchedArtist and #searchedArtist > 0 then data.Artist:lower():find(searchedArtist:lower()) ~= nil
                elseif searchedName and #searchedName > 0 then data.Name:lower():find(searchedName:lower()) ~= nil
                else true
        end),

        [Cleanup] = sound,

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.4, 1),
                Position = UDim2.fromScale(0.005, 0),
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
                AnchorPoint = Vector2.new(1, 0.5),
                Text = "Use",
                ZIndex = 3,
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
                    SongPlayButton {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -15, 0.35, 0),
                        Size = UDim2.fromScale(0.7, 0.7),
                        Image = Computed(function(): string
                            return isSongPlaying:get() and PAUSE_IMAGE.normal or PLAY_IMAGE.normal
                        end),
                        ImageColor3 = Computed(function(): Color3
                            if loadedSongs[data.ID]:get() == false then
                                return Theme.ErrorText.Default:get()
                            end
                            return isSongPlaying:get() and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                        end),
                        HoverImage = Computed(function(): string
                            return isSongPlaying:get() and PAUSE_IMAGE.hover or PLAY_IMAGE.hover
                        end),

                        [OnEvent "Activated"] = function()
                            updatePlayingSound(sound, data)
                        end
                    },
                }
            }
        }
    }
end

local function PageKey(data: PublicTypes.Dictionary): Instance
    return Hydrate(Components.ImageButton {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = Util.interfaceActive,
        BackgroundTransparency = 1,
        ZIndex = 3,
        [Children] = Components.Constraints.UIAspectRatio(1),
    })(data)

end

local function getAudioChildren(): {Instance}
    local children = {}

    local assets = FETCHED_AUDIO_DATA:get()
    local itemsPerPage = ITEMS_PER_PAGE:get()

    local totalAssets = #assets
    local totalPages = math.ceil(totalAssets / itemsPerPage)

    local assetsRemaining = totalAssets

    if #assets == 0 then
        return {}
    end

    if itemsPerPage == lastItemsPerPage then
        return audioChildrenCache
    end

    songLoadData.loaded:set(0)
    songLoadData.total:set(math.max(totalAssets, 1))
    currentSongData.currentAudio:set(nil)
    currentSongData.currentTween:set(nil)
    currentSongData.timePosition:set(0)
    currentSongData.timeLength:set(0)
    lastItemsPerPage = itemsPerPage

    for index = 1, totalPages do
        local pageAssetCount = assetsRemaining > itemsPerPage and itemsPerPage or assetsRemaining

		local startIndex = ((index - 1) * itemsPerPage) + 1
		local endIndex = (startIndex + pageAssetCount) - 1

        table.insert(children, New "Frame" {
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                New "Frame" {
                    BackgroundTransparency = 1,
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
                }
            }
        })

        assetsRemaining -= itemsPerPage
    end

    jumpToPage(1)
    pageData.total:set(totalPages)
    audioChildrenCache = children

    return children
end

local function fetchApi()
    if os.clock() - lastFetchTime < 120 and CURRENT_FETCH_STATUS:get(false) == "Success" then
        return;
    end
    
    local newLoaded = {}

    lastFetchTime = os.clock()
    CURRENT_FETCH_STATUS:set("Fetching")
    task.wait(0.5)

    local fired, result, errorCode, errorDetails = GitUtil:Fetch(URL)
    
    CURRENT_FETCH_STATUS:set(if not fired then errorCode else "Success")
    
    if fired then
        local newData = {}

        for key, tbl in pairs(result) do
            newLoaded[tbl.id] = Value(nil)
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

        loadedSongs = newLoaded
        pageData.current:set(#newData > 0 and 1 or 0)
        FETCHED_AUDIO_DATA:set(newData)
    end
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local textboxObject = Value()
    local isSongPlaying = Computed(function(): boolean
        local currentSong = currentSongData.currentAudio:get()
        return currentSong and currentSong.IsPlaying 
    end)
    
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library"),
            Components.SearchBox {
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.new(0.5, 0, 0, 29),
                Placeholder = "Search by Artist",
                State = searchData.artist
            },

            Components.SearchBox {
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.new(0.5, 0, 0, 29),
                Placeholder = "Search by Name",
                State = searchData.name
            },

            New "Frame" { -- Holder
                BackgroundColor3 = Theme.TableItem.Default,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 1, -100),
                LayoutOrder = 2,

                [Children] = {
                    New "Frame" { -- Status Message
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.95),
                        Visible = Computed(function(): boolean
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
                                Text = Computed(function(): string
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
                        Visible = Computed(function(): boolean
                            return CURRENT_FETCH_STATUS:get() == "Success"
                        end),

                        [Children] = {
                            New "Frame" { -- Main
                                [Out "AbsoluteSize"] = frameAbsoluteSize, 

                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.925),

                                [Children] = {
                                    Hydrate(Components.Constraints.UIPageLayout(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, UDim.new(0, 4), Computed(function()
                                        return pageData.total:get() > 1
                                    end))) {
                                        [Ref] = pageLayout
                                    },

                                    Computed(getAudioChildren, Fusion.cleanup)
                                }
                            },
                        }
                    }
                }
            },

            New "Frame" { -- Now playing
                BackgroundColor3 = Theme.RibbonTab.Default,
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(1, 0, 0, 36),
                Position = Spring(Computed(function(): UDim2
                    return UDim2.new(0, 0, 1, if currentSongData.currentAudio:get() then -38 else 0)
                end), 20),

                [Children] = {
                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Position = UDim2.fromScale(0.0, 0),
                        Text = Computed(function(): string
                            local currentData = currentSongData.songData:get()
                            return ("<b>%s</b>\n%s"):format(currentData.Artist, currentData.Name)
                        end),
                        TextColor3 = Theme.MainText.Default,
                        LineHeight = 1.1,
                        RichText = true,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextSize = 15,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), nil)
                    },

                    Components.Slider {
                        Value = currentSongData.timePosition,
                        Min = Value(0),
                        Max = currentSongData.timeLength,
                        Position = UDim2.fromScale(0.7, 0.275),
                        Size = UDim2.fromScale(0.5, 0.2),
                        Increment = 1,
                    },

                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.45, 0, 0.5, 2),
                        Size = UDim2.fromScale(0.5, 0.25),
                        TextSize = 14,
                        Text = Computed(function(): string
                            return ("%s/%s"):format(
                                Util.secondsToTime(currentSongData.timePosition:get()), 
                                Util.secondsToTime(currentSongData.timeLength:get())
                            )
                        end),
                        TextColor3 = Theme.MainText.Default,
                    },

                    SongPlayButton {
                        Position = UDim2.fromScale(0.4, 0.3),
                        Size = UDim2.fromScale(0.5, 0.5),
                        Image = Computed(function(): string
                            return isSongPlaying:get() and PAUSE_IMAGE.normal or PLAY_IMAGE.normal
                        end),
                        ImageColor3 = Computed(function(): Color3
                            return isSongPlaying:get() and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                        end),
                        HoverImage = Computed(function(): string
                            return isSongPlaying:get() and PAUSE_IMAGE.hover or PLAY_IMAGE.hover
                        end),

                        [OnEvent "Activated"] = function()
                            updatePlayingSound(currentSongData.currentAudio:get(false), currentSongData.songData:get(false))
                        end
                    },

                    New "Frame" { -- Line
                        BackgroundColor3 = Theme.Border.Default,
                        Position = UDim2.new(0, 0, 0, -2),
                        Size = UDim2.new(1, 0, 0, 2)
                    },
                }
            },

            New "Frame" { -- Page Cycler
                BackgroundColor3 = Theme.RibbonTab.Default,
                AnchorPoint = Vector2.new(0, 1),
                Size = UDim2.new(1, 0, 0, 36),
                Position = UDim2.fromScale(0, 1),
                ZIndex = 3,

                [Children] = {
                    PageKey { -- Skip to first page
                        LayoutOrder = 1,
                        ImageColor3 = Computed(function(): Color3
                            return pageData.current:get() == 1 and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Image = "rbxassetid://4458877936",
                        Rotation = 180,
                        Position = UDim2.fromScale(0.1, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),
                        
                        [OnEvent "Activated"] = function()
                            jumpToPage(1)
                        end
                    },
                    
                    PageKey { -- Skip one page left
                        Image = "rbxassetid://6031094687",
                        LayoutOrder = 2,
                        Rotation = 90,
                        ImageColor3 = Computed(function(): Color3
                            return pageData.current:get() == 1 and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Position = UDim2.fromScale(0.3, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),
                        [OnEvent "Activated"] = function()
                            incrementPage(-1)
                        end
                    },
                    
                    New "TextBox" {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        LayoutOrder = 3,
                        PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                        PlaceholderText = Computed(function(): string
                            return ("Page %d/%d"):format(pageData.current:get(), pageData.total:get())
                        end),
                        TextColor3 = Theme.MainText.Default,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextSize = 16,
                        Font = Enum.Font.SourceSansSemibold,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),
                        ZIndex = 3,

                        [Ref] = textboxObject,

                        [OnEvent "FocusLost"] = function() 
                            local textbox = textboxObject:get(false)
                            if not textbox then
                                return
                            end 

                            local enteredText = textbox.Text
                            if not enteredText then
                                return
                            end 

                            local pageNumber = tonumber(enteredText)
                            if pageNumber then
                                textbox.Text = ""
                                jumpToPage(pageNumber)
                            end
                        end
                    },

                    PageKey { -- Skip one page right
                        LayoutOrder = 4,
                        Image = "rbxassetid://6031094687",
                        ImageColor3 = Computed(function(): Color3
                            return pageData.current:get() == pageData.total:get() and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Rotation = -90,
                        Position = UDim2.fromScale(0.7, 0.5),
                        Size = UDim2.new(0.2, -5, 1, -5),

                        [OnEvent "Activated"] = function()
                            incrementPage(1)
                        end
                    },

                    PageKey { -- Skip to end page
                        LayoutOrder = 5,
                        Image = "rbxassetid://4458877936",
                        Position = UDim2.fromScale(0.9, 0.5),
                        ImageColor3 = Computed(function(): Color3
                            return pageData.current:get() == pageData.total:get() and Theme.DimmedText.Default:get() or Theme.SubText.Default:get()
                        end),
                        Size = UDim2.new(0.2, -5, 1, -5),

                        [OnEvent "Activated"] = function()
                            jumpToPage(pageData.total:get(false))
                        end
                    },

                    New "Frame" { -- Line
                        BackgroundColor3 = Theme.Border.Default,
                        Position = UDim2.new(0, 0, 0, -2),
                        Size = UDim2.new(1, 0, 0, 2)
                    },
                }
            },

        }
    }
end

function frame.OnClose()
    stopSong()
end

function frame.OnOpen()
    fetchApi()
end

Util.MainMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
    local currentlyPlaying = currentSongData.currentAudio:get(false)
    if 
        currentlyPlaying ~= nil 
        and currentlyPlaying.IsLoaded 
        and currentlyPlaying.IsPlaying
        and not Util._Slider.isUsingSlider:get(false) 
    then
        currentSongData.timePosition:set(currentSongData.timePosition:get(false) + deltaTime)
    end
end))

Observer(currentSongData.timePosition):onChange(function()
    if Util._Slider.isUsingSlider:get(false) then
        local currentlyPlaying = currentSongData.currentAudio:get(false)
        if currentlyPlaying then
            currentlyPlaying.TimePosition = currentSongData.timePosition:get(false)
        end
    end
end)

return frame
