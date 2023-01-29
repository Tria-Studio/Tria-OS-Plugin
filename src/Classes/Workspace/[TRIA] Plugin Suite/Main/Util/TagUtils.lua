local ChangeHistoryService = game:GetService("ChangeHistoryService")

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
        "_Gas",

        _convert = {
            _Liquid = "_Liquid%d",
            _Gas = "_Gas%d",
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
local tagsWithNumbers = {
    "_Button",
    "_Gas",
    "_Liquid",
    "_Show",
    "_Hide",
    "_Fall",
    "_Explode",
    "_Destroy",
    "_Sound",
}

function tagUtils:SetPartMetaData(part, metadata, newValue)
    local Types = {}

    if newValue then --// Assign or Change
        function Types.Attribute()
                
        end

        function Types.ConfigAttribute()
            
        end

        function Types.ChildInstanceValue()
            
        end

        function Types.EndOfName()
            
        end
    else --// Clear
        function Types.Attribute()
            part:SetAttribute(metadata.dataName, nil)
        end

        function Types.ConfigAttribute()
            part:FindFirstChild("Customization"):SetAttribute(metadata.dataName, nil)
        end

        function Types.ChildInstanceValue()
            
        end

        function Types.EndOfName()
            
        end
    end
    print(metadata)
    Types[metadata.type]()
end

function tagUtils:SetPartTag(part: Instance, newTag: string?, oldTag: string?)
    local function VerifyFolder(Name: string?)
        if not Util.mapModel:get():FindFirstChild(Name or "Geometry") then
            Instance.new("Folder", Util.mapModel:get()).Name = Name or "Geometry"
        end
    end
    --[[
        Issues:
         - [ ] Clearing tag doesnt remove its metadata
         - [ ] Doesnt assign default metadata
         - [x] Doesnt support optimized structure
    ]]
    local isOptimized = Util.mapModel:get():FindFirstChild("Special")
    local tagData = TagData.dataTypes.objectTags[newTag or oldTag] or TagData.dataTypes.buttonTags[newTag or oldTag]
    local Methods = {}

    if not newTag then --// Clear tag
        function Methods._Action()
            if isOptimized then
                VerifyFolder()
            end
            part:SetAttribute("_action", nil)
            part.Parent = if isOptimized then Util.mapModel:get().Geometry else part.Parent
        end

        function Methods.Name()
            if isOptimized then
                VerifyFolder()
            end
            part.Name = part.ClassName
            part.Parent = if isOptimized then Util.mapModel:get().Geometry else part.Parent
        end
        function Methods.DetailParent()
            VerifyFolder()
            part.Parent = Util.mapModel:get().Geometry
        end
        function Methods.Child()
            if isOptimized then
                VerifyFolder()
            end
            for _, Child in pairs(part:GetChildren()) do
                if string.find(Child.Name, oldTag, 1, true) then
                    Child.Parent = nil
                end
            end
            part.Parent = if isOptimized then Util.mapModel:get().Geometry else part.Parent
        end

        local tagData = TagData.dataTypes.buttonTags[oldTag] or TagData.dataTypes.objectTags[oldTag]
        for _, metaData in pairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, metaData, nil)
        end
    else --// Assign new tag
        function Methods._Action()
            VerifyFolder()
            part:SetAttribute("_action", newTag)
            part.Parent = if isOptimized and isOptimized:FindFirstChild("Interactable") then isOptimized.Interactable else part.Parent
        end

        function Methods.Name()
            VerifyFolder()
            part.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            part.Parent = if isOptimized and isOptimized:FindFirstChild("Fluid") then isOptimized.Interactable else part.Parent
        end
        function Methods.DetailParent()
            VerifyFolder("Detail")
            part.Parent = Util.mapModel:get().Detail
        end
        function Methods.Child()
            VerifyFolder()

            local newChild = Instance.new("ObjectValue")
            newChild.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            newChild.Parent = part
            part.Parent = if isOptimized and isOptimized:FindFirstChild("Button") then isOptimized.Interactable else part.Parent
        end

        local tagData = TagData.dataTypes.buttonTags[newTag] or TagData.dataTypes.objectTags[newTag]
        for _, metaData in pairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, metaData, metaData.default)
        end
    end

    local method = typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod[1] or tagData.ApplyMethod
    Methods[method]()
end

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

        if numYes > 0 and not value then
            return Enum.TriStateBoolean.Unknown
        end
    end

    return #parts == numYes and Enum.TriStateBoolean.True
        or numYes == 0 and Enum.TriStateBoolean.False
        or Enum.TriStateBoolean.Unknown
end

return tagUtils
