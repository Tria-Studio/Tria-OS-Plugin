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
    },
    ActionTags = { --// _action attribute
        "_WallRun",
        "_WallJump",
        "_SpeedBooster",
        "_JumpBooster",
        "_Kill",
    },
    ModelTags = { --// They are a model named this and stuff
        "Zipline",
        "_Button",
        "AirTank"
    },
    DetailTag = { --// Parented to the detail folder
        "Detail"
    }
}
 
function tagUtils:PartHasTag(part: Instance, tag: string): boolean
    local Children = part:GetChildren()
    local firstAttempt
    local Types = {}

    function Types.ButtonTags()
        for _, Child in pairs(Children) do
            if string.find(Child.Name, tag, 1, true) and Child:IsA("ValueBase") then
                return true
            end
         end
    end
    Types.ObjectTags = Types.ButtonTags

    function Types.ActionTags()
        if part:GetAttribute("_action") == tag then
            return true
        end
    end

    function Types.ModelTags()
        if part:IsA("Model") and (part.Name == tag or string.find(part.Name, "_Button%d", 1)) then
            return true
        end
    end

    function Types.DetailTag()
        local DetailFolder = Util.mapModel:get() and Util.mapModel:get():FindFirstChild("Detail")
        return DetailFolder and part:IsDescendantOf(DetailFolder)
    end

    for i = 1, 2 do
       for type, tags in pairs(tagTypes) do
            if table.find(tags, tag) and firstAttempt ~= tag then
                firstAttempt = type
                local success = Types[type]()
                if success then
                    return true
                end
            end
       end 
    end
end

function tagUtils:PartsHaveTag(parts: {[number]: Instance}, tag: string): Enum.TriStateBoolean
    for _, part in pairs(parts) do
        if not tagUtils:PartHasTag(part, tag) then
            return false
        end
    end

    return Enum.TriStateBoolean.True
end

return tagUtils
