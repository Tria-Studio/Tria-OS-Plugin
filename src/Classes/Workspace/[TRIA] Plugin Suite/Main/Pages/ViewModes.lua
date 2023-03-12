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
local Computed = Fusion.Computed

local frame = {}
 
function frame:GetFrame(data: PublicTypes.Dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "ViewModes",

        [Children] = {
            Components.PageHeader("View Modes"),
            Components.GradientTextLabel(Computed(function()
                local mapModel = Util.mapModel:get()
                return not Util.hasSpecialFolder:get() and mapModel
            end), {
                Size = UDim2.new(1, 0, 1, 0),
                Text = "Unsupported Map."
            })
        }
    }
end

Util.MapChanged:Connect(function()
    if not Util.hasSpecialFolder:get() then
        Util:ShowMessage("Feature Unavaliable", "Due to the complexity and performance, View Modes only supports maps with OptimizedStructure (aka the \"Special\" folder). You can add this to your map at the insert page.", {Text = "Get Mapkit", Callback = function()
            Pages:ChangePage("Insert")
        end})
    end
end)

function frame.onOpen()
    if not Util.hasSpecialFolder:get() and Util.mapModel:get() then
        Util:ShowMessage("Feature Unavaliable", "Due to the complexity and performance, View Modes only supports maps with OptimizedStructure (aka the \"Special\" folder). You can add this to your map at the insert page.", {Text = "Get Mapkit", Callback = function()
            Pages:ChangePage("Insert")
        end})
    end
end

return frame
