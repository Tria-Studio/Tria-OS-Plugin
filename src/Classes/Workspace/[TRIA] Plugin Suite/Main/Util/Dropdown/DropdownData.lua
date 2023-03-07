local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)

local DEFAULT_LIQUIDS = {
    {
        Value = "water",
        TextColor = Color3.fromRGB(0, 143, 156)
    }, {
        Value = "acid",
        TextColor = Color3.fromRGB(0, 255, 0)
    }, {
        Value = "lava",
        TextColor = Color3.fromRGB(255, 0, 0)
    },
}

return {
    Difficulty = function()
        local data = {}
        for i = 1, 7 do
            local tbl = Util.Difficulty[i - 1]
            data[i] = {
                Image = tbl.Image,
                Value = i - 1,
                TextColor = tbl.Color
            }
        end
        return data, Enum.SortOrder.LayoutOrder
    end,
    LiquidType = function()
        local data = table.clone(DEFAULT_LIQUIDS)
        for i, child in ipairs(Util.mapModel:get(false).Settings.Liquids:GetChildren()) do
            data[3 + i] = {
                Value = child.Name,
                TextColor = child:GetAttribute("Color")
            }
        end
        return data, Enum.SortOrder.LayoutOrder
    end,
    Liquids = function()
        return table.clone(DEFAULT_LIQUIDS), Enum.SortOrder.LayoutOrder
    end,
    Materials = function()
        local data = {}
        for i, material in ipairs(Enum.Material:GetEnumItems()) do
            if material.Name == "Air" or material.Name == "Water" then
                continue
            end
            table.insert(data, {
                Value = material.Name
            })
        end
        return data, Enum.SortOrder.Name
    end,
    Locators = function()
        return {
            {
                Value = "default",
                Image = "rbxassetid://6274811030",
            }, {
                Value = "classic",
                Image = "rbxassetid://6275599542",
            }, {
                Value = "circle",
                Image = "rbxassetid://6275600040",
            }, {
                Value = "square",
                Image = "rbxassetid://6275600378",
            },
        }
    end,
    TeleportType = function()
        return {
            {Value = "start"},
            {Value = "end"},
        }
    end,
    BubbleParticle = function()
        return {
            {Value = "default"}
        }
    end,
    FanShape = function()
        return {
            {Value = "square"},
            {Value = "circle"}
        }
    end
}
