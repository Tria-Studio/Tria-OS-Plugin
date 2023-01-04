local Fusion = require(script.Parent.Parent.Fusion)

local New = Fusion.New

local constraints = {}
local a:UIListLayout

function constraints.UIListLayout(FillDirection: Enum.FillDirection)
    return New "UIListLayout" {
        FillDirection = FillDirection,
        SortOrder = Enum.SortOrder.LayoutOrder
    }
end

function constraints.UIAspectRatio(AspectRatio: number)
    return New "UIAspectRatioConstraint" {
        AspectRatio = AspectRatio
    }
end

return constraints