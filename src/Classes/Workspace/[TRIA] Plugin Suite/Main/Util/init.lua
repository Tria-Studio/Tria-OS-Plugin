local Selection = game:GetService("Selection")

local Fusion = require(script.Parent.Resources.Fusion)
local Signal = require(script.Signal)
local Maid = require(script.Maid)

local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer

local defaultMessageResponses = {
    "Ok",
    "Fine",
    "Sure",
    "Whatever",
    "k",
    "Got it",
    "Alright",
    "Yeah",
    "Cool",
    "Ok thanks"
}

local Util = {
    Signal = Signal,
    Maid = Maid,

    Widget = nil,
    mapModel = Value(nil),
    MapChanged = Signal.new(),
    MainMaid = Maid.new(),

    _manualActive = Value(true),
    interfaceActive = Value(false),

    selectedParts = Value({}),

    _Topbar = {
        FreezeFrame = Value(false)
    },
    _Message = {
        Text = Value(""),
        Header = Value(""),
        Option1 = Value({}),
        Option2 = Value({}),
    },

    Difficulty = {
        [0] = {
            Name = "Unrated",
            Color = Color3.new(1, 1, 1),
            ImageID = "rbxassetid://12132024589"
        },
        [1] = {
            Name = "Easy",
            Color = Color3.fromRGB(85, 255, 127),
            ImageID = "rbxassetid://12132025467"
        },
        [2] = {
            Name = "Normal",
            Color = Color3.fromRGB(255, 255, 127),
            ImageID = "rbxassetid://12132024792"
        },
        [3] = {
            Name = "Hard",
            Color = Color3.fromRGB(255, 0, 25),
            ImageID = "rbxassetid://12132025088"
        },
        [4] = {
            Name = "Insane",
            Color = Color3.fromRGB(112, 42, 241),
            ImageID = "rbxassetid://12132024949"
        },
        [5] = {
            Name = "Extreme",
            Color = Color3.fromRGB(255, 128, 0),
            ImageID = "rbxassetid://12132025296"
        },
        [6] = {
            Name = "Divine",
            Color = Color3.fromRGB(255, 8, 152),
            ImageID = "rbxassetid://12132025606"
        }
    },  
    Images = {
        Checkbox = {
            Checked = "rbxassetid://6031068421",
            Unchecked = "rbxassetid://6031068420",
            Unknown = "rbxassetid://6031068445"
        }
    }
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
    Util._manualActive:set(value)
end

function Util.CloseMessage()
    Util:ToggleInterface(true)
    Util._Message.Text:set("")
    Util._Message.Header:set("")
    Util._Message.Option1:set({})
    Util._Message.Option2:set({})
end

function Util:ShowMessage(header: string, text: string, option1: any?, option2: any?)
    Util:ToggleInterface(false)
    self._Message.Text:set(text)
    self._Message.Header:set(header)
    self._Message.Option1:set(option1 or {Text = defaultMessageResponses[math.random(1, #defaultMessageResponses)], Callback = Util.CloseMessage})
    self._Message.Option2:set(option2 or {})
end

function Util.updateMapSetting(directory: string, attribute: string, value: any)
    local dirFolder = getSettingsDirFolder(directory)
    if not dirFolder then
        return
    end
    if value == nil then
        return
    end
    dirFolder:SetAttribute(attribute, value)
end

function Util.prefixWarn(...)
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
    local multiplier = 1

    str = string.gsub(str, " ", "")
    if string.find(str, "Color3%.%a%a%a%(", 1) then
        str = string.gsub(str, 'Color3%.%a%a%a%(', "")
        multiplier = 255
    elseif string.find(str, "Color3.%a%a%a%a%a%a%a%(", 1) then
        str = string.gsub(str, 'Color3%.%a%a%a%a%a%a%a%(', "")
    end
    str = string.gsub(str, "%)", "")

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
        math.min(math.floor(split[1] * multiplier + 0.5), 255), 
        math.min(math.floor(split[2] * multiplier + 0.5), 255), 
        math.min(math.floor(split[3] * multiplier + 0.5), 255)

    local newColor = Color3.fromRGB(r, g, b)
    return true, newColor
end

function Util.parseTimeString(str: string): (boolean, string)
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

Selection.SelectionChanged:Connect(function()
    local newTable = {}
    for _, Thing: Instance in pairs(Selection:Get()) do
        if Thing:IsDescendantOf(Util.mapModel:get(false)) then
            table.insert(newTable, Thing)
        end
    end

    if not (#newTable == 0 and #Util.selectedParts:get(false) == 0) then
        Util.selectedParts:set(newTable)
    end
end)

updateButtonsActive()
Observer(Util._Message.Text):onChange(updateButtonsActive)
Observer(Util.mapModel):onChange(updateButtonsActive)
Observer(Util._manualActive):onChange(updateButtonsActive)

return Util
