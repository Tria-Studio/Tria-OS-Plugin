local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")

local Package = script.Parent
local Resources = Package.Resources

local Fusion = require(Resources.Fusion)
local Pages = require(Resources.Components.Pages)

local Maid = require(script.Maid)
local Signal = require(script.Signal)

local Value = Fusion.Value
local Observer = Fusion.Observer
local Computed = Fusion.Computed

local selectionMaid = Maid.new()
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local oldUniverseId = game.GameId
local oldPlaceId = game.PlaceId

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

    _Addons = {
        hasAddonsWithObjectTags = Value(false),
        hasWaterjet = Value(false),
        hasEasyTP = Value(false)
    },
    _Slider = {
        isUsingSlider = Value(false),
        currentSlider = Value(nil)
    },
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
        },
        [7] = {
            Name = "Eternal",
            Color = Color3.fromRGB(255, 255, 255),
		    Image = "rbxassetid://12741946741",
        }
    }, 

    _Headers = {
        ERROR_HEADER = "<font color='rgb(196, 108, 100)'>Error</font>",
        WARNING_HEADER = "<font color='rgb(245, 193, 51)'>Warning</font>",
        DEBUG_HEADER = "<font color='rgb(100, 100, 100)'>Plugin Debug Menu</font>",
        WIP_HEADER = "<font color='rgb(145, 195, 255)'>Work In Progress</font>"
    },
    _Errors = {
        HTTP_ERROR = "<font color='rgb(180, 180, 180)'>HTTP Error</font>",
        SCRIPT_INSERT_ERROR = "There was an error while trying to insert the requested script. This may be due to the plugin not having script injection permissions, you can change this in the \"Plugin Settings\" tab.",
        AUTOCOMPLETE_ERROR = "There was an error while trying to initiate autocomplete. This may be due to the plugin not having script injection permissions, you can change this in the \"Plugin Settings\" tab.", 
    },
    _DEBUG = {
        _HttpPing = Value("Pinging..."),
        _Fps = Value(0),
        _SuggesterResponse = Value("Waiting..."),
        _Uptime = Value(0),
        _GitStatus = Value("Pinging...")
    },
    _showArrows = Value(true),
}

local function getSettingsDirFolder(directory: string): Instance?
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

    for index, child in ipairs(split) do
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
    self._Message.Option2:set(option1 and not option2 and {Text = "Ok", Callback = Util.CloseMessage} or option2 or {})
end

function Util.isPluginFrozen(): boolean
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

function Util.getDirFolder(directory: string): Instance?
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
    for _, v in ipairs(split) do
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

function Util.parseTextColor3(color: string): string
    local newColor = (color == "" or not color) and Color3.new(0, 0, 0) or color
    return string.format("%d, %d, %d",
        newColor.R * 255,
        newColor.G * 255,
        newColor.B * 255)
end

function Util.parseTimeString(str: string): (boolean, string | nil)
    local split = string.split(str, ":")

    if #split ~= 3 then
        return false, nil
    end

    for i, v in ipairs(split) do
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

local function updateButtonsActive()
    Util.interfaceActive:set(Util.mapModel:get(false) and Util._manualActive:get(false))
end

