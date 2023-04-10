local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
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
local PluginSoundManager = require(Package.Util.PluginSoundManager)
local GitUtil = require(Package.Util.GitUtil)

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

type audioTableFormat = {Name: string, Artist: string, ID: number}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"
local BUTTON_ICONS = {
    Pause = {
        normal = "rbxassetid://6026663701",
        hover = "rbxassetid://6026663718"
    },
    Play = {
        normal = "rbxassetid://6026663726",
        hover = "rbxassetid://6026663705"
    },
    Error = {
        normal = "rbxassetid://6031071050",
        hover = "rbxassetid://6031071057",
    },
    Loading = {
        normal = "rbxassetid://12853387225",
        hover = "rbxassetid://12853387151"
    }
}

task.spawn(function()
    for _, t in pairs(BUTTON_ICONS) do
        for _, imageId in pairs(t) do
            ContentProvider:PreloadAsync({imageId})
        end
    end
end)

local SoundMaid = Util.Maid.new()

local frameAbsoluteSize = Value()


local lastFetchTime = 0
local songLoadSession = 0

local searchData = {
    name = Value(""),
    artist = Value("")
}

local songLoadData = {
    isLoadingSong = Value(false),
    currentlyLoading = Value(nil),
    loaded = {},
}

local songPlayData = {
    currentlyPlaying = Value(nil),
    currentTimePosition = Value(0),
    currentTimeLength = Value(1),
    currentSongData = Value({Name = "", Artist = ""}),
    isPaused = Value(false),
    currentTween = nil
}

local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local CURRENT_FETCH_STATUS = Value("Fetching")
local FETCHED_AUDIO_DATA = Value({})

local STATUS_ERRORS = {
    ["Fetching"] = "Fetching the latest audio...",
    ["HTTPDisabled"] = "Failed to fetch audio library due to HTTP requests being disabled. You can change this in the \"Plugin Settings\" tab.",
    ["HTTPError"] = "A network error occured while trying to get the latest audio. Please try again later.",
    ["JSONDecodeError"] = "A JSON Decoding error occured, please report this to the plugin developers as this needs to be manually fixed."
}

local function fadeSound(sound: Sound, direction: string)
    if not sound then
        return
    end

    local tween = TweenService:Create(sound, fadeInfo, {Volume = (direction == "In" and 1 or 0)})
    tween:Play()
    songPlayData.currentTween = tween

    if direction == "Out" then
        tween.Completed:Connect(function()
            if tween.PlaybackState ~= Enum.PlaybackState.Cancelled then
                sound:Stop()
            end
        end)
    end
end

local function loadSound(sound: Sound, soundData: audioTableFormat): boolean
    local LoadEvent = Util.Signal.new()

    local loaded = false
    local timeout = false

    songLoadSession += 1
    local currentSession = songLoadSession

    if songLoadData.loaded[soundData.ID]:get(false) ~= Enum.TriStateBoolean.True then
        Util.toggleAudioPerms(true)
    end

    songLoadData.isLoadingSong:set(true)
    songLoadData.currentlyLoading:set(sound)

    sound.SoundId = "rbxassetid://" .. soundData.ID
    task.wait()

    task.delay(5, function()
        if not loaded then
            timeout = true
            LoadEvent:Fire()
        end
    end)

    task.spawn(function()
        ContentProvider:PreloadAsync({sound}, function(assetId: number, fetchStatus: Enum.AssetFetchStatus)
            loaded = (fetchStatus == Enum.AssetFetchStatus.Success) and not timeout
        end)
    
        if not timeout then
            LoadEvent:Fire()
        end
    end)

    LoadEvent:Wait()
    songLoadData.loaded[soundData.ID]:set(Enum.TriStateBoolean[loaded and "True" or "False"])
    songLoadData.isLoadingSong:set(false)
    songLoadData.currentlyLoading:set(nil)

    --== DO NOT TOUCH THIS ==--
    task.delay(1, function()
        if Util.AudioPerms and currentSession == songLoadSession then
            Util.toggleAudioPerms(false)
        end
    end)
    
    return loaded
end

local function resetSongData()
    songPlayData.currentTimePosition:set(0)
    songPlayData.currentlyPlaying:set(nil)
    Util._Slider.isUsingSlider:set(false)
end

