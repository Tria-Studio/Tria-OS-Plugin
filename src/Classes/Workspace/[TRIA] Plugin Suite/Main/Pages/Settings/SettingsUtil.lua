local Package = script.Parent.Parent.Parent

local Util = require(Package.Util)
local Fusion = require(Package.Resources.Fusion)
local Components = require(Package.Resources.Components)

local SettingTypes = require(script.Parent:WaitForChild("SettingTypes"))

local Value = Fusion.Value

local SettingsUtil = {
	SettingMaid = Util.Maid.new(),
    Directories = {
        Main = {
            Default = true,
            Display = "Main",
            LayoutOrder = 1,
            Items = Value({}),
        },
        Skills = {
            Default = true,
            Display = "Skills and Features",
            LayoutOrder = 2,
            Items = Value({})
        },
        Lighting = {
            Default = true,
            Display = "Lighting",
            LayoutOrder = 3,
            Items = Value({})
        },
        Liquids = {
            Default = true,
            Display = "Liquids and Gas",
            LayoutOrder = 5,
            Items = Value({})
        }
    }
}

function SettingsUtil.hookAttributeChanged(parent, attribute, callback)
    local conn; conn = parent:GetAttributeChangedSignal(attribute):Once(function()
        conn:Disconnect()
        task.defer(callback)
    end)
    SettingsUtil.SettingMaid:GiveTask(conn)
end

function SettingsUtil.updateStateValue(currentValue, newValue, tbl)
    local acceptedValues = {
        ["String"] = {"string", "number"},
        ["Number"] = {"string", "number"},
        ["Checkbox"] = {"boolean"},
        ["Color"] = {"Color3"},
        ["Time"] = {"string"}
    }

    if currentValue then
        currentValue = newValue
    end
    if not table.find(acceptedValues[tbl.Type], typeof(currentValue)) then
        tbl.Errored:set(true)
        tbl.Value:set(if tbl.Fallback then tbl.Fallback else "")
        Util.debugWarn(("'%s' values aren't accepted for %s objects (%s)"):format(typeof(currentValue), tbl.Type, tbl.Text))
    else
        tbl.Errored:set(false)
        tbl.Value:set(if currentValue ~= nil then currentValue elseif tbl.Fallback ~= nil then tbl.Fallback else "")
    end
end

function SettingsUtil.modifyStateTable(state, action, ...)
    local newTbl = state:get(false)
    local args = {...}

    if action == "insert" then
        table.insert(newTbl, args[1])
    elseif action == "set" then
        newTbl[args[1]] = args[2]
    end
    state:set(newTbl, true)
end

function SettingsUtil.settingOption(optionType, optionData): Instance
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

function SettingsUtil.DirectoryDropdown(data, childProcessor)
    return Components.Dropdown({
        DefaultState = data.Default, 
        Header = data.Display, 
        LayoutOrder = data.LayoutOrder,
        HeaderColor = data.HeaderColor
    }, childProcessor)
end

return SettingsUtil