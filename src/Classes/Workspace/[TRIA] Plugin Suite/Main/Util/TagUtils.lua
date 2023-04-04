local Package = script.Parent.Parent
local Players = game:GetService("Players")

local Fusion = require(Package.Resources.Fusion)
local TagData = require(Package.Pages.ObjectTags.TagData)
local Util = require(script.Parent)
local PublicTypes = require(Package.PublicTypes)

local Value = Fusion.Value

local mapDescendants = {}
local mapDescendantsUpdate = 0

local tagAddedSignals = {}
local tagRemovedSignals = {}
local tagUtils = {
	OnlyShowUpdate = Value(0),
}

local ImmutableTags = {
	"_WallRun",
	"_WallJump",
	"_Liquid",
	"_Gas",
	"_Kill",
	"Zipline",
	"AirTank",
}
local newTagTypes = {
	_Show = { "ButtonTags" },
	_Hide = { "ButtonTags" },
	_Fall = { "ButtonTags" },
	_Explode = { "ButtonTags" },
	_Destroy = { "ButtonTags" },
	_Sound = { "ButtonTags" },
	_WallRun = { "ObjectTags", "ActionTags" },
	_WallJump = { "ObjectTags", "ActionTags" },
	_Liquid = { "ObjectTags" },
	_Gas = { "ObjectTags" },
	_SpeedBooster = { "ActionTags" },
	_JumpBooster = { "ActionTags" },
	_Kill = { "ActionTags" },
	Detail = { "DetailTag" },
	Zipline = { "ModelTags" },
	_Button = { "ModelTags" },
	AirTank = { "ModelTags" },
	_Teleporter = { "AddonTags" },
	_Waterjet = { "AddonTags" },
}
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
		},
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
			_WallRun = "WallRun",
		},
	},
	DetailTag = { --// Parented to the detail folder
		"Detail",
	},
	ModelTags = { --// They are a model named this and stuff
		"Zipline",
		"_Button",
		"AirTank",

		_convert = {
			_Button = "_Button%d",
		},
	},
	AddonTags = {
		"_Teleporter",
		"_Waterjet",
	},
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
	"_Waterjet",
}

local defaultMetadataTypes = {
	number = 0,
	color = Color3.new(),
	string = "",
	boolean = Enum.TriStateBoolean.False,
}

function tagUtils:GetTagInstance(part: Instance, tag: string): Instance | nil
	if part.Parent ~= game then
		for _, child in ipairs(part:GetChildren()) do
			if string.find(child.Name, tag, 1, true) then
				return child
			end
		end
	end
	return nil
end

function tagUtils:GetPartTags(part: Instance, excludeTag: string?): { string }
	local partTags = {}
	for tagType, tags in pairs(tagTypes) do
		for key, tag in ipairs(tags) do
			if
				key ~= "_convert"
				and tagUtils:PartHasTag(part, tag)
				and tag ~= excludeTag
				and not table.find(partTags, tag)
			then
				table.insert(partTags, tag)

				if table.find(ImmutableTags, tag) then
					return partTags
				end
			end
		end
	end
	return partTags
end

function tagUtils:SetPartMetaData(part: Instance, tag: string, metadata: PublicTypes.Dictionary, newValue: any)
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
			local tagInstance = tagUtils:GetTagInstance(part, tag)

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
			local tagInstance = tagUtils:GetTagInstance(part, tag) or part

			if tagInstance then
				tagInstance[metadata.data._propertyName] = newValue --TODO: this is broken
			end
		end

		function types.EndOfName()
			local tagInstance = tagUtils:GetTagInstance(part, tag) or part

			if tagInstance then
				tagInstance.Name = (
					TagData.dataTypes.buttonTags[tag]
					or TagData.dataTypes.objectTags[tag]
					or TagData.dataTypes.addonTags[tag]
				)._nameStub .. newValue or 0
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

		function types.Property() end

		function types.EndOfName()
			part.Name = part.ClassName
		end
	end

	types[metadata.data.type]()
	tagUtils.OnlyShowUpdate:set(tagUtils.OnlyShowUpdate:get(false) + 1)
end

