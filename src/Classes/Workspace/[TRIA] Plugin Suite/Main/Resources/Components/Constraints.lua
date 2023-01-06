local Fusion = require(script.Parent.Parent.Fusion)

local New = Fusion.New

local constraints = {}
local a:UIListLayout

function constraints.UIListLayout(FillDirection: Enum.FillDirection, HorizontalAlignment: Enum.HorizontalAlignment, Padding: UDim?)
    return New "UIListLayout" {
        Padding = Padding,
        FillDirection = FillDirection,
        HorizontalAlignment = HorizontalAlignment,
        SortOrder = Enum.SortOrder.LayoutOrder
    }
end

function constraints.UIAspectRatio(AspectRatio: number)
    return New "UIAspectRatioConstraint" {
        AspectRatio = AspectRatio
    }
end

function  constraints.UIPadding(Top: UDim?, Bottom: UDim?, Left: UDim?, Right: UDim?)
    return New "UIPadding" {
        PaddingTop = Top,
        PaddingBottom = Bottom,
        PaddingLeft = Left,
        PaddingRight = Right,
    }
end

return constraints
