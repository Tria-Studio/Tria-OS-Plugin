local Package = script.Parent.Parent
local TagData = require(Package.Pages.ObjectTags.tagData)
local Util = require(script.Parent)

local tagUtils = {}
local tagTypes = {
    ButtonTags = { --// Child named tag but button
        "_Show",
		"_Hide",
		"_Fall",
		"_Explode",
		"_Destroy",
		"_Sound",
    },
    ObjectTags = { --// Child named tag
        "_WallRun",
        "_WallJump",
        "_Liquid",

        _convert = {
            _Liquid = "_Liquid%d"
        }
    },
    ActionTags = { --// _action attribute
        "_WallRun",
        "_WallJump",
        "_SpeedBooster",
        "_JumpBooster",
        "_Kill",
    
        _convert = {
            _SpeedBooster = "WalkSpeed",
            _JumpBooster = "JumpPower",
            _Kill = "Kill",
            _WallJump = "WallJump",
            _WallRun = "WallRun"
        }
    },
    ModelTags = { --// They are a model named this and stuff
        "Zipline",
        "_Button",
        "AirTank",

        _convert = {
            _Button = "_Button%d"
        }
    },
    DetailTag = { --// Parented to the detail folder
        "Detail"
    }
}
 
function tagUtils:PartHasTag(part: Instance, tag: string): boolean
    local Types = {}

    function Types.ButtonTags()
        for _, Child in pairs(part:GetChildren()) do
            if string.find(Child.Name, tag.."%d") then
                return true
            end
         end
    end
    function Types.ObjectTags()
        local secondary = tagTypes.ObjectTags._convert[tag]
        print(tag, secondary)
        if string.find(part.Name, tag, 1, true) or part:FindFirstChild(tag) or secondary and (string.find(part.Name, secondary, 1, true) or part:FindFirstChild(secondary)) then
            return true
        end
    end

    function Types.ActionTags()
        local secondary = tagTypes.ActionTags._convert[tag]
        if part:GetAttribute("_action") == tag or part:GetAttribute("_action") == secondary then
            return true
        end
    end

    function Types.ModelTags()
        local secondary = tagTypes.ModelTags._convert[tag]
        local model = if part:IsA("Model") then part
            elseif part.Parent:IsA("Model") then part.Parent
            else nil

        if model and (string.find(model.Name, tag, 1) or secondary and string.find(model.Name, secondary, 1)) then
            return true
        end
    end

    function Types.DetailTag()
        local DetailFolder = Util.mapModel:get(false) and Util.mapModel:get(false):FindFirstChild("Detail")
        return DetailFolder and part:IsDescendantOf(DetailFolder)
    end

    for type, tags in pairs(tagTypes) do
        if table.find(tags, tag) and Types[type]() then
            return true
        end
    end 
end

function tagUtils:PartsHaveTag(parts: {[number]: Instance}, tag: string): Enum.TriStateBoolean
    local numYes = 0
    for _, part in pairs(parts) do
        local value = tagUtils:PartHasTag(part, tag)
        numYes += if value then 1 else 0
    end

    return #parts == numYes and Enum.TriStateBoolean.True
        or numYes == 0 and Enum.TriStateBoolean.False
        or Enum.TriStateBoolean.Unknown
end

return tagUtils
