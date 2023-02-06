local Package = script.Parent.Parent.Parent
local Util = require(Package.Util)

return {
    Difficulty = function()
        local data = {}
        for i, data in ipairs(Util.Difficulty) do
            data[i] = {
                Name = data.Name,
                Image = data.Image,
                Value = i,
                TextColor = data.Color
            }
        end
        return data, Enum.SortOrder.LayoutOrder
    end,
    LiquidType = function()
        local data = {
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
        for i, child in pairs(Util.mapModel:get().Settings.Liquids:GetChildren()) do
            data[3 + i] = {
                Name = child.Name,
                Value = child.Name,
                TextColor = child:GetAttribute("Color")
            }
        end
        return data, Enum.SortOrder.LayoutOrder
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
    end
}
