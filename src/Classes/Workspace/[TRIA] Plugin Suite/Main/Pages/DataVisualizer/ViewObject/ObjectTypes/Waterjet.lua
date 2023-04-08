local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    local EmitterPart = Instance.new("Part")
    EmitterPart.Transparency = 1
    EmitterPart.Locked = true
    EmitterPart.Parent = Util._DebugView.debugObjectsFolder
    EmitterPart.Size = part.Size * Vector3.new(1, 1, 0)
    EmitterPart.CFrame = part.CFrame

    local ParticleEmitter = Instance.new("ParticleEmitter")
    ParticleEmitter.Parent = EmitterPart
    ParticleEmitter.EmissionDirection = Enum.NormalId.Front
    ParticleEmitter.LockedToPart = true

    local function UpdateEmitter(waterjet)
        local speed = waterjet:GetAttribute("FanSpeed") or 32
        local distance = waterjet:GetAttribute("Distance") or 24
        local bubbleId = waterjet:GetAttribute("BubbleParticle") or "1249690853"
        local ParticleEmitter = self.Objects[waterjet].EmitterPart:FindFirstChildOfClass("ParticleEmitter")

        ParticleEmitter.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.5, 0.15), NumberSequenceKeypoint.new(1, 0.35, 0.15)}
        ParticleEmitter.Speed = NumberRange.new(speed, speed)
        ParticleEmitter.Lifetime = NumberRange.new(distance / speed, distance / speed)
        ParticleEmitter.Rate = waterjet.Size.X * waterjet.Size.Y / 144 * 32
        ParticleEmitter.Texture = bubbleId == "default" and "rbxassetid://1249690853" or "rbxassetid://" .. bubbleId
        ParticleEmitter.Shape = Enum.ParticleEmitterShape[waterjet:GetAttribute("FanShape") == "Cylinder" and "Disc" or "Box"]
    end

    local ID1 = part:GetPropertyChangedSignal("Size"):Connect(function()
        EmitterPart.Size = part.Size * Vector3.new(1, 1, 0)
        ParticleEmitter.Rate = part.Size.X * part.Size.Y / 144 * 32
    end)

    local ID2 = part:GetPropertyChangedSignal("Position"):Connect(function()
        EmitterPart.CFrame = part.CFrame
    end)

    local ID3 = part.AttributeChanged:Connect(function()
        UpdateEmitter(part)
    end)

    self.Objects[part] = {
        EmitterPart = EmitterPart,
        MaidIndex = {self._Maid:GiveTask(ID1), self._Maid:GiveTask(ID2), self._Maid:GiveTask(ID3)}
    }

	self._Maid:GiveTask(EmitterPart)
    UpdateEmitter(part)

    return true
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
