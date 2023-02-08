local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local Fusion = require(script.Parent.Resources.Fusion)
local Signal = require(script.Signal)
local Pages = require(script.Parent.Resources.Components.Pages)
local Maid = require(script.Maid)

local Value = Fusion.Value
local Observer = Fusion.Observer

local selectionMaid = Maid.new()

local Util = {
    Signal = Signal,
    Maid = Maid,

    Widget = nil,
    mapModel = Value(nil),
    hasSpecialFolder = Value(false),

    MapChanged = Signal.new(),
    MainMaid = Maid.new(),
    MapMaid = Maid.new(),

    _pageChanged = Signal.new(),
    _currentPageNum = Value(1),
    _manualActive = Value(true),
    interfaceActive = Value(false),
    dropdownActive = Value(false),

    _Selection = {
        selectedParts = Value({}),
        selectedUpdate = Value(0)
    },  
    _Topbar = {
        FreezeFrame = Value(false)
    },
    _Message = {
        Text = Value(""),
        Header = Value(""),
        Option1 = Value({}),
        Option2 = Value({}),
    },
    _PageOrder = {
        "ObjectTags",
        "ViewModes",
        "Settings",
        "Compatibility",
        "Publish",
        "Insert"
    },
    Difficulty = {
        [0] = {
            Name = "Unrated",
            Color = Color3.new(1, 1, 1),
            Image = "rbxassetid://12132024589"
        },
        [1] = {
            Name = "Easy",
            Color = Color3.fromRGB(85, 255, 127),
            Image = "rbxassetid://12132025467"
        },
        [2] = {
            Name = "Normal",
            Color = Color3.fromRGB(255, 255, 127),
            Image = "rbxassetid://12132024792"
        },
        [3] = {
            Name = "Hard",
            Color = Color3.fromRGB(255, 0, 25),
            Image = "rbxassetid://12132025088"
        },
        [4] = {
            Name = "Insane",
            Color = Color3.fromRGB(112, 42, 241),
            Image = "rbxassetid://12132024949"
        },
        [5] = {
            Name = "Extreme",
            Color = Color3.fromRGB(255, 128, 0),
            Image = "rbxassetid://12132025296"
        },
        [6] = {
            Name = "Divine",
            Color = Color3.fromRGB(255, 8, 152),
            Image = "rbxassetid://12132025606"
        }
    },  
}

function getSettingsDirFolder(directory: string)
    local currentMap = Util.mapModel:get(false)
    if currentMap == nil then
        return nil
    end

    local mapSettings = currentMap:FindFirstChild("Settings")
    if not mapSettings then
        return nil
    end

    local dirFolder = mapSettings
    local split = directory:split(".")

    for index, child in pairs(split) do
        dirFolder = dirFolder:FindFirstChild(child)
        if not dirFolder then
            return nil
        end
    end

    return dirFolder
end

function Util:ToggleInterface(value: boolean)
    self._manualActive:set(value)
end

function Util.CloseMessage()
    Util:ToggleInterface(true)
    Util._Message.Text:set("")
    Util._Message.Header:set("")
    Util._Message.Option1:set({})
    Util._Message.Option2:set({})
end

function Util:ShowMessage(header: string, text: string, option1: any?, option2: any?)
    self:ToggleInterface(false)
    self._Message.Text:set(text)
    self._Message.Header:set(header)
    self._Message.Option1:set(option1 or {Text = "Ok", Callback = Util.CloseMessage})
    self._Message.Option2:set(option2 or option1 and {Text = "Ok", Callback = Util.CloseMessage} or {})
end

function Util.isPluginFrozen()
	return Util.mapModel:get() == nil and not table.find(Pages.pageData.bypassedPages, Pages.pageData.currentPage:get())
end

function Util.updateMapSetting(directory: string, attribute: string, value: any)
    local dirFolder = getSettingsDirFolder(directory)
    if not dirFolder then
        return
    end
    if value == nil then
        return
    end
    ChangeHistoryService:SetWaypoint("Changing setting '%s' to '%s'", attribute, value)
    dirFolder:SetAttribute(attribute, value)
    ChangeHistoryService:SetWaypoint("Set setting '%s' to '%s'", attribute, value)
