return {
	Name = "Survive",
	Branches = nil,
	Arguments = "Survive(player: Player): ()",
	Documentation = {
		value = "Calling this function will make the player survive without needing to touch the ExitRegion."
	},
	CodeSample = [[-- causes all player mid-round to survive the round  
local PlayersInRound = MapLib:GetPlayers()  
	
for _, Player: Player in pairs(PlayersInRound) do  
	MapLib:Survive(Player)  
end	]],
}
