local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)

local DEFAULT_LIQUIDS = {
    {
        Name = "Water",
        Value = "water",
        TextColor = Color3.fromRGB(0, 143, 156)
    }, {
        Name = "Acid",
        Value = "acid",
        TextColor = Color3.fromRGB(0, 255, 0)
    }, {
        Name = "Lava",
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
                Name = tbl.Name,
                Image = tbl.Image,
                Value = i,
                TextColor = tbl.Color
            }
        end
        return data, Enum.SortOrder.LayoutOrder
    end,
    LiquidType = function()
        local data = table.clone(DEFAULT_LIQUIDS)
        for i, child in ipairs(Util.mapModel:get(false).Settings.Liquids:GetChildren()) do
            data[3 + i] = {
                Name = child.Name,
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
                Name = material.Name,
                Value = material.Name
            })
        end
        return data, Enum.SortOrder.Name
    end,
    Locators = function()
        return {
            {
                Name = "Default",
                Value = "default",
                Image = "rbxassetid://6274811030",
            }, {
                Name = "Classic",
                Value = "classic",
                Image = "rbxassetid://6275599542",
            }, {
                Name = "Circle",
                Value = "circle",
                Image = "rbxassetid://6275600040",
            }, {
                Name = "Square",
                Value = "square",
                Image = "rbxassetid://6275600378",
            },
        }
    end
}
