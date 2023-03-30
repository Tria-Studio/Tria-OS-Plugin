local Package = script.Parent.Parent.Parent

local PublicTypes = require(Package.PublicTypes)
local Components = require(Package.Resources.Components)
local Fusion = require(Package.Resources.Fusion)
local Util = require(Package.Util)
local Dropdown = require(script.Parent)

local Value = Fusion.Value
local Ref = Fusion.Ref
local Spring = Fusion.Spring
local Children = Fusion.Children
local New = Fusion.New
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed

local DropdownComponents = {}

function DropdownComponents.DropdownButton(props: PublicTypes.Dictionary): Instance
    local arrowButton = Value()
    local dropdownVisible = Value(false)

    return Components.ImageButton {
        AnchorPoint = Vector2.new(1, 0),
        Active = Util.interfaceActive,
        Position = props.Position,
        Size = props.Size,

        [Ref] = arrowButton,

        [Children] = {
            Components.Constraints.UIAspectRatio(1),
            New "ImageLabel" {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031094687",
                Rotation = Spring(Computed(function(): number
                    return dropdownVisible:get() and 0 or 180
                end), 20),
                ZIndex = Computed(function(): number
                    return Util._showArrows:get() and 8 or 1
                end),
            }
        },

        [OnEvent "Activated"] = function() 
            if not dropdownVisible:get() then
                dropdownVisible:set(true)
                local newData = Dropdown:GetValue(props.Options, arrowButton:get())
                if newData and props.OnToggle then
                    props.OnToggle(newData)
                end
                dropdownVisible:set(false)
            else
            	Dropdown:Cancel()
            end
        end
    }
end

return DropdownComponents
