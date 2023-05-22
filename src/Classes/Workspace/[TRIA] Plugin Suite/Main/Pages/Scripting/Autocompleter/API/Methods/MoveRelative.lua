return {
	AutocompleteArgs = {"object", "movement", "duration"},
	Name = "MoveRelative",
	Branches = nil,
	Arguments = "Move(object: PVInstance, direction: Vector3, time: number): ()",
	Documentation = {
		value = "Moves an object in local space (relative to its own rotation). This should be used instead of MapLib:Move() when you want to move a part on the axis along one of its faces."
	},
	CodeSample = [[local Map = MapLib.Map

-- Moves a part named Part1 up 20 studs in relative to its orientation over 10 seconds  
MapLib:MoveRelative(Map.Part1, Vector3.new(0, 20, 0), 10)  ]],
}
