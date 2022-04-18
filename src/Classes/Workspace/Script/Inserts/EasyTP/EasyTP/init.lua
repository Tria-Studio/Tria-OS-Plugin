--[[
	EasyTP by not_grif (@grif_0)
	
	INSTRUCTIONS:
		1) Parent this module into your map script
		2) Require this in your MapScript with the following
				local EasyTP = require(script.EasyTP)

		3) Define your teleporting parts with the following naming scheme:
				_Teleport[TeleportNumber][Start or End]
				
				Example:
					_Teleport1Start, _Teleport1End

			- In order to set a custom flash color per flash, you can add copy this table into the table 'TeleportParts' on Line 47.
					[TeleportNumber] = {
						FlashColor = [The Flash Color. If nil or not stated, it will use the default color on Line 45.],
					},

		4) Enable/Disable flashing on Line 44
		5) Set up your teleport parts
			- Size doesnt matter, Make it transparent and CanCollide false. Players will be teleported to the center of the End part,
			  facing the FRONT FACE of the part.

		6) Call a teleport using with the followng:
				EasyTP.Teleport(TeleportNumber)



	Enjoy!
	 - grif_0

]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Map = script:FindFirstAncestorOfClass("Model")
local Overlap = OverlapParams.new()



local module = {
	DoFlashing = true, --// Should the screen flash when teleporting?
	FlashColor = Color3.fromRGB(255, 255, 255), --// Color of the flash
}
local TeleportParts: {[number]: {Start: BasePart?, End: BasePart?, FlashColor: Color3?} } = {
	[1] = {
		FlashColor = nil,
	},
}

Overlap.FilterType = Enum.RaycastFilterType.Whitelist



function module.Teleport(TeleportNumber: number)
	TeleportParts[TeleportNumber] = TeleportParts[TeleportNumber] or {Start = nil, End = nil, FlashColor = nil}

	local TPParts = TeleportParts[TeleportNumber]
	local PlayersToTP: {[number]: Player} = {}
	local ColorCorrection: ColorCorrectionEffect = Lighting:FindFirstChild("_qwertyuiopasdfghjklzxcvbnm")
	local Characters = {}

	TPParts.Start = Map:FindFirstChild(string.format("_Teleport%dStart", TeleportNumber), true)
	TPParts.End = Map:FindFirstChild(string.format("_Teleport%dEnd", TeleportNumber), true)

	assert(TPParts.Start, string.format("Start for Teleport %d not found.", TeleportNumber))
	assert(TPParts.End, string.format("End for Teleport %d not found.", TeleportNumber))

	for _, Player in pairs(Players:GetPlayers()) do
		table.insert(Characters, Player.Character)
	end

	if not ColorCorrection then
		ColorCorrection = Instance.new("ColorCorrectionEffect")
		ColorCorrection.Name = "_qwertyuiopasdfghjklzxcvbnm"
		ColorCorrection.Parent = Lighting
	end

	Overlap.FilterDescendantsInstances = Characters

	for _, Part: BasePart in pairs(workspace:GetPartsInPart(TPParts.Start, Overlap)) do
		if Part.Name ~= "HumanoidRootPart" then
			continue
		end
		local Player: Player = Players:GetPlayerFromCharacter(Part.Parent)

		if Player then
			table.insert(PlayersToTP, Player)
		end
	end

	for _, Player: Player in pairs(PlayersToTP) do
		local Character = Player.Character
		Character.HumanoidRootPart.CFrame = TPParts.End.CFrame
	end

	if module.DoFlashing or TPParts.FlashColor then
		for _, Player in pairs(PlayersToTP) do
			local LocalScript = script.LocalFlash:Clone()
			local Color = TPParts.FlashColor or module.FlashColor or Color3.fromRGB(255, 255, 255)
			
			LocalScript.Disabled = false
			LocalScript:SetAttribute("TintColor", Color)
			LocalScript.Parent = Player.PlayerGui
		end
	end
end

return module
