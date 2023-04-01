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

local frame = {}

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.TableItem.Default,
        Visible = data.Visible,
        Name = "AudioLib",

        [Children] = {
            Components.PageHeader("Audio Library", 4)
        }
    }
end

return frame
