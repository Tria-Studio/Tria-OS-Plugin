local Package = script.Parent.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Theme = require(Resources.Themes)
local Components = require(Resources.Components)

local PublicTypes = require(Package.PublicTypes)

local New = Fusion.New
local Children = Fusion.Children

local frame = {}
 
function frame:GetFrame(data: PublicTypes.dictionary): Instance
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "ViewModes",

        [Children] = {
            Components.PageHeader("Audio Library")
        }
    }
end

return frame
