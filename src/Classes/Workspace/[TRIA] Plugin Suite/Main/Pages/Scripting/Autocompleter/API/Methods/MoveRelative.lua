return {
	AutocompleteArgs= {"object", "movement", "duration"},
	Name = "MoveRelative",
	Branches = nil,
	Documentation = {
		value = "Moves an object in local space (relative to its own rotation). This should be used instead of MapLib:Move() when you want to move a part on the axis along one of its faces."
	},
	CodeSample = [[
-- Moves Part1 up 20 studs locally in 10 seconds  
MapLib:MoveRelative(MapLib.Map.Part1, Vector3.new(0, 20, 0), 10)  ]],
}
