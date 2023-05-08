local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value
local New = Fusion.New

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Tag = controller.Tag
    self.TagType = controller.TagType
    self.Visible = false
    self.Color = controller.Color:get() and controller.Color or Value(Color3.new())
    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    self.Visible = true
    local function GetSelectionBox(Part)
        if self.Tag == "AirTank" then
            return New "SelectionSphere" {
                SurfaceColor3 = self.Color:get(),
                Color3 = self.Color:get(),
                SurfaceTransparency = 0.6,
                Parent = Util._DebugView.debugObjectsFolder,
                Adornee = Part
            }
        else
            return New "SelectionBox" {
                SurfaceColor3 = self.Color:get(),
                Color3 = self.Color:get(),
                LineThickness = 0.03,
                SurfaceTransparency = 0.6,
                Parent = Util._DebugView.debugObjectsFolder,
                Adornee = Part
            }
        end
    end
        
    self.Objects[part] = {
        SelectionBox = {},
        MaidIndex = {}
    }

    if (part:IsA("Model") or part:IsA("Folder")) and self.TagType ~= "Parent" then
        local references = {}
        local function ProcessPart(partToProcess)
            local index
            local selectionBox = GetSelectionBox(partToProcess)

            table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(selectionBox))
            table.insert(self.Objects[part].SelectionBox, selectionBox)
            index = self._Maid:GiveTask(partToProcess.AncestryChanged:Connect(function()
                if not partToProcess:IsDescendantOf(part) then
                    self._Maid[index] = nil
                    selectionBox:Destroy()
                end
            end))
            table.insert(references, partToProcess)
            table.insert(self.Objects[part].MaidIndex, index)
        end
        for _, instance in pairs(part:GetDescendants()) do
            if instance:IsA("BasePart") then
                ProcessPart(instance)
            end
        end
        task.spawn(function()
            task.wait(5)
            while self.Visible do
                local newReferences = {}
                for _, instance in pairs(part:GetDescendants()) do
                    if instance:IsA("BasePart") then
                        if not table.find(references, instance) then
                            ProcessPart(instance)
                        end
                        table.insert(newReferences, instance)
                    end
                end
                references = newReferences
                task.wait(5)
            end
        end)
    elseif part:IsA("BasePart") then
        local selectionBox = GetSelectionBox(part)

        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.AncestryChanged:Connect(function()
            if not part:IsDescendantOf(Util.mapModel:get()) then
                self:ClearAppearance(part)
            end
        end)))
        table.insert(self.Objects[part].SelectionBox, selectionBox)
        self._Maid:GiveTask(selectionBox)
    end

    return true
end

function ObjectType:UpdateAppearance()
    for i, parts in pairs(self.Objects) do
        for _, SelectionBox in pairs(parts.SelectionBox) do
            SelectionBox.Color3 = self.Color:get()
            SelectionBox.SurfaceColor3 = self.Color:get()
        end
    end
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        for _, SelectionBox in pairs(self.Objects[part].SelectionBox) do
            SelectionBox:Destroy()
        end

        for _, index in pairs(self.Objects[part].MaidIndex) do
            self._Maid[index] = nil
        end
        self.Objects[part] = nil
    else
        self.Visible = false
        self._Maid:Destroy()
        self.Objects = {}
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
