-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local RopeFuncs = {}
local Bezier = require(script.Parent:WaitForChild("Bezier"))
local PartCache = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Util.PartCache)

local customizationDefault = {
	Material = "Neon",
	Color = Color3.new(1, 1, 1),
	Width = 0.25,
}

function RopeFuncs.sortPointsArray(points)
	table.sort(points, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	return points
end

function RopeFuncs.createPoint(point: Vector3, nextPoint: Vector3, parent: Instance, custom: {})
	local distance = (nextPoint - point).Magnitude
	local width = custom.Width or customizationDefault.Width

	local part = PartCache:GetObject("ZiplineCache")

	local success = pcall(function()
		part.Material = custom.Material or customizationDefault.Material
	end)
	if not success then
		part.Material = customizationDefault.Material
	end
	part.Color = custom.Color or customizationDefault.Color
	part.Size = Vector3.new(width, width, distance)

	part.CFrame = CFrame.lookAt(point, nextPoint, Vector3.new(0, 1, 0)) * CFrame.new(0, 0, -distance / 2)
	part.Parent = parent

	if point == nextPoint then
		part:Destroy()
	end
	return part
end

function RopeFuncs.generateRope(rope: Model, customization: Configuration?, ...)
	local points = { ... }
	local pointPositions = {}

	local totalDistance = 0
	for i = 1, #points - 1 do
		totalDistance += (points[i + 1].Position - points[i].Position).Magnitude
	end

	totalDistance = math.floor(totalDistance)
	local dist = math.floor(totalDistance / 2)
	dist = dist < 40 and 40 or dist

	local segments = math.ceil(totalDistance / 3)
	local increment = (1 / segments)
	local finalPositionTable = table.create(segments)

	for i = 1, #points do
		table.insert(pointPositions, points[i].Position)
	end

	if #points == 2 then
		local lookCF = CFrame.new(points[1].Position, points[2].Position)
		local distance = (points[1].Position - points[2].Position).Magnitude
		table.insert(
			pointPositions,
			2,
			((lookCF + lookCF.LookVector * (distance / 2)) * CFrame.new(0, distance / -8, 0)).Position
		)
	end

	local lookup = Bezier.createLookup(segments, unpack(pointPositions))
	table.insert(finalPositionTable, points[1].Position)
	for t = 0, 0.999, increment do
		table.insert(finalPositionTable, Bezier.calculate(math.clamp(t + increment, 0, 1), lookup, pointPositions))
	end
	if finalPositionTable[#finalPositionTable] ~= points[#points] then
		table.insert(finalPositionTable, points[#points].Position)
	end

	local custom = { Material = customizationDefault.Material }
	if customization then
		custom = customization:GetAttributes()
		for _, v in pairs(Enum.Material:GetEnumItems()) do
			if string.lower(v.Name) == string.lower(custom.Material) then
				custom.Material = v.Name
				break
			end
		end
	else
		custom = {}
	end

	local totalLength = 1

	for i = 1, #finalPositionTable - 1 do
		local point, nextPoint = finalPositionTable[i], finalPositionTable[i + 1]
		RopeFuncs.createPoint(point, nextPoint, rope, custom)

		totalLength += (nextPoint - point).Magnitude
	end
	return finalPositionTable, totalLength
end

return RopeFuncs
