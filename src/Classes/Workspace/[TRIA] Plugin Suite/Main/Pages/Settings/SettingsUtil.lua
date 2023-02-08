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
            IsHeader = true,
            LayoutOrder = 1,
            Items = Value({}),
        },
        Buttons = {
            Default = true,
            IsHeader = true,
            Display = "Buttons",
            LayoutOrder = 2,
            Items = Value({})
        },
        Lighting = {
            Default = true,
            IsHeader = true,
            Display = "Lighting",
            LayoutOrder = 3,
            Items = Value({})
        },
        Skills = {
            Default = true,
            IsHeader = true,
            Display = "Skills and Features",
            LayoutOrder = 5,
            Items = Value({})
        },
        Liquids = {
            IsHeader = true,
            Default = true,
            Display = "Liquids and Gas",
            LayoutOrder = 6,
            Items = Value({})
        }
    }
}

function SettingsUtil.hookAttributeChanged(parent, attribute, callback)
    SettingsUtil.SettingMaid:GiveTask(parent:GetAttributeChangedSignal(attribute):Once(function()
        task.defer(callback)
    end))
end

function SettingsUtil.updateStateValue(currentValue, newValue, tbl)
    local acceptedValues = {
        ["String"] = {"string", "number"},
        ["Number"] = {"string", "number"},
        ["Checkbox"] = {"boolean"},
        ["Color"] = {"Color3"},
        ["Time"] = {"string"},
        ["Dropdown"] = {"string"}
    }

    if currentValue ~= nil then
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
    elseif action == "remove" then
        table.remove(newTbl, args[1])
    end
    state:set(newTbl, true)
end

function SettingsUtil.connectValue(object, data)
    local currentValue = object:GetAttribute(data.Attribute)
    local function updateConnection()
        SettingsUtil.updateStateValue(currentValue, object:GetAttribute(data.Attribute), data)
        SettingsUtil.hookAttributeChanged(object, data.Attribute, updateConnection)
    end
    updateConnection()
end

function SettingsUtil.settingOption(optionType, optionData): Instance
    local newOption = SettingTypes[optionType](optionData)
    return newOption 
end

function SettingsUtil.DirectoryDropdown(data, childProcessor)
    return Components.Dropdown({
        DefaultState = data.Default, 
        Header = data.Display, 
        HasButton = data.HasButton,
        IsHeader = data.IsHeader,
        IsSecondary = data.IsSecondary,
        LayoutOrder = data.LayoutOrder,
        HeaderColor = data.HeaderColor,
        HeaderChildren = data.HeaderChildren,
        HeaderEditable = data.HeaderEditable,
        OnHeaderChange = data.OnHeaderChange
    }, childProcessor)
end

return SettingsUtil
