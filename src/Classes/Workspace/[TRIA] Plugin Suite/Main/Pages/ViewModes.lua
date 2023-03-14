local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)
local Util = require(Package.Util)
local PublicTypes = require(Package.PublicTypes)
local Pages = require(Resources.Components.Pages)

local New = Fusion.New
local Children = Fusion.Children
local Observer = Fusion.Observer
local Value = Fusion.Value

local PAGE_ACTIVE = Value(false)

local TextLabelVisible = Value(true)

local frame = {}


function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "ViewModes",

        [Children] = {
            Components.PageHeader("View Modes"),
            Components.GradientTextLabel(Computed(function(): boolean
                local mapModel = Util.mapModel:get()
                return not Util.hasSpecialFolder:get() and mapModel ~= nil
            end), {
                Size = UDim2.new(1, 0, 1, 0),
                Text = "Unsupported Map."
            })
        }
    }
end


local function UpdatePage()
    local old = PAGE_ACTIVE:get()
    PAGE_ACTIVE:set(Util.hasSpecialFolder:get() and Util.mapModel:get())
    TextLabelVisible:set(not PAGE_ACTIVE:get())
    
    if old and not PAGE_ACTIVE:get() and Pages.pageData.currentPage:get() == "ViewModes" then
        Util:ShowMessage("Feature Unavaliable, AAAAA", "Due to the complexity and performance, View Modes only supports maps with OptimizedStructure (aka the \"Special\" folder). You can add this to your map at the insert page.", {Text = "Get OptimizedStructure", Callback = function()
            Pages:ChangePage("Insert")
        end})
    end
end
Observer(Util.hasSpecialFolder):onChange(UpdatePage)
Observer(Util.mapModel):onChange(UpdatePage)

function frame.onOpen()
    if not Util.hasSpecialFolder:get(false) and Util.mapModel:get(false) then
        Util:ShowMessage("Feature Unavaliable", "Due to the complexity and performance, View Modes only supports maps with OptimizedStructure (aka the \"Special\" folder). You can add this to your map at the insert page.", {Text = "Get OptimizedStructure", Callback = function()
            Pages:ChangePage("Insert")
        end})
    end
end

function frame.OnClose()
    if Util._Message.Header:get() == "Feature Unavaliable" then
        Util.CloseMessage() 
    end
end

return frame
