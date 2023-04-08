local Package = script.Parent.Parent.Parent.Parent.Parent
local Util = require(Package.Util)

local BUTTON_LOCATORS = {
    default = "rbxassetid://6274811030",
    classic = "rbxassetid://6275599542",
    circle = "rbxassetid://6275600040",
    square = "rbxassetid://6275600378",
}

local ObjectType = {}
ObjectType.__index = ObjectType

function ObjectType.new(controller)
    local self = setmetatable({}, ObjectType)

    self.Objects = {}
    self._Maid = Util.Maid.new()

    return self
end

function ObjectType:SetAppearance(part)
    local Marker = script.Marker:Clone()
    if not part.Name:find("_Button") then
        return
    end
    local ButtonSettings = Util.mapModel:get().Settings.Button
    self.Objects[part] = {
        Marker = Marker,
        MaidIndex = {}
    }
    Marker.Parent = Util._DebugView.debugObjectsFolder
    Marker.Adornee = part
    Marker.Enabled = true

    local function UpdateButton(button)
        local Marker = self.Objects[button].Marker

        Marker.ButtonNum.Text = button.Name:sub(8)
        Marker.GroupPercent.Text = button:GetAttribute("Group") and '50%' or ""

        local ColorType = string.gsub(string.sub(button.Name, 8), "%a", "") == "1" and "ActiveColor" or "InactiveColor"
        local ButtonType = if button:GetAttribute("Group") then "Group"
            elseif string.gsub(string.sub(button.Name, 8), "%d", "") ~= "" then "PathChild"
            else "Default"
        
        Marker.Icon.ImageColor3 = button:GetAttribute(ColorType) or ButtonSettings:FindFirstChild(ButtonType) and ButtonSettings:FindFirstChild(ButtonType):GetAttribute(ColorType) or Color3.new(0, 0, 0)
        Marker.Icon.Image = BUTTON_LOCATORS[button:GetAttribute("LocatorImage")] or BUTTON_LOCATORS[ButtonSettings:FindFirstChild(ButtonType) and ButtonSettings[ButtonType]:GetAttribute("LocatorImage")] or "rbxassetid://6274811030"
    end
    UpdateButton(part)
    

    for _,  buttonType in pairs(ButtonSettings:GetChildren()) do
        table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(buttonType.AttributeChanged:Connect(function()
            for part, data in pairs(self.Objects) do
                UpdateButton(part)
            end
        end)))
    end
    table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part.AttributeChanged:Connect(function()
        UpdateButton(part)
    end)))
    table.insert(self.Objects[part].MaidIndex, self._Maid:GiveTask(part:GetPropertyChangedSignal("Name"):Connect(function()
        UpdateButton(part)
    end)))

    return true
end

function ObjectType:ClearAppearance(part: Instance?)
    if part then
        self.Objects[part].Marker:Destroy()

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
