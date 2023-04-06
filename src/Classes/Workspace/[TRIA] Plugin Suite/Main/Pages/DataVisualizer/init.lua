local plugin = plugin or script:FindFirstAncestorWhichIsA("Plugin")
local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)
local Pages = require(Resources.Components.Pages)
local ViewFrame = require(script.ViewFrame)
local ViewData = require(script.ViewData)

local New = Fusion.New
local Children = Fusion.Children
local Observer = Fusion.Observer
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

local frame = {}


function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "DataVisualizer",

        [Children] = {
            Components.PageHeader("Debug View Modes"),
            Components.GradientTextLabel(Computed(function(): boolean
                local mapModel = Util.mapModel:get()
                return not Util.hasSpecialFolder:get() and mapModel ~= nil
            end), {
                Size = UDim2.new(1, 0, 1, 0),
                Text = "Unsupported Map."
            }),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.MainBackground.Default,
                BorderColor3 = Theme.Border.Default,
                BorderSizePixel = 1,
                Size = UDim2.new(1, 0, 1, 0),
                LayoutOrder = 2,

                [Children] = {
                    Components.Constraints.UIListLayout(nil, nil, UDim.new(0, 0)),
                    ForPairs(ViewData, function(tagName: string, data: PublicTypes.Dictionary): (string, Instance)
                        return tagName, ViewFrame(tagName, data)
                    end, Fusion.cleanup)
                }
            }
        }
    }
end

function frame.OnOpen()
    if not plugin:GetSetting("TRIA_HasViewedDebugView") then
        plugin:SetSetting("TRIA_HasViewedDebugView", true)
        Util:ShowMessage("Welcome to Debug View", "With the click of a button, you can view every part, instance, model, etc. of every data type that TRIA.os supports! This feature requires the OptimizedStructure (AKA the 'Special' folder) in order to work.\n\nUsing a featured addon in your map? Some featured addons support Debug View!")
    end
end

function frame.OnClose()
    if Pages.pageData.currentPage:get(false) == "DataVisualizer" then
        Util.CloseMessage() 
    end
end

Observer(Util._DebugView.activeDebugViews):onChange(function()
    Util._DebugView.debugObjectsFolder.Parent = Util._DebugView.activeDebugViews:get(false) ~= 0 and workspace.CurrentCamera or Util.Widget
end)



return frame
