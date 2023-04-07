local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local ZiplineGenerator = require(script.ZiplineGenerator)

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
        Zipline = nil,
        MaidIndex = {},
        BasePart = part
    }
    local success, data = ZiplineGenerator:generate(part, self.Color)

    if success then
        self.Objects[part].Zipline = data.Rope

        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(data.Rope))
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part:FindFirstChildOfClass("Configuration").AttributeChanged:Connect(function()
            self:UpdateAppearance(part)
        end)))
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part:GetPropertyChangedSignal("WorldPivot"):Connect(function()
            self.Objects[part].Zipline:PivotTo(self.Objects[part].BasePart:GetPivot())
            task.wait()
            self.Objects[part].Zipline:PivotTo(self.Objects[part].BasePart:GetPivot())
        end)))
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.ChildRemoved:Connect(function()
            self:ClearAppearance(part)
            self:SetAppearance(part)
        end)))
    end

    return true
end

function ObjectType:UpdateAppearance(part)
    local parts = self.Objects[part]
    if not parts then
        return
    end

    local Config = parts.BasePart:FindFirstChildOfClass("Configuration")

    for  _, Part in pairs(parts.Zipline:GetChildren()) do
        Part.Material = Enum.Material[Config:GetAttribute("Material") or "Plastic"]
        Part.Color = Config:GetAttribute("Color") or Color3.new
        Part.Size = Vector3.new(Config:GetAttribute("Width"), Config:GetAttribute("Width"), Part.Size.Z)
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
