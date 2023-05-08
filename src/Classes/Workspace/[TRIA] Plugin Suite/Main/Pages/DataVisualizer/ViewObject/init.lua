local Players = game:GetService("Players")

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
	self.ObjectHandler = require(script.ObjectTypes[self.ObjectType]).new(self)

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
        local index1, index2, index3

		local function UpdatePart()
			if not TagUtil:PartHasTag(part, self.Tag) or not part:IsDescendantOf(Util.mapModel:get()) then
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

		function TagTypes.Addon()
			index3 = self._Maid:GiveTask(Util._Addons.AddonRemoved:Connect(function(removedTag)
				if removedTag == self.Tag then
					UpdatePart()
				end
			end))
			TagTypes.Any()
		end

		TagTypes[self.TagType]()
        table.insert(self.ObjectHandler.Objects[part].MaidIndex, index1)
        table.insert(self.ObjectHandler.Objects[part].MaidIndex, index2)
        table.insert(self.ObjectHandler.Objects[part].MaidIndex, index3)
	end

	self._Maid:GiveTask(TagUtil.OnTagAdded(self.Tag):Connect(function(...)
		if self.ObjectHandler:SetAppearance(...) then
			HandleUpdates(...)
		end
	end))
	self._Maid:GiveTask(TagUtil.OnTagRemoved(self.Tag):Connect(function(...)
		self.ObjectHandler:ClearAppearance(...)
	end))
	self.Enabled = true
	self.checkState:set(true)

	self._Maid:GiveTask(Util._DebugView.debugObjectsFolder.AncestryChanged:Connect(function()
		if not Util._DebugView.debugObjectsFolder.Parent then
			self:Disable(true)
		end
	end))
	self._Maid:GiveTask(Util.MapChanged:Connect(function()
		self:Disable(true)
	end))

	if self.Tag == "_Detail" then
		self._Maid:GiveTask(Util.mapModel:get():FindFirstChild("Detail").AncestryChanged:Connect(function()
			if not Util.mapModel:get():FindFirstChild("Detail") then
				self:Disable(true)
			end
		end))
	end

	local parts, UsesSpecialFolder = TagUtil:GetPartsWithTag(self.Tag, self.SubTag)
	if UsesSpecialFolder then
		self._Maid:GiveTask(UsesSpecialFolder.ChildAdded:Connect(function(part)
			task.wait()
			if TagUtil:PartHasTag(part, self.Tag) and not self.ObjectHandler.Objects[part] and self.ObjectHandler:SetAppearance(part) then
				HandleUpdates(part)
			end
		end))
	end

    task.defer(function()
        for i, part in pairs(parts) do
			if self.ObjectHandler:SetAppearance(part) then
				HandleUpdates(part)
			end
        end

        task.wait(math.random(1, 12))

        while self.Enabled do
			if self.Tag == "_Detail" and not Util.mapModel:get():FindFirstChild("Detail") then
				self:Disable(true)
				break
			end
            local studioQuality = settings().Rendering.QualityLevel.Value == 0 and 21 or settings().Rendering.QualityLevel.Value
            for _, part in pairs(TagUtil:GetPartsWithTag(self.Tag)) do
                if not self.ObjectHandler.Objects[part] then
                    if self.ObjectHandler:SetAppearance(part) then
						HandleUpdates(part)
					end
                end
            end
            task.wait(((5 / (math.max(12, studioQuality) / 21)) * (0.5 + (Util._DebugView.activeDebugViews:get() / 12)) + ((#Players:GetPlayers() >= 1 and 10 or 0))))
        end
    end)
end

function ViewObject:Disable(override)
	if self.Enabled then
		self.ObjectHandler:ClearAppearance()
        self.Enabled = false
        self.checkState:set(false)
        self._Maid:DoCleaning()
		if override then
			Util._DebugView.activeDebugViews:set(Util._DebugView.activeDebugViews:get() - 1)
		end
	end
end

function ViewObject:Destroy()
	self:Disable()
	self._Maid:DoCleaning()
end

return ViewObject
