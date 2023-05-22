return {
	AutocompleteArgs = {"object", "movement", "duration"},
	Name = "Move",
	Branches = nil,
	Arguments = "Move(object: PVInstance, direction: Vector3, time: number): ()",
	Documentation = {
		value = "Moves an object in world space, not taking the parts orientation into account."
	},
	CodeSample = [[
-- Moves Part1 up 20 studs over a span of 10 seconds
local Map = MapLib.Map  
MapLib:Move(Map.Part1, Vector3.new(0, 20, 0), 10)  ]],
}
