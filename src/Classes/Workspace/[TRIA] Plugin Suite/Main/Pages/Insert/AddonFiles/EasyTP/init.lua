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
local RunService = game:GetService("RunService")

local currentMap = script:FindFirstAncestorOfClass("Model")
local teleportParts = {}

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "EasyTPColorCorrection"
colorCorrection.Parent = Lighting

local EasyTP = {}

function EasyTP.Teleport(teleportNumber: number)
	assert(teleportParts[teleportNumber].Start, `[EasyTP] Starting part for teleport number {teleportNumber} does not exist.`)
	assert(teleportParts[teleportNumber].End, `[EasyTP] End part for teleport number {teleportNumber} does not exist.`)
	
	local currentTeleportParts = teleportParts[teleportNumber]
	local playersToTeleport = {}

	overlapParams.FilterDescendantsInstances = workspace:FindFirstChild("Characters")
	for _, part: BasePart in pairs(workspace:GetPartsInPart(currentTeleportParts.Start, overlapParams)) do
		local player = Players:GetPlayerFromCharacter(part)
		if part.Name == "HumanoidRootPart" and player and not table.find(playersToTeleport, player) then
			table.insert(playersToTeleport, player)
		end
	end

	for _, player in pairs(playersToTeleport) do
		local endPart = currentTeleportParts.End
		player.Character.HumanoidRootPart.CFrame = endPart.CFrame * CFrame.new(0, -endPart.Size.Z / 2 + player.Character.Humanoid.HipHeight, 0)
	end

	if currentTeleportParts.Start:GetAttribute("DoFlash") then
		for _, player in pairs(playersToTeleport) do
			local localFlashScript = script.LocalFlash:Clone()
			localFlashScript:SetAttribute("FlashColor", currentTeleportParts.Start:GetAttribute("FlashColor") or Color3.new(1, 1, 1))
			localFlashScript:SetAttribute("FlashDuration", currentTeleportParts.Start:GetAttribute("FlashDuration"))
			localFlashScript.Parent = player.PlayerGui
		end
	end
end

if RunService:IsStudio() then
	return {Teleport = 0}
end

local folder = currentMap:FindFirstChild("Special") or currentMap
for _, part in pairs(folder:GetDescendants()) do
	local teleportNumber = part:GetAttribute("TeleportNumber")
	local isStart = part:GetAttribute("TeleportType")

	if part.Name == "_Teleporter" then
		teleportParts[teleportNumber][isStart and "Start" or "End"] = part
	end
end

return EasyTP
