--[[
    TODO
     - [ ] bug where liquids get parented to the Interactables folder instead of the liquids folder
     - [ ] make selecting the data tag object count as selecting the part/model
]]

local Package = script.Parent.Parent
local TagData = require(Package.Pages.ObjectTags.tagData)
local Util = require(script.Parent)
local PublicTypes = require(Package.PublicTypes)

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
    boolean = Enum.TriStateBoolean.False,
}

local function getTagInstance(part: Instance, tag: string): Instance | nil
    for _, child in ipairs(part:GetChildren()) do
        if string.find(child.Name, tag, 1, true) then
            return child
        end
    end
    return nil
end

function tagUtils:GetPartTags(part: Instance, excludeTag: string): {string}
    local partTags = {}
    for tagType, tags in pairs(tagTypes) do
        for key, tag in ipairs(tags) do
            if key ~= "_convert" and tagUtils:PartHasTag(part, tag) and tag ~= excludeTag and not table.find(partTags, tag) then
                table.insert(partTags, tag)
            end
        end
    end
    return partTags
end

function tagUtils:SetPartMetaData(part: Instance, tag: string, metadata: PublicTypes.dictionary, newValue: any)
    if table.find(tagTypes.ModelTags, tag) then
        part = part:IsA("Model") and part or part.Parent
    end

    local types = {}

    if newValue then --// Assign or Change
        function types.Attribute()
            part:SetAttribute(metadata.data.dataName, newValue)
        end

        function types.ConfigAttribute()
            local customization = part:FindFirstChild("Customization")
            customization:SetAttribute(metadata.data.dataName, newValue)
        end

        function types.ChildInstanceValue() 
            local tagInstance = getTagInstance(part, tag)

            if newValue ~= 0 then
                if not tagInstance:FindFirstChild("_Delay") then
                    local newValue = Instance.new("NumberValue", tagInstance)
                    newValue.Name = "_Delay"
                end
                tagInstance._Delay.Value = newValue
            elseif tagInstance and tagInstance:FindFirstChild("_Delay") then
                tagInstance:FindFirstChild("_Delay").Parent = nil
            end
        end

        function types.Property()
            local tagInstance = getTagInstance(part, tag)

            if tagInstance then
                tagInstance[metadata.data._propertyName] = newValue
            end
        end

        function types.EndOfName()
            local tagInstance = getTagInstance(part, tag)

            if tagInstance then
                tagInstance.Name = (TagData.dataTypes.buttonTags[tag] or TagData.dataTypes.objectTags[tag])._nameStub .. newValue or 0
            end
        end
    else --// Clear
        function types.Attribute()
            part:SetAttribute(metadata.data.dataName, nil)
        end

        function types.ConfigAttribute()
            local customization = part:FindFirstChild("Customization")
            customization:SetAttribute(metadata.data.dataName, nil)
        end

        function types.ChildInstanceValue()
            if part:FindFirstChild(metadata.data.dataName) then
                part:FindFirstChild(metadata.data.dataName).Parent = nil
            end
        end

        function types.Property()
            
        end

        function types.EndOfName()
            part.Name = part.ClassName
        end
    end

    types[metadata.data.type]()
end

