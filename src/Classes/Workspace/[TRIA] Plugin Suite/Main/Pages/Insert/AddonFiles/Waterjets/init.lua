--[[	
	WaterJet Mod created by not_grif and Kris
	GRIF PUT INSTRUCTIONS HERE PLS
]]


local Waterjets = {}

function Waterjets:SetFanEnabled(fan: Part, enabled: boolean)
	fan:SetAttribute("Enabled", boolean)
end

for _, player in pairs(game.Players:GetPlayers()) do
	local clonedScript = script.WaterjetClient.lua:Clone()
	clonedScript.Disabled = false
	clonedScript.Parent = Player.PlayerGui
end

return Waterjets