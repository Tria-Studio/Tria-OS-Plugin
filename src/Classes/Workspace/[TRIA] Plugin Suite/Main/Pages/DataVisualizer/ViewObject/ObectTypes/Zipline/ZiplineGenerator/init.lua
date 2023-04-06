-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local ZiplineService = {}
local Package = script.Parent.Parent.Parent.Parent.Parent.Parent
local RopeFuncs = require(script.RopeFuncs)
local Util = require(Package.Util)


function ZiplineService:generate(rope: Model): (boolean, {} | nil)
	local ropeModel = Instance.new("Model")
	ropeModel.Name = "ZiplineModel"
	ropeModel.Parent = rope.Parent

	local DEFAULT_SPEED = 40

	local customizationFolder = rope:FindFirstChild("Customization")

	local sparkleEnabled = if customizationFolder then customizationFolder:GetAttribute("Sparkle") else true
	local customSparkle = nil

	if sparkleEnabled and customizationFolder then
		customSparkle = customizationFolder:FindFirstChild("_Sparkle")
	end

	local data = {
		Rope = ropeModel,

		Sparkle = {
			Enabled = sparkleEnabled,
			Emitter = if customSparkle and customSparkle:IsA("ParticleEmitter")
				then customSparkle:Clone()
				else "Default",
		},
		Jumpable = if customizationFolder then customizationFolder:GetAttribute("Jumpable") == true else false,
		Momentum = if customizationFolder then customizationFolder:GetAttribute("Momentum") == true else false,

		Speed = if customizationFolder then customizationFolder:GetAttribute("Speed") else DEFAULT_SPEED,
		Length = 0,
	}

	if tonumber(data.Speed) == nil then
		data.Speed = DEFAULT_SPEED
	end

	local points = {}
	for _, part in ipairs(rope:GetChildren()) do
		if tonumber(part.Name) then
			table.insert(points, part)
		end
	end
	points = RopeFuncs.sortPointsArray(points)
	if #points < 2 then
		return false, "Not enough points!"
	end
	if points[1]:GetAttribute("_action") ~= "Zipline" then
		return false, "No _action attribute!"
	end

	local positions, totalLength = RopeFuncs.generateRope(ropeModel, customizationFolder, unpack(points))

	local firstPoint, lastPoint = points[1], points[#points]

	data.ZiplineStart = points[1]
	data.Positions = positions
	data.Length = totalLength

	ropeModel.Parent = Util._DebugView.debugObjectsFolder
	return true, data
end

return ZiplineService
