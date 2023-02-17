return {
	autocompleteArgs = {"object", "movement", "duration"},
	name = "Move",
	branches = nil,
	documentation = {
		value = "Moves an object in world space"
	},
	codeSample = [[
-- Moves Part1 up 20 studs in 10 seconds
MapLib:Move(MapLib.Map.Part1, Vector3.new(0, 20, 0), 10)]],
}
