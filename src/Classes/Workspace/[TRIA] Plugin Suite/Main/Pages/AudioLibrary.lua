local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")

local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)
local Util = require(Package.Util)
local PlguinSoundManager = require(Package.PluginSoundManager)
local GitUtil = require(Package.GitUtil)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local OnChange = Fusion.OnChange
local Value = Fusion.Value
local ForValues = Fusion.ForValues
local Hydrate = Fusion.Hydrate
local Ref = Fusion.Ref
local Out = Fusion.Out
local Spring = Fusion.Spring
local Observer = Fusion.Observer

local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local frame = {}

local URL = "https://raw.githubusercontent.com/Tria-Studio/TriaAudioList/master/AUDIO_LIST/list.json"

local MOCK_DATA = {
    {["Name"] = "Test Audio 1", ["ID"] = 5410083912, ["Artist"] = "Kris"},
    {["Name"] = "Test Audio 2", ["ID"] = 5409360995, ["Artist"] = "Grif"},
    {["Name"] = "Test Audio 3", ["ID"] = 7023635858, ["Artist"] = "Ethan"},
    {["Name"] = "Test Audio 4", ["ID"] = 5410085763, ["Artist"] = "Umbreon"},
    {["Name"] = "Test Audio 5", ["ID"] = 5410085189, ["Artist"] = "Super"}
}

local ITEMS_PER_PAGE = 8
local CURRENT_PAGE_COUNT = Value(1)
local TOTAL_PAGE_COUNT = Value(1)
local CURRENT_FETCH_STATUS = Value("Fetching")

local refreshTime = Value(GitUtil:GetTimeUntilNextRefresh())

local STATUS_ERRORS = {
    ["Fetching"] = "Currently fetching the latest audio...",
    ["HTTPDisabled"] = "Failed to fetch audio library due to HTTP requests being disabled. You can change this in the \"Plguin Settings\" tab.",
    ["HTTPError"] = "A network error occured while trying to get the latest audio. Please try again later.",
    ["JSONDecodeError"] = "A JSON Decoding error occured, please report this to the plugin developers as this needs to be manually fixed."
}

local currentAudio = Value(nil)
local currentAudioVolume = Value(1)

local isUsingSlider = Value(false)
local currentSlider = Value(nil)

local fadeInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

Observer(currentAudioVolume):onChange(function()
    if currentAudio:get(false) then
        currentAudio:get(false).Volume = currentAudioVolume:get(false)
    end
end)

function fade(sound: Sound, direction: string)
    local tween = TweenService:Create(sound, fadeInfo, {Volume = (direction == "In" and currentAudioVolume:get(false) or 0)})
    tween:Play()

    if direction == "Out" then
        tween.Completed:Connect(function()
            sound:Stop()
        end)
    end
end

