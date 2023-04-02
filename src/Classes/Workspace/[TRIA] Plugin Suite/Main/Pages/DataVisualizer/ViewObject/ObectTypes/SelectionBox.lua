local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local TagUtils = require(Package.Util.TagUtils)
local Fusion = require(Package.Resources.Fusion)

local Value = Fusion.Value
local New = Fusion.New

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.AppearanceSet = false
    self.Tag = controller.Name
    self.TagType = controller.TagType
    self.Color = controller.Color:get() and controller.Color or Value(Color3.new())
    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(parts)
    if typeof(parts) == "Instance" then
        parts = {parts}
    end

    for i, part in pairs(parts) do
        if not part:IsA("BasePart") then
            continue
        end
        local SelectionBox = New "SelectionBox" {
            Archivable = false,
            SurfaceColor3 = self.Color:get(),
            Color3 = self.Color:get(),
            LineThickness = 0.05,
            Transparency = 0.375,
            SurfaceTransparency = .6,
            Parent = Util._DebugView.debugObjectsFolder,
            Adornee = part
        }
        print(SelectionBox:GetFullName())
        local selectionId = self._Maid:GiveTask(SelectionBox)

        local index1, index2

        local function UpdatePart()
            if not TagUtils:PartHasTag(part, self.Tag) then
                self._Maid[selectionId] = nil
                self._Maid[index1] = nil
                self._Maid[index2] = nil
            end
        end

        local TagTypes = {}

        function TagTypes.Any()
            index1 = self._Maid:GiveTask(part.Changed:Connect(UpdatePart))

            local tagInstance = TagUtils:GetTagInstance(part, self.Tag)
            if tagInstance then
                index2 = self._Maid:GiveTask(tagInstance.Changed:Connect(UpdatePart))
            elseif part:GetAttribute("_action") then
                index2 = self._Maid:GiveTask(part:GetAttributeChangedSignal("_action"):Connect(UpdatePart))
            end
        end

        function TagTypes.Child()
            local tagInstance = TagUtils:GetTagInstance(part, self.Tag)
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

        TagTypes[self.TagType]()
        self.Objects[part] = {
            SelectionBox = SelectionBox,
            MaidIndex = {selectionId, index1, index2}
        }
    end
    self.AppearanceSet = true
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
        self.AppearanceSet = false
    end
end

function ObjectType:Destroy()
    self._Maid:Destroy()
end

return ObjectType