function tagUtils:GetPartMetaData(part: Instance, name: string, tag: any): any
    if table.find(tagTypes.ModelTags, name) then
        part = part:IsA("Model") and part or part.Parent
    end

    local data = TagData.metadataTypes[tag]
    local mainData = TagData.dataTypes.buttonTags[name] or TagData.dataTypes.objectTags[name]
    local types = {}

    function types.Attribute()
        return part:GetAttribute(data.dataName) or defaultMetadataTypes[data.dataType]
    end

    function types.ConfigAttribute()
        local customization = part:FindFirstChild("Customization")
        return customization and customization:GetAttribute(data.dataName)
    end

    function types.ChildInstanceValue()
        local child = getTagInstance(part, name)
        if child then 
            return child:FindFirstChild("_Delay") and child._Delay.Value
        end
    end

    function types.Property()
        local sound = part:FindFirstChildOfClass("Sound") or part.Parent:FindFirstChildOfClass("Sound")
        return sound and sound[data._propertyName]
    end

    function types.EndOfName() 
        local tagInstance = getTagInstance(part, name)
        return tagInstance
            and string.sub(tagInstance.Name, #mainData._nameStub + 1)
            or string.sub(part.Name, #mainData._nameStub + 1)
    end

    return types[data.type]()
end

function tagUtils:GetSelectedMetadataValue(name: string, tag: string): any
    local metaDataData = TagData.metadataTypes[tag]
    local firstValue
    local numHas = 0

    for _, part: Instance in ipairs(Util._Selection.selectedParts:get()) do
        local tagData = tagUtils:GetPartMetaData(part, name, tag)
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

function tagUtils:SetPartTag(part: Instance, newTag: string?, oldTag: string)
    local currentMap = Util.mapModel:get(false)
    local function verifyFolder(folderName: string?)
        if not currentMap:FindFirstChild(folderName or "Geometry") then
            local newFolder = Instance.new("Folder", currentMap)
            newFolder.Name = folderName or "Geometry"
        end
    end

    local isOptimized = currentMap:FindFirstChild("Special")
    local tagData = TagData.dataTypes.objectTags[newTag or oldTag] or TagData.dataTypes.buttonTags[newTag or oldTag]
    local methods = {}

    if not newTag then --// Clear tag
        local otherTags = tagUtils:GetPartTags(part, oldTag)
        local currentMap = Util.mapModel:get(false)

        function methods._Action()
            if isOptimized then
                verifyFolder()
            end
            part:SetAttribute("_action", nil)
            part.Parent = if isOptimized and #otherTags == 0 then currentMap.Geometry else part.Parent
        end

        function methods.Name()
            if isOptimized then
                verifyFolder()
            end
            part.Name = part.ClassName
            part.Parent = if isOptimized and #otherTags == 0 then currentMap.Geometry else part.Parent
        end

        function methods.DetailParent()
            verifyFolder()
            part.Parent = currentMap.Geometry
        end

        function methods.Child()
            if isOptimized then
                verifyFolder()
            end
            for _, child in ipairs(part:GetChildren()) do
                if string.find(child.Name, oldTag, 1, true) then
                    child.Parent = nil
                end
            end
            part.Parent = if isOptimized and #otherTags == 0 then currentMap.Geometry else part.Parent
        end

        local tagData = TagData.dataTypes.buttonTags[oldTag] or TagData.dataTypes.objectTags[oldTag]
        for _, metaData in ipairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, oldTag, metaData, nil)
        end

        local applyMethods = typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod or {tagData.ApplyMethod}
        for _, method in pairs(applyMethods) do
            methods[method]()
        end
    else --// Assign new tag
        local newParent = 
            if isOptimized and table.find(tagTypes.ButtonTags, newTag) and isOptimized:FindFirstChild("Button") then isOptimized.Button
            elseif newTag == "_Liquid" or newTag == "_Gas" and isOptimized:FindFirstChild("Fluid") then isOptimized.Fluid
            elseif isOptimized:FindFirstChild("Interactable") then isOptimized.Interactable
            else part.Parent

        function methods._Action()
            verifyFolder()
            part:SetAttribute("_action", tagData.ActionText or newTag)
            part.Parent = newParent
        end

        function methods.Name()
            verifyFolder()
            local tagInstance = getTagInstance(part, newTag) or part
            tagInstance.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            part.Parent = newParent
        end

        function methods.DetailParent()
            verifyFolder("Detail")
            part.Parent = currentMap.Detail
        end

        function methods.Child()
            verifyFolder()
            local newChild = Instance.new(tagData._instanceType or "ObjectValue")
            
            newChild.Name = string.format("%s%s", newTag, table.find(tagsWithNumbers, newTag) and "1" or "")
            newChild.Parent = part
            part.Parent = newParent
        end

        local tagData = TagData.dataTypes.buttonTags[newTag] or TagData.dataTypes.objectTags[newTag]
        for _, metaData in ipairs(tagData.metadata) do
            tagUtils:SetPartMetaData(part, newTag, metaData, metaData.data.default)
        end
    end

    methods[typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod[1] or tagData.ApplyMethod]()
end

function tagUtils:PartHasTag(part: Instance, tag: string): boolean
    local types = {}

    function types.ButtonTags()
        for _, child in ipairs(part:GetChildren()) do
            if string.find(child.Name, tag.."%d") then
                return true
            end
         end
    end

    function types.ObjectTags()
        local secondary = tagTypes.ObjectTags._convert[tag]
        if string.find(part.Name, tag, 1, true) or part:FindFirstChild(tag) or secondary and (string.find(part.Name, secondary, 1, true) or part:FindFirstChild(secondary)) then
            return true
        end
    end

    function types.ActionTags()
        local secondary = tagTypes.ActionTags._convert[tag]
        if part:GetAttribute("_action") == tag or part:GetAttribute("_action") == secondary or part:GetAttribute("_action") == TagData.dataTypes.objectTags[tag].ActionText then
            return true
        end
    end

    function types.ModelTags()
        local secondary = tagTypes.ModelTags._convert[tag]
        local model = if part:IsA("Model") then part
            elseif part.Parent and part.Parent:IsA("Model") then part.Parent
            else nil

        if model and (string.find(model.Name, tag, 1) or secondary and string.find(model.Name, secondary, 1)) then
            return true
        end
    end

    function types.DetailTag()
        local DetailFolder = Util.mapModel:get(false) and Util.mapModel:get(false):FindFirstChild("Detail")
        return DetailFolder and part:IsDescendantOf(DetailFolder)
    end

    for type, tags in pairs(tagTypes) do
        if table.find(tags, tag) and types[type]() then
            return true
        end
    end

    return false
end

function tagUtils:PartsHaveTag(parts: {[number]: Instance}, tag: string): Enum.TriStateBoolean
    local numYes = 0
    for _, part in ipairs(parts) do
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