local function Slider(data: PublicTypes.Dictionary, holder: Instance): {Instance}
    local absolutePosition = Value(Vector2.zero)
    local absoluteSize = Value(Vector2.zero)
    local sliderButton = Value()

    local text = Value("")

    local min = data.Min
    local max = data.Max

    local sliderPosition = Computed(function()
        return UDim2.fromScale((data.Value:get() - min:get()) / (max:get() - min:get()), 0.5)
    end)

    local backFrameSize = Computed(function()
        return UDim2.fromScale(data.Value:get() / max:get(), 1)
    end)

    local function updateSliderValue(mousePos: Vector2)
        local percent = 1 - math.clamp(-1 + ((mousePos.X + absoluteSize:get(false).X) / 2 / absoluteSize:get(false).X + 0.5) * 2, 0, 1)
    
        data.Value:set(math.clamp(
            Util.round(Util.lerp(min:get(false), max:get(false), percent), data.Increment), 
            min:get(false), 
            max:get(false)
        ))
    end

    local sliderFrame = New "ImageButton" {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = data.Position,
        Size = data.Size,
        BackgroundColor3 = Theme.SubText.Default,
        ImageTransparency = 1,
        Visible = if data.Visible then data.Visible else true,

        [Out "AbsolutePosition"] = absolutePosition,
        [Out "AbsoluteSize"] = absoluteSize,

        [OnEvent "MouseButton1Down"] = function()
            local mousePos = absolutePosition:get(false) - Util.Widget:GetRelativeMousePosition()
            isUsingSlider:set(true)
            updateSliderValue(mousePos)
            isUsingSlider:set(false)
        end,

        [OnEvent "MouseMoved"] = function()
            if isUsingSlider:get(false) and currentSlider:get(false) == sliderButton:get(false) then
                local mousePos = absolutePosition:get(false) - Util.Widget:GetRelativeMousePosition()
                updateSliderValue(mousePos)
            end
        end,

        [Children] = {
            New "ImageButton" {
                ImageTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(247, 0, 255),
                Position = sliderPosition,

                Size = UDim2.fromScale(1.6, 1.6),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ZIndex = 2,

                [Ref] = sliderButton,

                [Children] = {
                    Components.Constraints.UICorner(1, 0),
                    Components.Constraints.UIStroke(1, Color3.new(), Enum.ApplyStrokeMode.Border)
                },

                [OnEvent "MouseButton1Up"] = function()
                    isUsingSlider:set(false)
                    currentSlider:set(nil)
                end,

                [OnEvent "MouseButton1Down"] = function()
                    isUsingSlider:set(true)
                    currentSlider:set(sliderButton:get(false))
                end
            },

            New "Frame" {
                BackgroundColor3 = Color3.fromRGB(245, 158, 29),
                Size = backFrameSize,

                [Children] = Components.Constraints.UICorner(0, 8)
            },

            Components.Constraints.UICorner(0, 8)
        },
    }

    return sliderFrame
end

