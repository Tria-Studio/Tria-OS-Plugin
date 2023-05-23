return {
	Name = "RoundEnding",
	Arguments = "RBXScriptSignal",
	Documentation = {
		value = "Fires when the round ends, usually used in cleanup of the round."
	},
    Kind = Enum.CompletionItemKind.Event,

    Branches = {
		["Connect"] = {
			Name = "Connect",
			Branches = nil,
			Arguments = "Connect(self: RBXScriptSignal, func: (...any) -> ()): RBXScriptConnection",
			Documentation = {
				value = "Allows you to connect a custom function for when a button is activated"
			},
			CodeSample = [[local Map = MapLib.Map

MapLib.RoundEnding:Connect(function(player)  
	print("Round is over!")  
end)  ]],
		},
		["Wait"] = {
			Name = "Wait",
			Branches = nil,
			Arguments = "Wait(_: RBXScriptSignal): Instance",
			Documentation = {
				value = "Yields/halts the current thread until this button is activated"
			},
			CodeSample = [[
print("Waiting for the round to end...")  
MapLib.RoundEnding:Wait()  
print("Round ended!")  ]],
		}
	}
}
