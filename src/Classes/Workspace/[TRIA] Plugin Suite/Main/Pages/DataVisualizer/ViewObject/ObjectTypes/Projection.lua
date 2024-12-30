local Selection = game:GetService("Selection")

local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local PartCache = require(Package.Util.PartCache)

local ObjectType = {}
ObjectType.__index = ObjectType



local function calc(Orb, x, cf, type)
	local g = workspace.Gravity * 1
	local v = Orb:GetAttribute("Power") * (workspace:GetAttribute("Power") or 1)
	local localYDirection = cf.UpVector
	local angle = math.pi/2 - 
		math.abs(
			math.acos(localYDirection:Dot(Vector3.new(0, 1, 0)))
				* (localYDirection:Dot(Vector3.new(0, 1, 0)) > 0 and 1 or -1)
		)
    if type == "Pivot" then
        angle = 0
    end
	angle += angle < 0 and math.rad(5) or 0
	x *= math.cos(angle)
	local returnX = -x * (if angle > 75 then .0625 elseif angle > 60 then .25 elseif angle > 45 then .5 elseif angle > 30 then .6 else .8) 
	local returnY = x * math.tan(angle) - (g * x^2) / (2 * v^2 * math.cos(angle)^2)
	
	return returnX, returnY  
end

local function MakeProjection(OrbHitbox, Type, Parent, Color)
    local Orb = OrbHitbox.Parent
    local cf
    if Type == "Launch" then
	    local Arrow = Orb:FindFirstChild("Arrow")
        cf = Arrow.CFrame
    else
        cf = OrbHitbox.CFrame
    end
    
	local cf2 = cf * CFrame.new(0, 2, 0)
	local unit = Vector3.new(cf2.X - cf.X, 0, cf2.Z - cf.Z).Unit
    if unit.Magnitude ~= unit.Magnitude then -- if nan
        if Type == "Launch" then
            unit= Vector3.new(1,0,0)
        else
            local newCF = cf * CFrame.new(2, 0, 2)
            unit = Vector3.new(newCF.X - cf.X, 0, newCF.Z - cf.Z).Unit
        end
	end

	local CF = CFrame.lookAt(cf.Position, cf.Position + unit)

	for i = 1, 99, 3 do
		local node = PartCache:GetObject("OrbCache")
		node.Anchored = true
		node.Material = Enum.Material.Neon
		node.CanCollide = false
		node.Color = Color
		node.Size = Vector3.new(.375, .375, .375)
		node.Parent = Parent

		local X, Y = calc(Orb, i, cf, Type)
		node.CFrame = CF * CFrame.new(0, 0, X) + Vector3.new(0, Y, 0)
	end
    return true
end

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Tag = controller.Tag
    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    if not part:GetAttribute("_action") then
        return
    end

    local orbType = part.Parent:GetAttribute("Type")

    if not self.Objects[part] then
        self.Objects[part] = {
            Orb = Instance.new("Model"),
            MaidIndex = {},
            BasePart = part,
            Color = Color3.fromHSV(math.random(), 1, 1),
        }
        self.Objects[part].Orb.Parent = Util._DebugView.debugObjectsFolder
    end

    local success = MakeProjection(part, orbType, self.Objects[part].Orb, self.Objects[part].Color)

    if success then
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part:GetPropertyChangedSignal("CFrame"):Connect(function()
            self:ClearAppearance(part)
            task.wait()
            self:SetAppearance(part)
        end)))
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.Parent:GetAttributeChangedSignal("Power"):Connect(function()
            self:ClearAppearance(part)
            task.wait()
            self:SetAppearance(part)
        end)))
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.AncestryChanged:Connect(function()
            if not self.Parent then
                self:ClearAppearance(part)
            end
        end)))
    end
    
    return true
end

function ObjectType:UpdateAppearance(part)
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        for _, object in pairs(self.Objects[part].Orb:GetChildren()) do
            PartCache:CacheObject("OrbCache", object)
        end
        for _, index in pairs(self.Objects[part].MaidIndex) do
            self._Maid[index] = nil
        end
    else
        for _, viewobject in pairs(self.Objects) do
            if viewobject.Orb then
	            for _, object in pairs(viewobject.Orb:GetChildren()) do
	                PartCache:CacheObject("OrbCache", object)
				end
				viewobject.Orb:Destroy()
			end
        end
        self._Maid:Destroy()
        self.Objects = {}
        PartCache:RemoveCache("OrbCache")
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