local function stopSong()
    local currentlyPlaying = songPlayData.currentlyPlaying:get(false)
    if not currentlyPlaying then
        return
    end
    fadeSound(currentlyPlaying, "Out")
    resetSongData()
end

local function pauseSong(soundData: audioTableFormat)
    local currentlyPlaying = songPlayData.currentlyPlaying:get(false)
    if not currentlyPlaying then
        return
    end
    currentlyPlaying:Pause()
    songPlayData.currentlyPlaying:set(currentlyPlaying, true)
    songPlayData.isPaused:set(true)
end

local function resumeSong(soundData: audioTableFormat)
    local currentlyPlaying = songPlayData.currentlyPlaying:get(false)
    if not currentlyPlaying then
        return
    end
    currentlyPlaying.Volume = 0
    currentlyPlaying:Resume()
    songPlayData.currentlyPlaying:set(currentlyPlaying, true)
    songPlayData.isPaused:set(false)
    fadeSound(currentlyPlaying, "In")
end

local function playSong(newSound: Sound, soundData: audioTableFormat)
    SoundMaid:DoCleaning()

    newSound.Volume = 0
    newSound.TimePosition = 0
    newSound:Resume()
    fadeSound(newSound, "In")

    songPlayData.isPaused:set(false)
    songPlayData.currentTimePosition:set(0)
    songPlayData.currentlyPlaying:set(newSound, true)
    songPlayData.currentSongData:set(soundData)
    
    SoundMaid:GiveTask(newSound.Ended:Connect(resetSongData))

    SoundMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
        if newSound ~= nil 
            and newSound.IsLoaded 
            and newSound.IsPlaying
            and not Util._Slider.isUsingSlider:get(false) 
        then
            songPlayData.currentTimePosition:set(songPlayData.currentTimePosition:get(false) + deltaTime)
        end
    end))

    songPlayData.currentTimeLength:set(math.max(newSound.TimeLength, 0.1))
    SoundMaid:GiveTask(newSound:GetPropertyChangedSignal("TimeLength"):Connect(function()
        songPlayData.currentTimeLength:set(math.max(newSound.TimeLength, 0.1))
    end))
end

local function stopCurrentTween()
    local tween = songPlayData.currentTween
    if tween then
        tween:Cancel()
        songPlayData.currentTween = nil
    end
end

local function updatePlayingSound(newSound: Sound, soundData: audioTableFormat)
    local currentlyPlaying = songPlayData.currentlyPlaying:get(false)

    if not currentlyPlaying then -- No song playing
        stopCurrentTween()
        playSong(newSound, soundData)
    elseif currentlyPlaying == newSound then -- Song being paused/resumed
        if currentlyPlaying.IsPaused then
            resumeSong(soundData)
        else
            pauseSong(soundData)
        end
    else -- Song switched while playing
        fadeSound(currentlyPlaying, "Out")
        playSong(newSound, soundData)
    end
end

local function SongPlayButton(data: PublicTypes.Dictionary): Instance
    return Hydrate(Components.ImageButton {
        Active = Util.interfaceActive,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 3,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        [Children] = Components.Constraints.UICorner(1, 0),
    })(data)
end

