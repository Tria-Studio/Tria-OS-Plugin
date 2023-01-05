local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Theme = require(script.Parent.Parent.Parent.Themes)
local Components = require(script.Parent.Parent)

local New = Fusion.New
local State = Fusion.State
local Children = Fusion.Children



local frame = {}

function frame:GetFrame(data)
    return New "Frame" {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.MainBackground.Default,
        Visible = data.Visible,

        [Children] = {
            Components.PageHeader("Map Whitelisting & Publishing")
        }
    }
end

return frame