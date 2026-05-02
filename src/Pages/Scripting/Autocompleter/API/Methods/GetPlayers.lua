-- Original code from: https://devforum.roblox.com/t/lexer-for-rbx-lua/183115
-- Modified and adapted for TRIA.os Plugin :D

return {
	Name = "GetPlayers",
	Branches = nil,
	Arguments = "GetPlayers(): {Player}",
	Documentation = {
		value = "Returns an array with all current players in the map."
	},
	CodeSample = [[local currentPlayers = MapLib:GetPlayers()  

for i, player: Player in pairs(currentPlayers) do  
	-- Code here will run for all players in the round  
	print(player.Name .. " is in the round and alive!")
end  ]],
}
