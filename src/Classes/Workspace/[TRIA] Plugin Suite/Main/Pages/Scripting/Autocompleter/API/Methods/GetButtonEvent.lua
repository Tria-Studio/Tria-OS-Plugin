return {
	autocompleteArgs = {"buttonNumber"},
	name = "GetButtonEvent",
	documentation = {
		value = "Get's a specific buttons events which allow you to detect when it is pressed"
	},
	codeSample = [[
	MapLib:GetButtonEvent(1):Connect(function()
	
	end)
	
	MapLib:GetButtonEvent(2):Wait()
	]],
	
	branches = {
		["Connect"] = {
			autocompleteArgs = {"function()\n\nend"},
			name = "Connect",
			branchType = "method",
			branches = nil,
			
			documentation = {
				value = "Allows you to connect a custom function for when a button is pressed"
			},
			codeSample = [[
			MapLib:GetButtonEvent(1):Connect(function()
				print("This runs when button one is clicked.")
			end)
			]],
		},
		["Wait"] = {
			autocompleteArgs = {""},
			name = "Wait",
			branchType = "method",
			branches = nil,
			
			documentation = {
				value = "Yields/halts the current thread until this button is pressed"
			},
			codeSample = [[
			print("Waiting for button one")
			MapLib:GetButtonEvent(1):Wait()
			print("Button one pressed!")
			]],
		}
	}
}
