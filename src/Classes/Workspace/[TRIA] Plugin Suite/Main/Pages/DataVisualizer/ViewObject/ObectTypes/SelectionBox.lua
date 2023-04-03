local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value
local New = Fusion.New

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Color = controller.Color:get() and controller.Color or Value(Color3.new())
    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    local SelectionBox = New "SelectionBox" {
        SurfaceColor3 = self.Color:get(),
        Color3 = self.Color:get(),
        LineThickness = 0.03,
        SurfaceTransparency = .625,
        Parent = Util._DebugView.debugObjectsFolder,
        Adornee = part
    }
    self.Objects[part] = {
        SelectionBox = SelectionBox,
        MaidIndex = {self._Maid:GiveTask(SelectionBox)}
    }
end

function ObjectType:UpdateAppearance()
    for i, parts in pairs(self.Objects) do
        parts.SelectionBox.Color3 = self.Color:get()
        parts.SelectionBox.SurfaceColor3 = self.Color:get()
    end
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        for _, index in pairs(self.Objects[part].MaidIndex) do
            self._Maid[index] = nil
        end
    else
        self._Maid:Destroy()
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
