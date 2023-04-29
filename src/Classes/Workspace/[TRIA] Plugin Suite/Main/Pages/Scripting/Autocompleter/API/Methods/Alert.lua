return {
	AutocompleteArgs = {"text", "color", "duration"},
	Name = "Alert",
	Branches = nil,
	Documentation = {
		value = "Sends an alert out to all players ingame with a custom text, color and duration."
	},
	CodeSample = [[MapLib:Alert("This is an alert colored red!", Color3.fromRGB(255, 0, 0), 5)  
-- Countdown with alerts from 3
MapLib:Alert("3..", Color3.new(1, 1, 1), 1)
task.wait(1)
MapLib:Alert("2..", Color3.new(1, 1, 1), 1)
task.wait(1)
MapLib:Alert("1...", Color3.new(1, 1, 1), 1)
task.wait(1)
MapLib:Alert("GO!!!", Color3.new(1, 1, 1), 1)

	]]
}
