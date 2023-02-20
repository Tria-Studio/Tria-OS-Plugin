return {
	AutocompleteArgs= {"buttonNumber"},
	Name = "GetButtonEvent",
	Documentation = {
		value = "Get's a specific buttons events which allow you to detect when it is pressed"
	},
	CodeSample = [[
MapLib:GetButtonEvent(1):Connect(function()
	
end)
	
MapLib:GetButtonEvent(2):Wait()]],
	
	Branches = {
		["Connect"] = {
			AutocompleteArgs= {"function()\n\nend"},
			Name = "Connect",
			Branches = nil,
			
			Documentation = {
				value = "Allows you to connect a custom function for when a button is pressed"
			},
			CodeSample = [[
MapLib:GetButtonEvent(1):Connect(function()
	print("This runs when button one is clicked.")
end)]],
		},
		["Wait"] = {
			AutocompleteArgs= {""},
			Name = "Wait",
			Branches = nil,
			
			Documentation = {
				value = "Yields/halts the current thread until this button is pressed"
			},
			CodeSample = [[
print("Waiting for button one")
MapLib:GetButtonEvent(1):Wait()
print("Button one pressed!")]],
		}
	}
}
