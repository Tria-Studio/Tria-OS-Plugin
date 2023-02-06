--[[
    TODO
     - [ ] bug where liquids get parented to the Interactables folder instead of the liquids folder
     - [ ] make selecting the data tag object count as selecting the part/model
]]
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

local defaultMetadataTypes = {
    number = 0,
    color = Color3.new(),
    string = "",
    boolean = Enum.TriStateBoolean.Unknown,

}


local function getTagInstance(part, tag)
    for _, Child in pairs(part:GetChildren()) do
        if string.find(Child.Name, tag, 1, true) then
            return Child
        end
    end
end

function tagUtils:GetPartTags(part: Instance, excludeTag: string?)
    local partTags = {}

    for Type, tags in pairs(tagTypes) do
        for i, tag in pairs(tags) do
            if i ~= "_convert" and tagUtils:PartHasTag(part, tag) and tag ~= excludeTag and not table.find(partTags, tag) then
                table.insert(partTags, tag)
            end
        end
    end

    return partTags
end

function tagUtils:SetPartMetaData(part, tag, metadata, newValue)
    if table.find(tagTypes.ModelTags, tag) then
        part = part:IsA("Model") and part or part.Parent
    end
    local Types = {}

    if newValue then --// Assign or Change
        function Types.Attribute()
            part:SetAttribute(metadata.data.dataName, newValue)
        end

        function Types.ConfigAttribute()
            part:FindFirstChild("Customization"):SetAttribute(metadata.data.dataName, newValue)
        end

        function Types.ChildInstanceValue() --// Just _Delay (i hate _delay its so hard to SUPPORT BSDKHFKDSHFKHSDHHFSDHKFGSHKFDSHKFGKHSHKSDKFkl)
            local TagInstance = getTagInstance(part, tag)

            if newValue ~= 0 then
                if not TagInstance:FindFirstChild("_Delay") then
                    local newValue = Instance.new("NumberValue", TagInstance)
                    newValue.Name = "_Delay"
                end

                TagInstance._Delay.Value = newValue
            elseif TagInstance and TagInstance:FindFirstChild("_Delay") then
                TagInstance:FindFirstChild("_Delay").Parent = nil
            end
        end

        function Types.Property() --// Just _Sound
            local TagInstance = getTagInstance(part, tag)

            if TagInstance then
                TagInstance[metadata.data._propertyName] = newValue
            end
        end

        function Types.EndOfName() --// Button, Liquid, & Gas
            local TagInstance = getTagInstance(part, tag)

            if TagInstance then
                TagInstance.Name = (TagData.dataTypes.buttonTags[tag] or TagData.dataTypes.objectTags[tag])._nameStub .. newValue or 0
            end
        end
    else --// Clear
        function Types.Attribute()
            part:SetAttribute(metadata.data.dataName, nil)
        end

        function Types.ConfigAttribute()
            part:FindFirstChild("Customization"):SetAttribute(metadata.data.dataName, nil)
        end

        function Types.ChildInstanceValue() --// Just _Delay (i hate _delay its so hard to SUPPORT BSDKHFKDSHFKHSDHHFSDHKFGSHKFDSHKFGKHSHKSDKFkl)
            if part:FindFirstChild(metadata.data.dataName) then
                part:FindFirstChild(metadata.data.dataName).Parent = nil
            end
        end

        function Types.Property()
            
        end

        function Types.EndOfName()
            part.Name = part.ClassName
        end
    end

    Types[metadata.data.type]()
end