function Util.updateSelectedParts()
    local newTable = {}
    for _, thing: Instance in ipairs(Selection:Get()) do
        if thing:IsDescendantOf(Util.mapModel:get(false)) then
            table.insert(newTable, thing)
        end
    end

    if not (#newTable == 0 and #Util._Selection.selectedParts:get(false) == 0) then
        selectionMaid:DoCleaning()
        Util._Selection.selectedParts:set(newTable)
        
        for _, thing: Instance in ipairs(Selection:Get()) do
            local function update()
                Util._Selection.selectedUpdate:set(Util._Selection.selectedUpdate:get(false) + 1)
            end
            selectionMaid:GiveTask(thing:GetPropertyChangedSignal("Name"):Connect(update))
            selectionMaid:GiveTask(thing:GetAttributeChangedSignal("_action"):Connect(update))
            selectionMaid:GiveTask(thing.Destroying:Connect(update))
            selectionMaid:GiveTask(thing.ChildRemoved:Connect(update))
            selectionMaid:GiveTask(thing.AncestryChanged:Connect(update))

            selectionMaid:GiveTask(thing.ChildAdded:Connect(function(newThing: Instance)
                if newThing:IsA("ValueBase") then
                    update()
                end
                selectionMaid:GiveTask(newThing.Changed:Connect(update))
            end))

            for _, child in ipairs(thing:GetChildren()) do
                if child:IsA("ValueBase") then
                    selectionMaid:GiveTask(thing.ChildRemoved:Connect(update))
                end
            end
        end
    end
end

function Util.attemptScriptInjection()
    local hasScriptInjection = pcall(function()
        local newScript = Instance.new("Script", game.CoreGui)
        newScript.Name = ""
        newScript.Parent = game.CoreGui
    
        task.delay(1, newScript.Destroy, newScript)
        newScript.Source = "Test"
    end)
    
    plugin:SetSetting("TRIA_ScriptInjectionEnabled", hasScriptInjection)
end

function Util.failedScriptInjection(errorMessage: string): boolean
    Util.attemptScriptInjection()
    if not plugin:GetSetting("TRIA_ScriptInjectionEnabled") then
        Util:ShowMessage(Util._Headers.ERROR_HEADER, errorMessage)
        return true
    end
    return false
end

function Util.getObjectCountWithNameMatch(pattern: string, path: Instance?, anyInstance: boolean?): number
    local map = Util.mapModel:get(false)
    local check = path or Util.hasSpecialFolder:get(false) and map.Special or map

    local highest = 0
    for _, model: Instance in ipairs(check:GetDescendants()) do 
        if (model:IsA("Model") or anyInstance) and model.Name:match(pattern .. "%d+") then 
            local objectNum = tonumber(model.Name:match(pattern .. "(%d+)")); 
            if objectNum then
                highest = math.max(highest, objectNum)
            end
        end 
    end
    return highest
end

function Util.round(num: number, step: number): number
	return math.round(num / step) * step
end

function Util.secondsToTime(t: number): string
    local timeStr = ""

    local formatters = {
        t / 60 ^ 2,     -- H
        t / 60 % 60,    -- M
        t % 60,         -- S
    }
    
    for i = 1, #formatters do
        if math.floor(formatters[i]) > 0 or i > 1 then
            timeStr ..= (i == 2 and "%01i%s" or "%02i%s"):format(formatters[i], i == #formatters and "" or ":")
        end
    end

    return timeStr
end

function Util.lerp(a: any<T>, b: any<T>, t: any<T>): any<T>
    return (1 - t) * a + t * b
end

function Util.getRollingAverage(data: {number}, backCount: number): number
    if #data < 1 then
        return 0
    end
    
    local newData = {}
    local startIndex = if #data + 1 > backCount then #data - backCount else 1

    for i = startIndex, #data do
        table.insert(newData, data[i])
    end

    local sum = 0
    for i = 1, #newData do
        sum += newData[i]
    end
    return sum / #newData
end

function Util.toggleAudioPerms(enabled: boolean)
    game:SetUniverseId(enabled and 2330396164 or oldUniverseId) 
    game:SetPlaceId(enabled and 6311279644 or oldPlaceId)
end

local function schedule(task: (number) -> (), interval: number)
    local lastUpdate = 0

    Util.MainMaid:GiveTask(RunService.Heartbeat:Connect(function(deltaTime: number)
        if os.clock() - lastUpdate >= interval then
            lastUpdate = os.clock()
            task(deltaTime)
        end
    end))
end

do
    local fpsTimes = {}
    task.defer(schedule, function(deltaTime: number)
        table.insert(fpsTimes, 1 / math.clamp(deltaTime, 1/1000, deltaTime + 0.1))
        Util._DEBUG._Fps:set(math.floor(Util.getRollingAverage(fpsTimes, 30)))
    end, 0.05)
end

local githubUrl = "https://www.githubstatus.com/api/v2/status.json"

do
    local httpTimes = {}
    task.defer(schedule, function()
        local start = os.clock()
        local fired, result = pcall(HttpService.GetAsync, HttpService, githubUrl, true)
        if fired then
            table.insert(httpTimes, (os.clock() - start) * 1000)
            Util._DEBUG._HttpPing:set(("%dms"):format(Util.getRollingAverage(httpTimes, 10)))
        else
            Util._DEBUG._HttpPing:set(Util._Errors.HTTP_ERROR)
        end
    end, 10)
end

do
    task.defer(schedule, function()
        local fired, response = pcall(HttpService.GetAsync, HttpService, githubUrl, true)
        local colorMap = {
            ["none"] = "<font color='rgb(66, 245, 126)'>%s</font>",
            ["minor"] = "<font color='rgb(235, 235, 68)'>%s</font>",
            ["major"] = "<font color='rgb(235, 140, 68)'>%s</font>",
            ["critical"] = "<font color='rgb(209, 66, 59)'>%s</font>"
        }
    
        if fired then
            response = HttpService:JSONDecode(response)
            if colorMap[response.status.indicator] then
                Util._DEBUG._GitStatus:set(colorMap[response.status.indicator]:format(response.status.description))
            end
        else
            Util._DEBUG._GitStatus:set(Util._Errors.HTTP_ERROR)
        end
    end, 10)
end

do
    task.defer(schedule, function()
        Util._DEBUG._Uptime:set(Util._DEBUG._Uptime:get(false) + 1)
    end, 1)
end

updateButtonsActive()
Observer(Util._Message.Text):onChange(updateButtonsActive)
Observer(Util.mapModel):onChange(updateButtonsActive)
Observer(Util._manualActive):onChange(updateButtonsActive)
Util.MainMaid:GiveTask(Util.MapMaid)
Util.MainMaid:GiveTask(selectionMaid)
Util.MainMaid:GiveTask(Selection.SelectionChanged:Connect(Util.updateSelectedParts))

return Util
