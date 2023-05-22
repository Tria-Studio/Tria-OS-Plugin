return {
	AutocompleteArgs = {"buttonNumber"},
	Name = "GetButtonEvent",
	Arguments = "GetButtonEvent(buttonNumber: number): RBXScriptSignal",
	Documentation = {
		value = "Get's a specific buttons events which allow you to detect when it is activated"
	},
	CodeSample = [[
MapLib:GetButtonEvent(1):Connect(function()  
	-- Code inside here will run when button 1 is activated  
end)  

print("Waiting for button 2")  
MapLib:GetButtonEvent(2):Wait()  
print("Button 2 was activated!")  ]],
	
	Branches = {
		["Connect"] = {
			AutocompleteArgs = {"function()\n\nend"},
			Name = "Connect",
			Branches = nil,
			Arguments = "Connect(self: RBXScriptSignal, func: (...any) -> ()): RBXScriptConnection",
			Documentation = {
				value = "Allows you to connect a custom function for when a button is activated"
			},
			CodeSample = [[local Map = MapLib.Map

MapLib:GetButtonEvent(1):Connect(function(player)  
	print("Button 1 was activated!")  

	-- Sets the liquid type to 'lava' and then moves the part up when button 1 is activated  
	MapLib:SetLiquidType(Map.Special.Fluid._Liquid3, "lava")  
	task.wait(0.5)  
	MapLib:Move(Map.Special.Fluid._Liquid3, Vector3.new(0, 40, 0), 7)  
end)  ]],
		},
		["Wait"] = {
			AutocompleteArgs = {""},
			Name = "Wait",
			Branches = nil,
			Arguments = "Wait(_: RBXScriptSignal): Instance",
			Documentation = {
				value = "Yields/halts the current thread until this button is activated"
			},
			CodeSample = [[
print("Waiting for button one to be activated...")  
MapLib:GetButtonEvent(1):Wait()  
print("Button 1 was activated!")  ]],
		}
	}
}
