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
    self.Objects = {}

    self.ObjectType = data.ObjectType or "SelectionBox"
    self.TagType = data.TagType
    
    self.Tag = data.Name
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

    local PartsWithTag = TagUtil:GetPartsWithTag(self.Tag)
    self.ObjectHandler:SetAppearance(PartsWithTag)

    self.Enabled = true
    self.checkState:set(true)
end

function ViewObject:Disable()
    if not self.Enabled then
        return
    end

    self.ObjectHandler:ClearAppearance()
    self.Objects = nil
    self.Enabled = false
    self.checkState:set(false)
    self._Maid:DoCleaning()
end

function ViewObject:Destroy()
    self:Disable()
    self._Maid:DoCleaning()
end

return ViewObject
