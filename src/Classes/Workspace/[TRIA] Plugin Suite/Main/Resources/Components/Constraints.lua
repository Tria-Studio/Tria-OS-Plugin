local Package = script.Parent.Parent
local Fusion = require(Package.Fusion)
local New = Fusion.New

local Constraints = {}

function Constraints.UIListLayout(FillDirection: Enum.FillDirection, HorizontalAlignment: Enum.HorizontalAlignment, Padding: UDim?, VerticalAlignment: Enum.VerticalAlignment?)
    return New "UIListLayout" {
        Padding = Padding,
        FillDirection = FillDirection,
        HorizontalAlignment = HorizontalAlignment,
        VerticalAlignment = VerticalAlignment,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }
end

function Constraints.UIAspectRatio(AspectRatio: number, AspectType: Enum.AspectType)
    return New "UIAspectRatioConstraint" {
        AspectRatio = AspectRatio,
        AspectType = AspectType
    }
end

function Constraints.UIPadding(Top: UDim?, Bottom: UDim?, Left: UDim?, Right: UDim?)
    return New "UIPadding" {
        PaddingTop = Top,
        PaddingBottom = Bottom,
        PaddingLeft = Left,
        PaddingRight = Right,
    }
end

function Constraints.UISizeConstraint(MinSize: Vector2?, MaxSize: Vector2?)
    return New "UISizeConstraint" {
        MinSize = MinSize,
        MaxSize = MaxSize
    }
end

function Constraints.UIStroke(Thickness: number, Color: Color3, StrokeMode: Enum.ApplyStrokeMode?, Transparency: number?)
	return New "UIStroke" {
		ApplyStrokeMode = StrokeMode,
		Thickness = Thickness,
		Color = Color,
		Transparency = Transparency
	}
end

function Constraints.UICorner(Scale: number, Offset: number)
	return New "UICorner" {
		CornerRadius = UDim.new(Scale, Offset)
	}
end

function Constraints.UIGradient(Color: ColorSequence?, Transparency: NumberSequence?, Rotation: number?)
	return New "UIGradient" {
		Color = Color,
		Rotation = Rotation,
		Transparency = Transparency
	}
end

function Constraints.UIGridLayout(CellSize: UDim2, CellPadding: UDim2, FillDirection: Enum.FillDirection)
	return New "UIGridLayout" {
		CellSize = CellSize,
		CellPadding = CellPadding,
		FillDirection = FillDirection,
	}
end

return Constraints