function tagUtils:GetPartMetaData(part, name, tag)
    if table.find(tagTypes.ModelTags, name) then
        part = part:IsA("Model") and part or part.Parent
    end
    local data = TagData.metadataTypes[tag]
    local mainData = TagData.dataTypes.buttonTags[name] or TagData.dataTypes.objectTags[name]
    local Types = {}

    function Types.Attribute()
        return part:GetAttribute(data.dataName)
    end

    function Types.ConfigAttribute()
        return part:FindFirstChild("Customization"):GetAttribute(data.dataName)
    end

    function Types.ChildInstanceValue() --// Just _Delay (i hate _delay its so hard to SUPPORT BSDKHFKDSHFKHSDHHFSDHKFGSHKFDSHKFGKHSHKSDKFkl)
        local Child = getTagInstance(part, name)
        if Child then 
            return Child:FindFirstChild("_Delay") and Child._Delay.Value
        end
    end

    function Types.Property() --// Just _Sound
        local Sound = part:FindFirstChildOfClass("Sound") or part.Parent:FindFirstChildOfClass("Sound")
        return Sound and Sound[data._propertyName]
    end

    function Types.EndOfName() --// Button, Liquid, & Gas
        local TagInstance = getTagInstance(part, name)
        return TagInstance
            and string.sub(TagInstance.Name, #mainData._nameStub + 1)
            or string.sub(part.Name, #mainData._nameStub + 1)
    end

    return Types[data.type]()
end

function tagUtils:GetSelectedMetadataValue(name, tag)
    local metaDataData = TagData.metadataTypes[tag]
    local firstValue
    local numHas = 0

    for _, Part: Instance in pairs(Util._Selection.selectedParts:get()) do
        local tagData = tagUtils:GetPartMetaData(Part, name, tag)
        if firstValue == nil and tagData ~= nil then
            firstValue = tagData
        end
        if tagData == firstValue and tagData ~= nil then
            numHas += 1
        elseif numHas > 0 then
            return ""
        end
    end

    return if numHas == #Util._Selection.selectedParts:get()
        then firstValue == false and Enum.TriStateBoolean.False or firstValue
        else metaDataData.hideWhenNil and "" or defaultMetadataTypes[TagData.metadataTypes[tag].dataType]
end

function tagUtils:SetPartTag(part: Instance, newTag: string?, oldTag: string?)
    local function VerifyFolder(Name: string?)
        if not Util.mapModel:get():FindFirstChild(Name or "Geometry") then
            Instance.new("Folder", Util.mapModel:get()).Name = Name or "Geometry"
        end
    end

    local isOptimized = Util.mapModel:get():FindFirstChild("Special")
    local tagData = TagData.dataTypes.objectTags[newTag or oldTag] or TagData.dataTypes.buttonTags[newTag or oldTag]
    local Methods = {}

    if not newTag then --// Clear tag
        local OtherTags = tagUtils:GetPartTags(part, oldTag)

        function Methods._Action()
            if isOptimized then
                VerifyFolder()
            end
            part:SetAttribute("_action", nil)
            part.Parent = if isOptimized and #OtherTags == 0 then Util.mapModel:get().Geometry else part.Parent
        end

        function Methods.Name()
            if isOptimized then
                VerifyFolder()
            end
            part.Name = part.ClassName
            part.Parent = if isOptimized and #OtherTags == 0 then Util.mapModel:get().Geometry else part.Parent
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
            part.Parent = if isOptimized and #OtherTags == 0 then Util.mapModel:get().Geometry else part.Parent
        end

        local tagData = TagData.dataTypes.buttonTags[oldTag] or TagData.dataTypes.objectTags[oldTag]
        for _, metaData in pairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, oldTag, metaData, nil)
        end

        local methods = typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod or {tagData.ApplyMethod}
        for _, method in  pairs(methods) do
            Methods[method]()
        end
    else --// Assign new tag
        local NewParent = if isOptimized and table.find(tagTypes.ButtonTags, newTag) and isOptimized:FindFirstChild("Button")
            then isOptimized.Button
            elseif newTag == "_Liquid" or newTag == "_Gas" and isOptimized:FindFirstChild("Fluid") then isOptimized.Fluid
            elseif isOptimized:FindFirstChild("Interactable") then isOptimized.Interactable
            else part.Parent

        function Methods._Action()
            VerifyFolder()
            part:SetAttribute("_action", tagData.ActionText or newTag)
            part.Parent = NewParent
        end

        function Methods.Name()
            VerifyFolder()
            local TagInstance = getTagInstance(part, newTag) or part
            TagInstance.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            part.Parent = NewParent
        end

        function Methods.DetailParent()
            VerifyFolder("Detail")
            part.Parent = Util.mapModel:get().Detail
        end

        function Methods.Child()
            VerifyFolder()
            local newChild = Instance.new(tagData._instanceType or "ObjectValue")
            
            newChild.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            newChild.Parent = part
            part.Parent = NewParent
        end

        local tagData = TagData.dataTypes.buttonTags[newTag] or TagData.dataTypes.objectTags[newTag]
        for _, metaData in pairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, newTag, metaData, metaData.data.default)
        end
    end

    Methods[typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod[1] or tagData.ApplyMethod]()
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
        if part:GetAttribute("_action") == tag or part:GetAttribute("_action") == secondary or part:GetAttribute("_action") == TagData.dataTypes.objectTags[tag].ActionText then
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
