return {
	AutocompleteArgs= {"liquid", "liquidType"},
	Name = "SetLiquidType",
	Branches = nil,
	Documentation = {
		value = "Modifies a liquids type from lava, acid, water, or a custom liquid specified in map settings."
	},
	CodeSample = [[-- Changes all liquids in the map to 'acid'
local Map = MapLib.Map

for _, Liquid: BasePart in pairs(Map.Special.Fluid:GetChildren()) do
	MapLib:SetLiquidType(Liquid, "acid")
end

-- Changes Liquid1 into a custom liquid 'milk' (liquid created under map settings)
MapLib:SetLiquidType(Map.Special.Fluid.Liquid1, "milk")
	]],
}
