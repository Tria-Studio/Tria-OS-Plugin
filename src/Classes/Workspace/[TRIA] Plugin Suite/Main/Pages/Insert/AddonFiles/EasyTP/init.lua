--[[ 
	Leave this script parented to the MapScript otherwise it may break. 
	Edit this script at your own risk of breaking it.

	Lighting effects are not applied to spectators.
	
	DoFlash: bolean
	FlashColor: Color3
	FlashDuration: number
	TeleportType: string
	TeleportNumber: number
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Map = script:FindFirstAncestorOfClass("Model")
local Overlap = OverlapParams.new()
local ColorCorrection = Instance.new("ColorCorrectionEffect")

local module = {}
local teleportParts = {}

Overlap.FilterType = Enum.RaycastFilterType.Whitelist
ColorCorrection.Name = "EasyTPColorCorrection"
ColorCorrection.Parent = Lighting


function module.Teleport(TeleportNumber: number)
	assert(teleportParts[TeleportNumber].Start, "[EasyTP] Starting part for teleport number {TeleportNumber} does not exist.")
	assert(teleportParts[TeleportNumber].End, "[EasyTP] End part for teleport number {TeleportNumber} does not exist.")
	
	local TPParts = teleportParts[TeleportNumber]
	local PlayersToTP: {[number]: Player} = {}

	Overlap.FilterDescendantsInstances = workspace:FindFirstChild("Characters")
	for _, Part: BasePart in pairs(workspace:GetPartsInPart(TPParts.Start, Overlap)) do
		local Player = Players:GetPlayerFromCharacter(Part)
		if Part.Name == "HumanoidRootPart" and Player and not table.find(PlayersToTP, Player) then
			table.insert(PlayersToTP, Player)
		end
	end

	for _, Player in pairs(PlayersToTP) do
		local EndPart = TPParts.End
		Player.Character.HumanoidRootPart.CFrame = EndPart.CFrame * CFrame.new(0, -EndPart.Size.Z / 2 + Player.Character.Humanoid.HipHeight, 0)
	end

	if TPParts.Start:GetAttribute("DoFlash") then
		for _, Player in pairs(PlayersToTP) do
			local LocalScript = script.LocalFlash:Clone()
			LocalScript:SetAttribute("FlashColor", TPParts.Start:GetAttribute("FlashColor") or Color3.new(1, 1, 1))
			LocalScript:SetAttribute("FlashDuration", TPParts.Start:GetAttribute("FlashDuration"))
			LocalScript.Parent = Player.PlayerGui
		end
	end
end

local FolderToCheck = Map:FindFirstChild("Special") or Map
for _, Part: Instance in pairs(FolderToCheck:GetDescendants()) do
	local teleportNumber = Part:GetAttribute("TeleportNumber")
	local isStart = Part:GetAttribute("TeleportType")

	if Part.Name == "_Teleporter" then
		teleportParts[teleportNumber][isStart and "Start" or "End"] = Part
	end
end

return module
