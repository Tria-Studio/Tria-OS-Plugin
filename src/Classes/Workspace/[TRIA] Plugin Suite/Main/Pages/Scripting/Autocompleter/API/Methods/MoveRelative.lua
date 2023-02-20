return {
	AutocompleteArgs= {"object", "movement", "duration"},
	Name = "MoveRelative",
	Branches = nil,
	Documentation = {
		value = "Moves an object in local space (relative to its own rotation)"
	},
	CodeSample = [[
-- Moves Part1 up 20 studs locally in 10 seconds
MapLib:MoveRelative(MapLib.Map.Part1, Vector3.new(0, 20, 0), 10)]],
}
