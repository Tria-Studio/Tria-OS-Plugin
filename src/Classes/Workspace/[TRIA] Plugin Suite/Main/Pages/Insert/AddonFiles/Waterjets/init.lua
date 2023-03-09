--[[	
	WaterJet Mod created by not_grif and Kris
	GRIF PUT INSTRUCTIONS HERE PLS
]]
local RunService = game:GetService("RunService")

local Waterjets = {}

function Waterjets:SetFanEnabled(fan: Part, enabled: boolean)
	fan:SetAttribute("Enabled", enabled)
end

if RunService:IsStudio() and not RunService:IsRunning() then
	return {SetFanEnabled = 0}
end

for _, player in pairs(game.Players:GetPlayers()) do
	local clonedScript = script.WaterjetClient.lua:Clone()
	clonedScript.Disabled = false
	clonedScript.Parent = player.PlayerGui
end

return Waterjets
