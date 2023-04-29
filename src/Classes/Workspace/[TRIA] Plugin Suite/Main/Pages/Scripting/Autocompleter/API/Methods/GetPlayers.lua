return {
	AutocompleteArgs = {""},
	Name = "GetPlayers",
	Branches = nil,
	Documentation = {
		value = "Returns an array with all current players in the map."
	},
	CodeSample = [[local currentPlayers = MapLib:GetPlayers()  

for i, player: Player in pairs(currentPlayers) do  
	-- Code here will run for all players in the round  
	print(player.Name .. " is in the round and alive!")
end  ]],
}