end

function Util.debugWarn(...)
    warn("[TRIA.os Map Plugin]:", ...)
end

function Util.getDirFolder(directory: string)
    return getSettingsDirFolder(directory)
end

function Util.colorToRGB(color: Color3): string
    return string.format("%i, %i, %i", 
        math.min(math.floor(color.R * 255), 255), 
        math.min(math.floor(color.G * 255), 255),
        math.min(math.floor(color.B * 255), 255)
    )
end

function Util.parseColor3Text(str: string): (boolean, nil | Color3)
    local split = string.split(str, ",")
    for _, v in pairs(split) do
        if not tonumber(v) then
            return false, nil
        end
    end

    if #split < 3 then
        return false, nil
    end

    local r, g, b = 
        math.min(math.floor(split[1] + 0.5), 255), 
        math.min(math.floor(split[2] + 0.5), 255), 
        math.min(math.floor(split[3] + 0.5), 255)

    local newColor = Color3.fromRGB(r, g, b)
    return true, newColor
end

function Util.parseTextColor3(color: Color3): string
    color = (color == "" or not color) and Color3.new(0, 0, 0) or color
    return string.format("%d, %d, %d",
        color.R * 255,
        color.G * 255,
        color.B * 255)
end

function Util.parseTimeString(str: string): (boolean, string | nil)
    local split = string.split(str, ":")

    if #split ~= 3 then
        return false, nil
    end

    for i, v in pairs(split) do
        if not tonumber(v) then
            return false, nil
        end
        if #v > 2 then
            split[i] = string.sub(v, 1, 2)
        end
        split[i] = ("%02i"):format(split[i])
    end
    return true, table.concat(split, ":")
end

function updateButtonsActive()
    Util.interfaceActive:set(Util.mapModel:get(false) and Util._manualActive:get(false))
end

function Util.UpdateSelectedParts()
    local newTable = {}
    for _, Thing: Instance in pairs(Selection:Get()) do
        if Thing:IsDescendantOf(Util.mapModel:get(false)) then
            table.insert(newTable, Thing)
        end
    end

    if not (#newTable == 0 and #Util._Selection.selectedParts:get(false) == 0) then
        selectionMaid:DoCleaning()
        Util._Selection.selectedParts:set(newTable)
        
        for _, Thing: Instance in pairs(Selection:Get()) do
            selectionMaid:GiveTask(Thing:GetPropertyChangedSignal("Name"):Connect(function()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
            end))
            selectionMaid:GiveTask(Thing:GetAttributeChangedSignal("_action"):Connect(function()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
            end))
            selectionMaid:GiveTask(Thing.Destroying:Connect(function()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
            end))
            selectionMaid:GiveTask(Thing.ChildRemoved:Connect(function()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
            end))
            selectionMaid:GiveTask(Thing.AncestryChanged:Connect(function()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
            end))

            selectionMaid:GiveTask(Thing.ChildAdded:Connect(function(newThing)
                if newThing:IsA("ValueBase") then
                    Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
                end
                selectionMaid:GiveTask(newThing.Changed:Connect(function()
                    Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
                end))
            end))
            for _, Child in pairs(Thing:GetChildren()) do
                if Child:IsA("ValueBase") then
                    selectionMaid:GiveTask(Thing.ChildRemoved :Connect(function()
                        Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get() + 1)
                    end))
                end
            end
        end
    end
end


updateButtonsActive()
Observer(Util._Message.Text):onChange(updateButtonsActive)
Observer(Util.mapModel):onChange(updateButtonsActive)
Observer(Util._manualActive):onChange(updateButtonsActive)
Util.MainMaid:GiveTask(Util.MapMaid)
Util.MainMaid:GiveTask(selectionMaid)
Util.MainMaid:GiveTask(Selection.SelectionChanged:Connect(Util.UpdateSelectedParts))

return Util