local function AudioButton(data: PublicTypes.Dictionary, holder): Instance
    local timePosition = Value(0)

    local previewSound = PlguinSoundManager:QueueSound(data.ID)
    previewSound.Volume = 0

    local soundLength = Value(1)
    local isPlaying = false

    previewSound.Loaded:Connect(function()
        soundLength:set(previewSound.TimeLength)
    end)
    previewSound.Played:Connect(function()
        isPlaying = true
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
            and not isUsingSlider:get(false) 
        then
            timePosition:set(timePosition:get(false) + deltaTime)
        end
    end)

    Observer(timePosition):onChange(function()
        if isUsingSlider:get(false) then
            previewSound.TimePosition = timePosition:get(false)
        end
    end)

    return New "Frame" {
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(1, 0, 1 / ITEMS_PER_PAGE, -4),
        
        [Children] = {
            New "TextLabel" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.4, 1),
                Position = UDim2.fromScale(0, 0),
                Text = ("%s - %s"):format(data.Artist, data.Name),
                TextColor3 = Theme.SubText.Default,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = Components.Constraints.UIPadding(nil, nil, UDim.new(0, 6), nil)
            },

            Components.TextButton {
                Size = UDim2.fromScale(0.1, 0.9),
                Position = UDim2.new(0.875, 0, 0.05, 0),
                Text = "Set Map BGM",
                TextSize = 15,
                TextScaled = true,

                [Children] = {
                    Components.Constraints.UICorner(0, 8)
                },

                [OnEvent "Activated"] = function()
                    Util.updateMapSetting("Main", "Music", data.ID)
                end
            },

            New "Frame" {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0.425, 0.8),
                Position = UDim2.new(0.675, 0, 0.2, 0),

                [Children] = {
                    Slider {
                        Value = timePosition,
                        Min = Value(0),
                        Max = soundLength,
                        Position = UDim2.fromScale(0.5, 0.4),
                        Size = UDim2.fromScale(0.7, 0.25),
                        Increment = 1
                    },

                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.15, 0, 0.7, -1),
                        Size = UDim2.fromScale(0.7, 0.25),
                        Text = Computed(function()
                            return Util.secondsToTime(timePosition:get()) .. "/" .. Util.secondsToTime(soundLength:get())
                        end),
                        TextColor3 = Theme.SubText.Default,
                    },

                    New "ImageButton" {
                        Image = Computed(function()
                            return "rbxasset://textures/StudioToolbox/AudioPreview/" .. (currentAudio:get() == previewSound and "Pause" or "Play") .. ".png"
                        end),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0, 0.4),
                        Size = UDim2.fromScale(0.6, 0.6),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        
                        [Children] = Components.Constraints.UICorner(1, 0),
                        [OnEvent "Activated"] = function()
                            local playing = currentAudio:get(false)
                            if playing ~= previewSound then
                                if playing then
                                    fade(playing, "Out")
                                end
                                previewSound.TimePosition = timePosition:get(false)
                                previewSound:Play()
                                currentAudio:set(previewSound)
                                fade(previewSound, "In")
                            else
                                if not playing then
                                    return
                                end
                                fade(playing, "Out")
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

    -- MOCK_DATA will be a state object, so we can hook a computed later on.

    for index = 1, #MOCK_DATA, ITEMS_PER_PAGE do 
        table.insert(children, New "Frame" {
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                Components.Constraints.UIListLayout(Enum.FillDirection.Vertical, nil, UDim.new(0, 4)),
                Computed(function()
                    local pageChildren = {}
                    for count = index, index + (ITEMS_PER_PAGE - 1) do
                        if MOCK_DATA[count] then
                            table.insert(pageChildren, AudioButton(MOCK_DATA[count]))
                        end
                    end
                    return pageChildren
                end):get()
            }
        })
    end

    TOTAL_PAGE_COUNT:set(#children)
    return children
end

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    local pageLayout = Value()
    
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library"),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BackgroundTransparency = 1,
                Size=  UDim2.fromScale(1, 1),

                [Children] = {
                    Components.Constraints.UIListLayout(nil, Enum.HorizontalAlignment.Center, UDim.new(0, 2)),
                    Components.FrameHeader("About the Audio Library", 1, nil, nil, nil),
                    Components.BasicTextLabel([[The audio library allows map creators to find approved music to use in their maps.
Below you will find a list of audios which have been approved for use by TRIA staff. You can choose to preview the song or automatically set your map's BGM to the selected audio.]], 2),
                    Components.FrameHeader("Audio Library", 3, nil, nil, nil),

                    New "Frame" { -- Holder
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(1, 0.85),
                        LayoutOrder = 4,

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
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(1, 0.1),
                                        Text = Computed(function()
                                            return STATUS_ERRORS[CURRENT_FETCH_STATUS:get()] or "N/A"
                                        end),
                                        TextSize = 18,
                                        TextColor3 = Theme.SubText.Default,
                                        TextXAlignment = Enum.TextXAlignment.Center,
                                        TextYAlignment = Enum.TextYAlignment.Top
                                    },
                                }
                            },

                            New "Frame" { -- Audio Library
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.95),
                                Visible = Computed(function()
                                    return CURRENT_FETCH_STATUS:get() == "Success"
                                end),

                                [Children] = {
                                    New "Frame" { -- Main
                                        BackgroundTransparency = 1,
                                        Size = UDim2.fromScale(1, 0.925),

                                        [Children] = {
                                            Hydrate(Components.Constraints.UIPageLayout(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, UDim.new(0, 4), Computed(function()
                                                return TOTAL_PAGE_COUNT:get() > 1
                                            end))) {
                                                [Ref] = pageLayout
                                            },

                                            Computed(getAudioChildren)
                                        }
                                    },

                                    New "Frame" { -- Page Cycler
                                        BackgroundColor3 = Color3.new(),
                                        BackgroundTransparency = 0.25,
                                        Size = UDim2.fromScale(1, 0.075),
                                        Position = UDim2.fromScale(0, 0.925),

                                        [Children] = {
                                            Components.ImageButton { -- Skip to first page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 1,
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
                                                Position = UDim2.fromScale(0.3, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                
                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):Previous()

                                                    local currentPage = CURRENT_PAGE_COUNT:get(false)
                                                    CURRENT_PAGE_COUNT:set((currentPage - 1 < 1 and TOTAL_PAGE_COUNT:get(false) or currentPage - 1))
                                                end
                                            },
                                            
                                            New "TextLabel" {
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 3,
                                                Text = Computed(function()
                                                    return ("Page %d/%d"):format(CURRENT_PAGE_COUNT:get(), TOTAL_PAGE_COUNT:get())
                                                end),
                                                TextColor3 = Theme.TitlebarText.Default,
                                                TextXAlignment = Enum.TextXAlignment.Center,
                                                TextSize = 16,
                                                Position = UDim2.fromScale(0.5, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),
                                            },

                                            Components.ImageButton { -- Skip one page right
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 4,
                                                Image = "rbxassetid://6031094687",
                                                Rotation = -90,
                                                Position = UDim2.fromScale(0.7, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),

                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):Next()

                                                    local currentPage = CURRENT_PAGE_COUNT:get(false)
                                                    CURRENT_PAGE_COUNT:set((currentPage + 1 > TOTAL_PAGE_COUNT:get(false) and 1 or currentPage + 1))
                                                end
                                            },

                                            Components.ImageButton { -- Skip to end page
                                                AnchorPoint = Vector2.new(0.5, 0.5),
                                                Active = Util.interfaceActive,
                                                BackgroundTransparency = 1,
                                                LayoutOrder = 5,
                                                Image = "rbxassetid://4458877936",
                                                Position = UDim2.fromScale(0.9, 0.5),
                                                Size = UDim2.new(0.2, -5, 1, -5),

                                                [Children] = Components.Constraints.UIAspectRatio(1),
                                                [OnEvent "Activated"] = function()
                                                    pageLayout:get(false):JumpToIndex(TOTAL_PAGE_COUNT:get(false) - 1)
                                                    CURRENT_PAGE_COUNT:set(TOTAL_PAGE_COUNT:get(false))
                                                end
                                            }
                                        }
                                    },

                                    New "Frame" { -- Line
                                        BackgroundColor3 = Theme.Border.Default,
                                        Position = UDim2.new(0, 0, 1, -2),
                                        Size = UDim2.new(1, 0, 0, 2)
                                    },
                                }
                            },

                            New "Frame" { -- Refresh time
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 0.05),
                                Position = UDim2.fromScale(0, 0.95),

                                [Children] = {
                                    New "TextLabel" {
                                        BackgroundTransparency = 1,
                                        Position = UDim2.fromScale(0.275, 0),
                                        Size = UDim2.fromScale(0.5, 1),
                                        Text = Computed(function()
                                            return ("Volume: %.2f"):format(currentAudioVolume:get())
                                        end),
                                        TextColor3 = Theme.SubText.Default,
                                        TextXAlignment = Enum.TextXAlignment.Left,
                                        Visible = Computed(function()
                                            return CURRENT_FETCH_STATUS:get() == "Success"
                                        end),
                                    },

                                    Slider {
                                        Value = currentAudioVolume,
                                        Min = Value(0),
                                        Max = Value(1),
                                        Position = UDim2.fromScale(0.125, 0.55),
                                        Size = UDim2.fromScale(0.2, 0.35),
                                        Increment = 0.01,
                                        Visible = Computed(function()
                                            return CURRENT_FETCH_STATUS:get() == "Success"
                                        end),
                                    },

                                    New "TextLabel" {
                                        BackgroundTransparency = 1,
                                        Position = UDim2.new(0.5, -4, 0, 0),
                                        Size = UDim2.fromScale(0.5, 1),
                                        Text = Computed(function()
                                            return "Refreshing in " .. Util.secondsToLongTime(refreshTime:get())
                                        end),
                                        TextColor3 = Theme.SubText.Default,
                                        TextXAlignment = Enum.TextXAlignment.Right,
                                    },
                                }
                            }
                        }
                    },
                }
            }
        }
    }
end

function frame.OnOpen()
    CURRENT_FETCH_STATUS:set("Fetching")
    print("Fetching")

    task.wait(1.5)

    local fired, result, errorCode, errorDetails = GitUtil:Fetch(URL)
    print("Fired:", fired, "Code:", errorCode)

    CURRENT_FETCH_STATUS:set(if not fired then errorCode else "Success")
end

return frame