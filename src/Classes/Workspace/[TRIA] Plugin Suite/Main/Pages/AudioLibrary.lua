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

local frameAbsoluteSize = Value()
local lastFetchTime = 0

local searchData = {
    name = Value(""),
    artist = Value("")
}

local pageData = {
    current = Value(0),
    total = Value(0)
}

local currentSongData = {}
local currentSongTween = nil

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
    local sound = PluginSoundManager:CreateSound()
    sound.Name = data.Name

    return New "Frame" {
        BackgroundColor3 = Theme.CategoryItem.Default,
        Size = UDim2.new(1, 0, 0, 36),
        Visible = true,

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
                    },{Text = "Nevermind", Callback = function() end})
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

                            return BUTTON_ICONS.Play.normal
                                -- if isLoading then BUTTON_ICONS.Loading.normal
                                -- elseif isLoaded == Enum.TriStateBoolean.False then BUTTON_ICONS.Error.normal
                                -- elseif isPlaying then BUTTON_ICONS.Pause.normal
                                -- else BUTTON_ICONS.Play.normal
                        end),
                        ImageColor3 = Computed(function(): Color3
                            -- if loadedSongs[data.ID] and loadedSongs[data.ID]:get() == Enum.TriStateBoolean.False then
                            --     return Theme.ErrorText.Default:get()
                            -- end
                            -- return isSongPlaying:get() and Theme.MainButton.Default:get() or Theme.SubText.Default:get()
                            return Theme.SubText.Default:get()
                        end),
                        HoverImage = Computed(function(): string
                            -- local isLoaded = loadedSongs[data.ID]:get()
                            -- local isPlaying = isSongPlaying:get()
                            -- local isLoading = (not loadingSongs[data.ID]) or loadingSongs[data.ID]:get()

                            return BUTTON_ICONS.Play.hover
                                -- if isLoading then BUTTON_ICONS.Loading.hover
                                -- elseif isLoaded == Enum.TriStateBoolean.False then BUTTON_ICONS.Error.hover
                                -- elseif isPlaying then BUTTON_ICONS.Pause.hover
                                -- else BUTTON_ICONS.Play.hover
                        end),

                        [OnEvent "Activated"] = function()
                            -- if loadedSongs[data.ID]:get() == Enum.TriStateBoolean.False then
                            --     return
                            -- end
                            -- updatePlayingSound(sound, data)
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
    local totalPages = math.ceil(totalAssets / itemsPerPage)

    local assetsRemaining = totalAssets

    if #assets == 0 then
        return {}
    end

    -- currentSongData.currentAudio:set(nil)
    -- currentSongData.currentTween:set(nil)
    -- currentSongData.timePosition:set(0)
    -- currentSongData.timeLength:set(0)

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

    --jumpToPage(1)
    pageData.total:set(totalPages)

    return children
end


local frame = {}

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
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
    }
end

function frame.OnClose()
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
