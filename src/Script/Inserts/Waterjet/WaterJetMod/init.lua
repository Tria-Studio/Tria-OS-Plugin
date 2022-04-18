--[[	
	WaterJet TRIA.OS mod V1.0 made by grif_0 (not_grif)
	
	This module is to only be used inside of TRIA:os. This module was created to add agility features to underwater gameplay by 
	adding customizable jetstreams.
	
	I have attached an example jet fan for reference.
	
	Please give me any feedback on what I could improve on twitter (@grif_0) or in the TRIA community server.
	
	
	Thanks for using this! Enjoy!
	
	 - grif
	
	
	
	
	TO INSTALL:
		 - Place this module directly inside of your MapScript. Do not edit or delete any children of this part. 
		 - Inside of the LocalWaterJet script, set the value of the ObjectValue 'Map' to your map model.
		 - Inside of your MapScript, insert the following code at the top of your script below the line where you define Lib:
		 	
		 		local WaterjetMod = require(script.WaterjetMod)
	
	
	
	
	TO EDIT JETS:
	

    WaterJet parts MUST:
        - Be a BasePart (Not a mesh or a union)
        - Follow the following naming scheme: _WaterJet[you can put whatever after this]
        - The FRONT face is the face that becomes the jetstream

    Editable Properties:
    
    [Attributes]
        - Distnace: number - how far the waterstream will be active
        - Speed: number - studs per second on how fast you will travel
        - Type: string - Determines the area in which the jetstream is active on the parts front face:
			- "Square": he entire face of the part
			- "Cylinder": Creates a cylinder with the diameter of the SMALLER EDGE SIZE in the center of the part.

    	- ParticleId: number - the assetID of the chosen particle emitter. Leave 0 for none.
    	
    [BoolValue inside fan part]
    	- Enabled: boolean - Determines whether or not the fan is active
    	
    	
    	
    To toggle fan states easily, you can use the function below:
    
   		function module:SetFanEnabled(Fan: Part, Enabled: boolean)

end

]]


local module = {}



function module:SetFanEnabled(Fan: Part, Enabled: boolean)
	Fan.Enabled.Value = Enabled
end

for _, Player in pairs(game.Players:GetPlayers()) do
	local Copy = script.LocalWaterjet:Clone()
	Copy.Disabled = false
	Copy.Parent = Player.PlayerGui
end



return module