function tagUtils:GetPartMetaData(part: Instance, name: string, tag: any): any
	if table.find(tagTypes.ModelTags, name) then
		part = part:IsA("Model") and part or part.Parent
	end

	local data = TagData.metadataTypes[tag]
	local mainData = TagData.dataTypes.buttonTags[name]
		or TagData.dataTypes.objectTags[name]
		or TagData.dataTypes.addonTags[name]
	local types = {}

	function types.Attribute(): any
		return part:GetAttribute(data.dataName) or defaultMetadataTypes[data.dataType]
	end

	function types.ConfigAttribute(): any
		local customization = part:FindFirstChild("Customization")
		return customization and customization:GetAttribute(data.dataName)
	end

	function types.ChildInstanceValue(): number?
		local child = tagUtils:GetTagInstance(part, name)
		if child then
			return child:FindFirstChild("_Delay") and child._Delay.Value
		end
		return
	end

	function types.Property(): any?
		local sound = part:FindFirstChildOfClass("Sound") or part.Parent:FindFirstChildOfClass("Sound")
		return sound and sound[data._propertyName]
	end

	function types.EndOfName(): string
		local tagInstance = tagUtils:GetTagInstance(part, name) or part
		return tagInstance and string.sub(tagInstance.Name, #mainData._nameStub + 1)
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

function tagUtils:SetPartTag(part: Instance, newTag: string?, oldTag: string?)
	local currentMap = Util.mapModel:get(false)
	local function verifyFolder(folderName: string?)
		if not currentMap:FindFirstChild(folderName or "Geometry") then
			local newFolder = Instance.new("Folder", currentMap)
			newFolder.Name = folderName or "Geometry"
		end
	end

	local isOptimized = currentMap:FindFirstChild("Special")
	local tagData = TagData.dataTypes.objectTags[newTag or oldTag]
		or TagData.dataTypes.buttonTags[newTag or oldTag]
		or TagData.dataTypes.addonTags[newTag or oldTag]
	local methods = {}

	if not newTag then --// Clear tag
		local otherTags = tagUtils:GetPartTags(part, oldTag)
		local currentMap = Util.mapModel:get(false)
		tagUtils.OnTagRemoved(oldTag):Fire(part)

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

		local tagData = TagData.dataTypes.buttonTags[oldTag]
			or TagData.dataTypes.objectTags[oldTag]
			or TagData.dataTypes.addonTags[oldTag]
		for _, metaData in ipairs(tagData.metadata) do
			tagUtils:SetPartMetaData(part, oldTag, metaData, nil)
		end

		local applyMethods = typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod or { tagData.ApplyMethod }
		for _, method in pairs(applyMethods) do
			methods[method]()
		end
	else --// Assign new tag
		local newParent = if isOptimized
				and table.find(tagTypes.ButtonTags, newTag)
				and isOptimized:FindFirstChild("Button")
			then isOptimized.Button
			elseif
				newTag == "_Liquid" or newTag == "_Gas" and isOptimized:FindFirstChild("Fluid")
			then isOptimized.Fluid
			elseif newTag == "_Teleporter" and isOptimized:FindFirstChild("Teleporters") then isOptimized.Teleporters
			elseif
				string.find(newTag, "_Waterjet", 1, true) and isOptimized:FindFirstChild("Waterjets")
			then isOptimized.Waterjets
			elseif isOptimized and isOptimized:FindFirstChild("Interactable") then isOptimized.Interactable
			else part.Parent

		function methods._Action()
			verifyFolder()
			part:SetAttribute("_action", tagData.ActionText or newTag)
			part.Parent = newParent
		end

		function methods.Name()
			verifyFolder()
			local tagInstance = tagUtils:GetTagInstance(part, newTag) or part
			tagInstance.Name = string.format(
				"%s%s",
				newTag,
				table.find(tagsWithNumbers, newTag)
						and tostring(Util.getObjectCountWithNameMatch(newTag, nil, true) + 1)
					or ""
			)
			part.Parent = newParent
		end

		function methods.DetailParent()
			verifyFolder("Detail")
			part.Parent = currentMap.Detail
		end

		function methods.Child()
			verifyFolder()
			local newChild = Instance.new(tagData._instanceType or "ObjectValue")

			newChild.Name = string.format(
				"%s%s",
				newTag,
				table.find(tagsWithNumbers, newTag)
						and tostring(Util.getObjectCountWithNameMatch(newTag, nil, true) + 1)
					or ""
			)
			newChild.Parent = part
			part.Parent = newParent
		end

		tagUtils.OnTagAdded(newTag):Fire(part)
		local tagData = TagData.dataTypes.buttonTags[newTag]
			or TagData.dataTypes.objectTags[newTag]
			or TagData.dataTypes.addonTags[newTag]
		for _, metaData in ipairs(tagData.metadata) do
			tagUtils:SetPartMetaData(part, newTag, metaData, metaData.data.default)
		end
	end

	methods[typeof(tagData.ApplyMethod) == "table" and tagData.ApplyMethod[1] or tagData.ApplyMethod]()
end

function tagUtils:PartHasTag(part: Instance, tag: string): boolean
	local types = {}

	function types.ButtonTags(): boolean?
		for _, child in ipairs(part:GetChildren()) do
			if string.find(child.Name, tag .. "%d") then
				return true
			end
		end
		return false
	end

	function types.ObjectTags(): boolean?
		local secondary = tagTypes.ObjectTags._convert[tag]
		if
			part:FindFirstChild(tag) and string.find(part.Name, tag, 1, true)
			or secondary and (string.find(part.Name, secondary, 1, true) or part:FindFirstChild(secondary))
		then
			return true
		end
		return false
	end

	function types.AddonTags(): boolean?
		return string.find(part.Name, tag, 1, true)
	end

	function types.ActionTags(): boolean?
		local secondary = tagTypes.ActionTags._convert[tag]
		local attribute = part:GetAttribute("_action")

		if attribute == tag or attribute == secondary or attribute == TagData.dataTypes.objectTags[tag].ActionText then
			return true
		end
		return false
	end

	function types.ModelTags(): boolean?
		local secondary = tagTypes.ModelTags._convert[tag]
		local model = if part:IsA("Model")
			then part
			elseif part.Parent and part.Parent:IsA("Model") then part.Parent
			else nil

		if model and (string.find(model.Name, tag, 1) or secondary and string.find(model.Name, secondary, 1)) then
			return true
		end
		return false
	end

	function types.DetailTag(): boolean?
		local detailFolder = Util.mapModel:get():FindFirstChild("Detail")
		return detailFolder and part:IsDescendantOf(detailFolder)
	end

	for _, type in pairs(newTagTypes[tag]) do
		if types[type]() then
			return true
		end
	end

	return false
end

function tagUtils:PartsHaveTag(parts: { [number]: Instance }, tag: string): Enum.TriStateBoolean
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

function tagUtils:GetPartsWithTag(tag: string, subTag: string?): { [number]: Instance }
	local Map = Util.mapModel:get()
	local Special = Map:FindFirstChild("Special")
	local CheckIfSpecial = {
		_Detail = Map:FindFirstChild("Detail"),
		_Show = Special and Special:FindFirstChild("Button"),
		_Hide = Special and Special:FindFirstChild("Button"),
		_Fall = Special and Special:FindFirstChild("Button"),
		_Sound = Special and Special:FindFirstChild("Button"),
		_Destroy = Special and Special:FindFirstChild("Button"),
		_Explode = Special and Special:FindFirstChild("Button"),
		_Button = Special and Special:FindFirstChild("Button"),
		Zipline = Special and Special:FindFirstChild("Zipline"),
		Variant = Special and Special:FindFirstChild("Variant"),
		_Liquid = Special and Special:FindFirstChild("Fluid"),
		_Gas = Special and Special:FindFirstChild("Fluid"),
	}

	local InstanceToCheck = CheckIfSpecial[subTag] or CheckIfSpecial[tag] or Map
	local partsFound = {}
	local studioQuality = settings().Rendering.QualityLevel.Value == 0 and 21 or settings().Rendering.QualityLevel.Value

	if
		Util._DebugView.viewsActiveUsingAll > 1
		and InstanceToCheck == Map
		and os.clock() - mapDescendantsUpdate > ((5 / (math.max(12, studioQuality) / 21)) * (1 + (Util._DebugView.activeDebugViews:get() / 8)) + (#Players:GetPlayers() == 1 and 10 or 0))
	then
		mapDescendantsUpdate = os.clock()
		local newParts = {}
		local counter = 0

		for i, part in pairs(Map:GetDescendants()) do
			counter += 1
			if counter == 1000 then
				task.wait()
			end
			if tagUtils:PartIsTagged(part) then
				table.insert(newParts, part)
			end
		end
		print("number of instances in map: ", #Map:GetDescendants())
		print("number of refined instances: ", #newParts)
		mapDescendants = newParts
	end

	if tag == "_Detail" then
		return InstanceToCheck and InstanceToCheck:GetDescendants() or {}
	elseif subTag == "Variant" then
		return InstanceToCheck and InstanceToCheck[tag:get()]:GetDescendants() or {}
	elseif tag == "Zipline" then
		return InstanceToCheck:GetChildren() or {}
	end

	local counter = 0
    local MapToCheck = (InstanceToCheck:GetDescendants() == Map and #mapDescendants > 0 and mapDescendants or Map:GetDescendants())
	for _, part in pairs(MapToCheck or InstanceToCheck:GetDescendants()) do
		counter += 1
		if counter == 100 then
			task.wait()
		end
		if (part:IsA("BasePart") or part:IsA("Model") or part:IsA("Folder")) and tagUtils:PartHasTag(part, tag) then
			table.insert(partsFound, part)
		end
	end

	return partsFound
end

function tagUtils:PartIsTagged(part: Instance): boolean
	if not (part:IsA("BasePart") or part:IsA("Model") or part:IsA("Folder")) then
		return false
	end

	local mapModel = Util.mapModel:get()

	if Util.hasSpecialFolder:get() and part:IsDescendantOf(mapModel.Special) then -- its safe to assume that most (if not all) parts inside the special folder have some kind of tag, if not it shouldnt be a large amount
		return true
	end

	if part:GetAttribute("_action") then
		return true
	end

	if newTagTypes[part.Name:gsub("%d", "")] then
		return true
	end

	if
		part:FindFirstChildOfClass("ValueBase")
		or part:FindFirstChildOfClass("Configuration")
		or part:FindFirstChildOfClass("Sound")
	then
		return true
	end
end

function tagUtils.OnTagRemoved(tagName: string)
	if not tagRemovedSignals[tagName] then
		tagRemovedSignals[tagName] = Util.Signal.new()
	end

	return tagRemovedSignals[tagName]
end

function tagUtils.OnTagAdded(tagName: string)
	if not tagAddedSignals[tagName] then
		tagAddedSignals[tagName] = Util.Signal.new()
	end

	return tagAddedSignals[tagName]
end

return tagUtils
