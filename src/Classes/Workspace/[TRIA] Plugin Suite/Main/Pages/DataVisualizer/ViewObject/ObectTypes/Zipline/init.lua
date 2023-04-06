local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local Fusion = require(Package.Resources.Fusion)
local ZiplineGenerator = require(script.ZiplineGenerator)

local Value = Fusion.Value
local New = Fusion.New

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    self.Objects[part] = {
        Zipline = {},
        MaidIndex = {}
    }
    local success, data = ZiplineGenerator:generate(part, self.Color)

    if success then
        self.Objects[part].Zipline = data.Rope
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(data.Rope))
    end

    return true
end

function ObjectType:UpdateAppearance()
    for i, parts in pairs(self.Objects) do
        for _, SelectionBox in pairs(parts.SelectionBox) do
            parts.SelectionBox.Color3 = self.Color:get()
            parts.SelectionBox.SurfaceColor3 = self.Color:get()
        end
    end
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        for _, index in pairs(self.Objects[part].MaidIndex) do
            self._Maid[index] = nil
        end
    else
        self._Maid:Destroy()
        self.Objects = {}
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