local function AudioButton(data: audioTableFormat): Instance
    local audio = PluginSoundManager:CreateSound()
    audio.Name = data.Name
    songLoadData.loaded[data.ID] = Value(Enum.TriStateBoolean.Unknown)

    local isLoadingCurrentSong = Computed(function(): boolean
        return songLoadData.isLoadingSong:get() and songLoadData.currentlyLoading:get() == audio
    end)

    local isPlayingCurrentSong = Computed(function(): boolean
        local currentSong = songPlayData.currentlyPlaying:get()
        local isPaused = songPlayData.isPaused:get()

        return (not isPaused) and (currentSong and currentSong == audio)
    end)

    local isSongNotLoaded = Computed(function(): boolean
        return songLoadData.loaded[data.ID]:get() == Enum.TriStateBoolean.False
    end)

    local BackgroundColorSpring = Spring(Computed(function(): Color3
        Util._ThemeUpdate:get()
        local defaultColor = Theme.CategoryItem.Default:get(false)
        local colorMultiplier = if isPlayingCurrentSong:get() then 1.125 else 1

        return Color3.new(defaultColor.R * colorMultiplier, defaultColor.G * colorMultiplier, defaultColor.B * colorMultiplier)
    end), 15)

    return New "Frame" {
        BackgroundColor3 = BackgroundColorSpring,
        Size = UDim2.new(1, 0, 0, 36),
        Visible = Computed(function()
            local searchedArtist = searchData.artist:get()
            local searchedName = searchData.name:get()

            local matches = true
            if searchedArtist and #searchedArtist > 0 and not data.Artist:lower():match(searchedArtist:lower()) then
                matches = false
            end
            if searchedName and #searchedName > 0 and not data.Name:lower():match(searchedName:lower()) then
                matches = false
            end

            return matches
        end),

        [Cleanup] = {audio},

        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.8, 1),
                ClipsDescendants = true,
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
                Active = Util.interfaceActive,
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
                    Util:ShowMessage("Update map BGM?", 
                        ("This will update the map BGM to <font color='rgb(207, 174, 0)'>%s - %s</font>, press <font color='rgb(7, 184, 4)'>Update</font> to confirm"):format(data.Artist, data.Name), 
                        {
                            Text = "Update",
                            Callback = function()
                                Util.debugWarn("Updated map music!")
                                Util.updateMapSetting("Main", "Music", data.ID)
                                ChangeHistoryService:SetWaypoint("Updated map music")
                            end
                        }, {Text = "Nevermind", Callback = function() end}
                    )
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
                            return 
                                if isLoadingCurrentSong:get() then BUTTON_ICONS.Loading.normal
                                elseif isSongNotLoaded:get() then BUTTON_ICONS.Error.normal
                                elseif isPlayingCurrentSong:get() then BUTTON_ICONS.Pause.normal
                                else BUTTON_ICONS.Play.normal
                        end),
                        ImageColor3 = Computed(function(): Color3
                            return
                                if isSongNotLoaded:get() then Theme.ErrorText.Default:get()
                                elseif isPlayingCurrentSong:get() then Theme.MainButton.Default:get()
                                else Theme.SubText.Default:get()
                        end),
                        HoverImage = Computed(function(): string
                            return
                                if isLoadingCurrentSong:get() then BUTTON_ICONS.Loading.hover
                                elseif isSongNotLoaded:get() then BUTTON_ICONS.Error.hover
                                elseif isPlayingCurrentSong:get() then BUTTON_ICONS.Pause.hover
                                else BUTTON_ICONS.Play.hover
                        end),

                        [OnEvent "MouseButton1Down"] = function()
                            if songLoadData.isLoadingSong:get(false) then
                                return
                            end

                            if not Util.interfaceActive:get(false) then
                                return
                            end

                            local needsLoading = songLoadData.loaded[data.ID]:get() ~= Enum.TriStateBoolean.True
                            local soundLoaded = if needsLoading then loadSound(audio, data) else true
                            if soundLoaded and audio then
                                updatePlayingSound(audio, data)
                            end  
                        end
                    },
                }
            }
            
        }
    }
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

        loadedSongs = {}
        FETCHED_AUDIO_DATA:set(newData)
    end
end

local function getScrollChildren(): {Instance}
    local children = {}
    local assets = FETCHED_AUDIO_DATA:get()

    if #assets == 0 then
        return {}
    end

    resetSongData()
    for index = 1, #assets do
        table.insert(children, AudioButton(assets[index]))
    end

    return children
end


