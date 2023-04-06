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
local pageLayout = Value()

local lastFetchTime = 0

local searchData = {
    name = Value(""),
    artist = Value("")
}

local pageData = {
    current = Value(0),
    total = Value(0)
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

local ITEMS_PER_PAGE = Computed(function(): number
    return frameAbsoluteSize:get() and math.max(1, math.floor((frameAbsoluteSize:get().Y + 32) / 40)) or 12
end)

local CURRENT_FETCH_STATUS = Value("Fetching")

local FETCHED_AUDIO_DATA = Value({})
local FILTERED_AUDIO_DATA = Computed(function(): {audioTableFormat}
    local newData = {}

    local searchedArtist = searchData.artist:get() or ""
    local searchedName = searchData.name:get() or ""

    for _, tbl in pairs(FETCHED_AUDIO_DATA:get()) do
        local matches = 
            if (searchedArtist and #searchedArtist > 0) then tbl.Artist:lower():match(searchedArtist:lower()) ~= nil
            elseif (searchedName and #searchedName > 0) then tbl.Name:lower():match(searchedName:lower()) ~= nil
            else true

        if matches then
            table.insert(newData, tbl)
        end
    end

    return newData
end)

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
    local loaded = false

    if not songLoadData.loaded[soundData.ID] then
        Util.toggleAudioPerms(true)
    end

    songLoadData.isLoadingSong:set(true)
    songLoadData.currentlyLoading:set(sound)

    sound.SoundId = "rbxassetid://" .. soundData.ID
    task.wait()

    ContentProvider:PreloadAsync({sound}, function(assetId: number, fetchStatus: Enum.AssetFetchStatus)
        print(fetchStatus)
        loaded = fetchStatus == Enum.AssetFetchStatus.Success
    end)

    songLoadData.isLoadingSong:set(false)
    songLoadData.currentlyLoading:set(nil)

    --== DO NOT TOUCH THIS ==--
    task.wait()
    Util.toggleAudioPerms(false)

    print("Did load", loaded)
    if loaded then
        songLoadData.loaded[soundData.ID] = true
    end
    return loaded
end

local function stopSong()
    local currentlyPlaying = songPlayData.currentlyPlaying:get(false)
    if not currentlyPlaying then
        return
    end
    fadeSound(currentlyPlaying, "Out")
    songPlayData.currentlyPlaying:set(nil)
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
    newSound.Volume = 0
    newSound.TimePosition = 0
    newSound:Resume()
    fadeSound(newSound, "In")

    songPlayData.currentlyPlaying:set(newSound)
end

local function stopCurrentTween()
    local tween = songPlayData.currentTween
    if tween then
        tween:Cancel()
        songPlayData.currentTween = nil
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

    local isLoadingCurrentSong = Computed(function(): boolean
        return songLoadData.isLoadingSong:get() and songLoadData.currentlyLoading:get() == audio
    end)

    local isPlayingCurrentSong = Computed(function(): boolean
        local currentSong = songPlayData.currentlyPlaying:get()
        local isPaused = songPlayData.isPaused:get()

        return (not isPaused) and (currentSong and currentSong == audio)
    end)

    return New "Frame" {
        BackgroundColor3 = Theme.CategoryItem.Default,
        Size = UDim2.new(1, 0, 0, 36),
        Visible = true,

        [Cleanup] = {
            function()
                print("Clean audio")
            end,
            -- audio
        },

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
                    }, {Text = "Nevermind", Callback = function() end})
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
                            -- local isLoaded = loadedSongs[data.ID]:get()
                            -- local isPlaying = isSongPlaying:get()
                            -- local isLoading = (not loadingSongs[data.ID]) or loadingSongs[data.ID]:get()

                            return 
                                if isLoadingCurrentSong:get() then BUTTON_ICONS.Loading.normal
                                -- elseif isLoaded == Enum.TriStateBoolean.False then BUTTON_ICONS.Error.normal
                                elseif isPlayingCurrentSong:get() then BUTTON_ICONS.Pause.normal
                                else BUTTON_ICONS.Play.normal
                        end),
                        ImageColor3 = Computed(function(): Color3
                            -- if loadedSongs[data.ID] and loadedSongs[data.ID]:get() == Enum.TriStateBoolean.False then
                            --     return Theme.ErrorText.Default:get()
                            -- end
                            return isPlayingCurrentSong:get() and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                        end),
                        HoverImage = Computed(function(): string
                            -- local isLoaded = loadedSongs[data.ID]:get()
                            -- local isPlaying = isSongPlaying:get()
                            -- local isLoading = (not loadingSongs[data.ID]) or loadingSongs[data.ID]:get()

                            return
                                if isLoadingCurrentSong:get() then BUTTON_ICONS.Loading.hover
                                -- elseif isLoaded == Enum.TriStateBoolean.False then BUTTON_ICONS.Error.hover
                                elseif isPlayingCurrentSong:get() then BUTTON_ICONS.Pause.hover
                                else BUTTON_ICONS.Play.hover
                        end),

                        [OnEvent "MouseButton1Down"] = function()
                            print("Clicked")
                            if songLoadData.isLoadingSong:get(false) then
                                return
                            end

                            local needsLoading = not songLoadData.loaded[data.ID]
                            print("Needs", needsLoading)

                            local soundLoaded = if needsLoading then loadSound(audio, data) else true
                            if soundLoaded and audio then
                                print("Updating")
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
        pageData.current:set(#newData > 0 and 1 or 0)
        FETCHED_AUDIO_DATA:set(newData)
    end
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

    local assets = FILTERED_AUDIO_DATA:get()
    local itemsPerPage = ITEMS_PER_PAGE:get()

    local totalAssets = #assets
    local totalPages = math.ceil(totalAssets / math.min(itemsPerPage, 1))

    local assetsRemaining = totalAssets

    if #assets == 0 then
        return {}
    end

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
    print("Created")

    return children
end


local frame = {}

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
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
                                    if not table.find({"Fetching", "Success"}, CURRENT_FETCH_STATUS:get(false)) and Util.mapModel:get() then
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
                                    Hydrate(Components.Constraints.UIPageLayout(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, UDim.new(0, 4), Computed(function(): boolean
                                        return pageData.total:get() > 1
                                    end))) {
                                        [Ref] = pageLayout
                                    },

                                    Computed(getAudioChildren, function(child)
                                        warn("Should clean", child)                                        
                                    end)
                                }
                            },
                        }
                    },

                    New "Frame" { -- Now playing
                        BackgroundColor3 = Theme.RibbonTab.Default,
                        AnchorPoint = Vector2.new(0, 1),
                        Size = UDim2.new(1, 0, 0, 36),
                        Position = Spring(Computed(function(): UDim2
                            return UDim2.new(0, 0, 1, if songPlayData.currentlyPlaying:get() then -38 else 0)
                        end), 20),

                        [Children] = {
                            New "TextLabel" {
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(.6, 1),
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
                                        Util.secondsToTime(songPlayData.currentTimePosition:get()), 
                                        Util.secondsToTime(songPlayData.currentTimeLength:get())
                                    )
                                end),
                                TextColor3 = Theme.MainText.Default,
                            },

                            SongPlayButton {
                                Position = UDim2.fromScale(0.4, 0.3),
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

                                [OnEvent "Activated"] = function()
                                    updatePlayingSound(songPlayData.currentlyPlaying:get(false), songPlayData.currentSongData:get(false))
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
            },
        }
    }
end

function frame.OnClose()
    SoundMaid:DoCleaning()
    if Util.mapModel:get(false) then
        fetchApi()
    end
end

function frame.OnOpen()
    if not plugin:GetSetting("TRIA_HasViewedAudioLibrary") then
        plugin:SetSetting("TRIA_HasViewedAudioLibrary", true)
        Util:ShowMessage("Welcome to the Audio Library", "Every audio that has been whitelisted by the TRIA staff for use in maps is shown here. If the audio has been created by Roblox or is on this list, it is good for use. \n\nFor information on how to submit your own audios to the library, check out the help page linked in the plugin's description.")
    end
end

task.defer(function()
    if not Util.mapModel:get(false) then
        Util.MapChanged:Wait()
    end
    task.defer(fetchApi)
end)

return frame
