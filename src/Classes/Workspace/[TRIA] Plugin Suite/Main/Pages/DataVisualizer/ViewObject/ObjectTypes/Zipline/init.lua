local Selection = game:GetService("Selection")

local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local ZiplineGenerator = require(script.ZiplineGenerator)
local PartCache = require(Package.Util.PartCache)

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Tag = controller.Tag
    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    if not self.Objects[part] then
        self.Objects[part] = {
            Zipline = Instance.new("Model"),
            MaidIndex = {},
            BasePart = part
        }
    end
    local success, data = ZiplineGenerator:generate(part, self.Objects[part].Zipline)

    if success then
        self.Objects[part].Zipline = data.Rope
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
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.AncestryChanged:Connect(function()
            if not self.Parent then
                self:ClearAppearance(part)
            end
        end)))

        local function HandlePoint(point)
            
            local function AncestorsSelected()
                local Selected = Selection:Get()
                local SelectedPart = point.Parent
                
                repeat
                    if table.find(Selected, SelectedPart) then
                        return true
                    end
                    SelectedPart = SelectedPart.Parent
                until SelectedPart == workspace
                return false
            end

            table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(point:GetPropertyChangedSignal("Name"):Connect(function()
                self:ClearAppearance(part)
                self:SetAppearance(part)
            end)))
            table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(point:GetPropertyChangedSignal("CFrame"):Connect(function()
                if not debounce and table.find(Selection:Get(), point) and not AncestorsSelected() then
                    debounce = true

                    repeat
                        local firstPos = point.CFrame
                        task.wait()
                    until point.CFrame == firstPos

                    self:ClearAppearance(part)
                    task.wait()
                    self:SetAppearance(part)
                    debounce = false
                end
            end)))
        end

        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.ChildAdded:Connect(function(newPart)
            if tonumber(newPart.Name) and newPart:IsA("BasePart") then
                self:ClearAppearance(part)
                self:SetAppearance(part)
            end
            HandlePoint(newPart)
        end)))

        for _, part in pairs(part:GetChildren()) do
            if part:IsA("BasePart") then
                HandlePoint(part)
            end
        end

        return true
    end
end

function ObjectType:UpdateAppearance(part)
    local parts = self.Objects[part]
    if not parts then
        return
    end

    local Config = parts.BasePart:FindFirstChildOfClass("Configuration")

    for  _, Part in pairs(parts.Zipline:GetChildren()) do
        if Enum.Material[Config:GetAttribute("Material") or "Plastic"] then
            Part.Material = Enum.Material[Config:GetAttribute("Material") or "Plastic"]
        end
        Part.Color = Config:GetAttribute("Color") or Color3.new
        Part.Size = Vector3.new(Config:GetAttribute("Width"), Config:GetAttribute("Width"), Part.Size.Z)
    end
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        for _, object in pairs(self.Objects[part].Zipline:GetChildren()) do
            PartCache:CacheObject("ZiplineCache", object)
        end
        for _, index in pairs(self.Objects[part].MaidIndex) do
            self._Maid[index] = nil
        end
    else
        for _, viewobject in pairs(self.Objects) do
            if viewobject.Zipline then
	            for _, object in pairs(viewobject.Zipline:GetChildren()) do
	                PartCache:CacheObject("ZiplineCache", object)
				end
				viewobject.Zipline:Destroy()
			end
        end
        self._Maid:Destroy()
        self.Objects = {}
        PartCache:RemoveCache("ZiplineCache")
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