local frame = {}

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local textboxObject = Value()
    local isSongPlaying = Computed(function(): boolean
        return songPlayData.currentlyPlaying:get() and (not songPlayData.isPaused:get())
    end)

    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library", 4),
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
                Position = UDim2.new(0, 0, 0, 36),
                Size = UDim2.new(1, 0, 1, -36),
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
                                    if not table.find({"Fetching", "Success"}, CURRENT_FETCH_STATUS:get(false)) and Util.mapModel:get() then
                                        task.spawn(fetchApi)
                                    end
                                end
                            }
                        }
                    },

                    New "Frame" { -- Audio Library
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, -42),
                        Visible = Computed(function(): boolean
                            return CURRENT_FETCH_STATUS:get() == "Success"
                        end),

                        [Children] = {
                            New "Frame" { -- Main
                                [Out "AbsoluteSize"] = frameAbsoluteSize, 

                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 1),

                                [Children] = {
                                    Components.ScrollingFrame({
                                        BackgroundTransparency = 1,
                                        BackgroundColor3 = Color3.new(1, 1, 1),
                                        Size = UDim2.fromScale(1, 1),

                                        [Children] = {
                                            Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, nil, UDim.new(0, 4)),
                                            Computed(getScrollChildren, Fusion.cleanup)
                                        }
                                    }, false)
                                }
                            },
                        }
                    },

                    New "Frame" { -- Now playing
                        BackgroundColor3 = Theme.RibbonTab.Default,
                        AnchorPoint = Vector2.new(0, 1),
                        Size = UDim2.new(1, 0, 0, 36),
                        Position = Spring(Computed(function(): UDim2
                            return UDim2.new(0, 0, 1, if songPlayData.currentlyPlaying:get() then 0 else 38)
                        end), 20),

                        [Children] = {
                            New "TextLabel" {
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(0.6, 1),
                                Position = UDim2.fromScale(0.0, 0),
                                Text = Computed(function(): string
                                    local currentData = songPlayData.currentSongData:get()
                                    return ("<b>%s</b>\n%s"):format(currentData.Artist, currentData.Name)
                                end),
                                TextColor3 = Theme.MainText.Default,
                                LineHeight = 1.1,
                                RichText = true,
                                ClipsDescendants = true,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                TextSize = 15,
                                TextXAlignment = Enum.TextXAlignment.Left, 

                                [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), nil)
                            },

                            Components.Slider {
                                Value = songPlayData.currentTimePosition,
                                Min = Value(0),
                                Max = songPlayData.currentTimeLength,
                                Position = UDim2.fromScale(0.675, 0.275),
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
                                        Util.secondsToTime(songPlayData.currentTimePosition:get()), 
                                        Util.secondsToTime(songPlayData.currentTimeLength:get())
                                    )
                                end),
                                TextColor3 = Theme.MainText.Default,
                            },

                            SongPlayButton {
                                Position = UDim2.fromScale(0.375, 0.3),
                                Size = UDim2.fromScale(0.5, 0.5),
                                Image = Computed(function(): string
                                    return isSongPlaying:get() and BUTTON_ICONS.Pause.normal or BUTTON_ICONS.Play.normal
                                end),
                                ImageColor3 = Computed(function(): Color3
                                    return isSongPlaying:get() and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                                end),
                                HoverImage = Computed(function(): string
                                    return isSongPlaying:get() and BUTTON_ICONS.Pause.hover or BUTTON_ICONS.Play.hover
                                end),
                                ZIndex = 1,

                                [OnEvent "Activated"] = function()
                                    updatePlayingSound(songPlayData.currentlyPlaying:get(false), songPlayData.currentSongData:get(false))
                                end
                            },

                            Components.ImageButton {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BorderSizePixel = 0,
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.96, 0.3),
                                Size = UDim2.fromScale(0.4, 0.4),
                                Image = "rbxasset://textures/StudioSharedUI/clear.png",
                                HoverImage = "rbxasset://textures/StudioSharedUI/clear-hover.png",
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                [OnEvent "Activated"] = function()
                                    stopSong()
                                end
                            },

                            New "Frame" { -- Line
                                BackgroundColor3 = Theme.Border.Default,
                                Position = UDim2.new(0, 0, 0, -2),
                                Size = UDim2.new(1, 0, 0, 2),
                            },
                        }
                    }
                }
            },
        }
    }
end

function frame.OnClose()
    SoundMaid:DoCleaning()
    stopSong()
    resetSongData()
    if Util.mapModel:get(false) then
        fetchApi()
    end
end

task.defer(function()
    if not Util.mapModel:get(false) then
        Util.MapChanged:Wait()
    end
    task.defer(fetchApi)
end)

Observer(songPlayData.currentTimePosition):onChange(function()
    if Util._Slider.isUsingSlider:get(false) then
        local currentlyPlaying = songPlayData.currentlyPlaying:get(false)
        if currentlyPlaying then
            currentlyPlaying.TimePosition = songPlayData.currentTimePosition:get(false)
        end
    end
end)

Observer(Util.interfaceActive):onChange(function()
    if not Util.interfaceActive:get() then
        stopSong()
    end
end)

return frame
