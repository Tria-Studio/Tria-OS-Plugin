local Fusion = require(script.Parent.Parent.Resources.Fusion)
local Theme = require(script.Parent.Parent.Resources.Themes)
local Components = require(script.Parent.Parent.Resources.Components)

local New = Fusion.New
local Children = Fusion.Children



local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,

        [Children] = {
            Components.PageHeader("Compatibility & MapScript")
        }
    }
end

return frame