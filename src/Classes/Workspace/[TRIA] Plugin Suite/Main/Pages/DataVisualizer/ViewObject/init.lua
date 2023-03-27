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
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value

local ViewObject = {}
ViewObject.__index = ViewObject

function ViewObject.new(Name, data)
    local self = setmetatable({}, ViewObject)

    self._Maid = Util.Maid.new()

    self.Name = Name
    self.Data = data

    self.checkState = Value(false)
    self.Enabled = false

    return self
end

function ViewObject:Enable()
    
end

function ViewObject:Disable()
    
end

function ViewObject:Destroy()
    self:Disable()
    self._Maid:DoCleaning()
end

return ViewObject
