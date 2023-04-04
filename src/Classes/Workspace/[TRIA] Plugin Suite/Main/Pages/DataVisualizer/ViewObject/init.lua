local Players = game:GetService("Players")
--[[
    The instance that will be in charge of creating the view mode "object" for a type of thing.

    CALLS:

    new() - creates it

    objectType - variable for the type of object its tracking
    _maid - internal cleanup for all instances and  events related to enable()

    setcolor() - updates the color used for visualization
    enable() - starts visualization
    disable() - stops visualization and clears all objects related to it

    destroy() - destroys it (will be used for variants)
]]

local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)
local TagUtil = require(Package.Util.TagUtils)
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value

local ViewObject = {}
ViewObject.__index = ViewObject

function ViewObject.new(Name, data, color)
	local self = setmetatable({}, ViewObject)

	self._Maid = Util.Maid.new()

	self.ObjectType = data.ObjectType or "SelectionBox"
	self.TagType = data.TagType

	self.UsesAll = data.UsesAllInstances
	self.Tag = data.Name
	self.SubTag = data.SubName
	self.Name = Name
	self.Data = data

	self.Color = Value(color)
	self.ObjectHandler = require(script.ObectTypes[self.ObjectType]).new(self)

	self.checkState = Value(false)
	self.Enabled = false
	return self
end

function ViewObject:SetColor(newColor: Color3)
	self.Color:set(newColor)

	if self.Enabled then
		self.ObjectHandler:UpdateAppearance()
	end
end

function ViewObject:Enable()
	if self.Enabled then
		return
	end

	local function HandleUpdates(part)
		local MaidIndex = self.ObjectHandler.Objects[part].MaidIndex
        local index1, index2

		local function UpdatePart()
			if not TagUtil:PartHasTag(part, self.Tag) then
				for i, index in pairs(MaidIndex) do
                    self.ObjectHandler._Maid[index] = nil
                end
			end
		end

		local TagTypes = {}

		function TagTypes.Any()
			index1 = self._Maid:GiveTask(part.Changed:Connect(UpdatePart))

			local tagInstance = TagUtil:GetTagInstance(part, self.Tag)
			if tagInstance then
				index2 = self._Maid:GiveTask(tagInstance.Changed:Connect(UpdatePart))
			elseif part:GetAttribute("_action") then
				index2 = self._Maid:GiveTask(part:GetAttributeChangedSignal("_action"):Connect(UpdatePart))
			end
		end

		function TagTypes.Child()
			local tagInstance = TagUtil:GetTagInstance(part, self.Tag)
			if tagInstance then
				index1 = self._Maid:GiveTask(tagInstance:GetPropertyChangedSignal("Name"):Connect(UpdatePart))
				index2 = self._Maid:GiveTask(tagInstance.AncestryChanged:Connect(UpdatePart))
			end
		end

		function TagTypes.Parent()
			index1 = self._Maid:GiveTask(part.AncestryChanged:Connect(UpdatePart))
		end

		function TagTypes.NoChild()
			index1 = self._Maid:GiveTask(part:GetAttributeChangedSignal("_action"):Connect(UpdatePart))
		end

		TagTypes[self.TagType]()
        table.insert(self.ObjectHandler.Objects[part].MaidIndex, index1)
        table.insert(self.ObjectHandler.Objects[part].MaidIndex, index2)
	end

	print(self.Tag)
	self._Maid:GiveTask(TagUtil.OnTagAdded(self.Tag):Connect(function(...)
		print("added", self.Tag)
		if self.ObjectHandler:SetAppearance(...) then
			HandleUpdates(...)
		end
	end))
	self._Maid:GiveTask(TagUtil.OnTagRemoved(self.Tag):Connect(function(...)
		self.ObjectHandler:ClearAppearance(...)
	end))
	self.Enabled = true
	self.checkState:set(true)

    task.defer(function()
        for i, part in pairs(TagUtil:GetPartsWithTag(self.Tag, self.SubTag)) do
			if self.ObjectHandler:SetAppearance(part) then
				HandleUpdates(part)
			end
        end

        task.wait(math.random(1, 12))

        while self.Enabled do
            local studioQuality = settings().Rendering.QualityLevel.Value == 0 and 21 or settings().Rendering.QualityLevel.Value
            for _, part in pairs(TagUtil:GetPartsWithTag(self.Tag)) do
                if not self.ObjectHandler.Objects[part] then
                    if self.ObjectHandler:SetAppearance(part) then
						HandleUpdates(part)
					end
                end
            end
            task.wait(((5 / (math.max(12, studioQuality) / 21)) * (1 + (Util._DebugView.activeDebugViews:get() / 8)) + ((#Players:GetPlayers() == 1 and 10 or 0))))
        end
    end)
end

function ViewObject:Disable()
	if self.Enabled then
		self.ObjectHandler:ClearAppearance()
        self.Enabled = false
        self.checkState:set(false)
        self._Maid:DoCleaning()
	end
end

function ViewObject:Destroy()
	self:Disable()
	self._Maid:DoCleaning()
end

return ViewObject
