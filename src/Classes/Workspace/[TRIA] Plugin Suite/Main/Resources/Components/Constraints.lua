local Package = script.Parent.Parent
local Fusion = require(Package.Fusion)
local New = Fusion.New

local Constraints = {}

function Constraints.UIListLayout(fillDirection: Enum.FillDirection?, horizontalAlignment: Enum.HorizontalAlignment?, padding: UDim?, verticalAlignment: Enum.VerticalAlignment?, sortOrder: Enum.SortOrder?): Instance
    return New "UIListLayout" {
        Padding = padding,
        FillDirection = fillDirection,
        HorizontalAlignment = horizontalAlignment,
        VerticalAlignment = verticalAlignment,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
    }
end

function Constraints.UIAspectRatio(aspectRatio: number, aspectType: Enum.AspectType?): Instance
    return New "UIAspectRatioConstraint" {
        AspectRatio = aspectRatio,
        AspectType = aspectType
    }
end

function Constraints.UIPadding(top: UDim?, bottom: UDim?, left: UDim?, right: UDim?): Instance
    return New "UIPadding" {
        PaddingTop = top,
        PaddingBottom = bottom,
        PaddingLeft = left,
        PaddingRight = right,
    }
end

function Constraints.UISizeConstraint(minSize: Vector2?, maxSize: Vector2?): Instance
    return New "UISizeConstraint" {
        MinSize = minSize,
        MaxSize = maxSize
    }
end

function Constraints.UIStroke(thickness: number?, color: Color3, strokeMode: Enum.ApplyStrokeMode?, transparency: number?): Instance
	return New "UIStroke" {
		ApplyStrokeMode = strokeMode,
		Thickness = thickness,
		Color = color,
		Transparency = transparency
	}
end

function Constraints.UICorner(scale: number, offset: number): Instance
	return New "UICorner" {
		CornerRadius = UDim.new(scale, offset)
	}
end

function Constraints.UIGradient(color: ColorSequence?, transparency: NumberSequence?, rotation: number?, enabled: any?): Instance
	return New "UIGradient" {
		Color = color,
        Enabled = enabled,
		Rotation = rotation,
		Transparency = transparency
	}
end

function Constraints.UIGridLayout(cellSize: UDim2, cellPadding: UDim2, fillDirection: Enum.FillDirection, horizontalAlignment: Enum.HorizontalAlignment): Instance
	return New "UIGridLayout" {
		CellSize = cellSize,
		CellPadding = cellPadding,
		FillDirection = fillDirection,
        HorizontalAlignment = horizontalAlignment,
        SortOrder = Enum.SortOrder.LayoutOrder
	}
end

function Constraints.UIPageLayout(tweenTime: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, padding: UDim?, circular: boolean?, sortOrder: Enum.SortOrder?): Instance
    return New "UIPageLayout" {
        TweenTime = tweenTime,
        EasingStyle = easingStyle,
        EasingDirection = easingDirection,
        Circular = circular,
        Padding = padding,
        ScrollWheelInputEnabled = false,
        SortOrder = sortOrder
    }
end

return Constraints
