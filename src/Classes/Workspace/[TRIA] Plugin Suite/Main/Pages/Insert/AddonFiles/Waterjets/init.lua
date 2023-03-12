--[[	
	Waterjets TRIA.OS addon V1.0 made by not_grif and Kris
	
	This module is to only be used inside of TRIA:os. This module was created to add agility features to underwater gameplay by 
	adding customizable jetstreams.
	
	TO EDIT JETS:
	
    Waterjet fans MUST:
        - Be a BasePart (Not a mesh or a union)
        - Follow the following naming scheme: _WaterJet[you can put whatever after this]
        - The FRONT face is the face that becomes the jetstream
    	
    FanNumber [number]: A unique identifier for the fan in use of scripting.
    FanSpeed [number]: Speed in studs/sec that the fan will push players inside its bounds.
    Distance [number]: The total distance that the fan can push you.
    LinearMovement [boolean]: When true, the fans push players at a constant rate throughout the entire distance. When false, the rate that the fan pushes players decreases as you get farther away.
    FanShape [string]: Determines if the bounds that the fan will push players in is a cylinder, or a box.
    Enabled [boolean]: Determines whether the fan is currently active.
    BubbleParticle [number]: The number of the ImageID that the fan's particles will show. 
    	
    To toggle fan states easily, you can use the function below:
   		function module:SetFanEnabled(Fan: Part, Enabled: boolean)
	

	Leave this script parented to the MapScript otherwise it may break. 
	Edit anything below at your own risk of breaking the addon or the plugin.
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
	local clonedScript = script.WaterjetClient:Clone()
	clonedScript.Enabled = true
	clonedScript.Parent = player.PlayerGui
end

return Waterjets
