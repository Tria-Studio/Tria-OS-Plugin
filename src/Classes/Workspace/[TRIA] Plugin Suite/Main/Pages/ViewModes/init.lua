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
local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

local PAGE_ACTIVE = Value(false)

local textLabelVisible = Value(true)

local frame = {}

function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "ViewModes",

        [Children] = {
            Components.PageHeader("Tag Visualization"),
            Components.GradientTextLabel(Computed(function(): boolean
                local mapModel = Util.mapModel:get()
                return not Util.hasSpecialFolder:get() and mapModel ~= nil
            end), {
                Size = UDim2.new(1, 0, 1, 0),
                Text = "Unsupported Map."
            }),
            Components.ScrollingFrame {
                BackgroundColor3 = Theme.ScrollBarBackground.Default,
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

local function showPageError()
    Util:ShowMessage("Feature Unavaliable", "View Modes only supports maps with OptimizedStructure (aka the \"Special\" folder). You can add this to your map at the insert page.", {Text = "Get OptimizedStructure", Callback = function()
        Pages:ChangePage("Insert")
    end})
end

local function updatePage()
    local wasActive = PAGE_ACTIVE:get(false)
    PAGE_ACTIVE:set(Util.hasSpecialFolder:get(false) and Util.mapModel:get(false))
    textLabelVisible:set(not PAGE_ACTIVE:get(false))
    
    if wasActive and not PAGE_ACTIVE:get(false) and Pages.pageData.currentPage:get(false) == "ViewModes" then
        showPageError()
    end
end

function frame.OnOpen()
    if not Util.hasSpecialFolder:get(false) and Util.mapModel:get(false) then
        showPageError()
    end
end

function frame.OnClose()
    if Pages.pageData.currentPage:get(false) == "ViewModes" then
        Util.CloseMessage() 
    end
end

Observer(Util.hasSpecialFolder):onChange(updatePage)
Observer(Util.mapModel):onChange(updatePage)

return frame
