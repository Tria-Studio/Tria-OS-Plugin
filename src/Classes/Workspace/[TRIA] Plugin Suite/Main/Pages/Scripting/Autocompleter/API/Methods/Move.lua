return {
	AutocompleteArgs= {"object", "movement", "duration"},
	Name = "Move",
	Branches = nil,
	Params = nil,
	Documentation = {
		value = "Moves an object in world space"
	},
	CodeSample = [[
-- Moves Part1 up 20 studs in 10 seconds
MapLib:Move(MapLib.Map.Part1, Vector3.new(0, 20, 0), 10)]],
}