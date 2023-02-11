local Package = script.Parent.Parent
local Fusion = require(Package.Resources.Fusion)
local Theme = require(Package.Resources.Themes)
local Components = require(Package.Resources.Components)

local New = Fusion.New
local Children = Fusion.Children

local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,
        Name = "Compatibility",

        [Children] = {
            Components.PageHeader("Scripting")
        }
    }
end

return frame
