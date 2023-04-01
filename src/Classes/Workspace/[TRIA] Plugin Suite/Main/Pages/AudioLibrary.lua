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
local PlguinSoundManager = require(Package.Util.PluginSoundManager)
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

local SoundMaid = Util.Maid.new()

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
