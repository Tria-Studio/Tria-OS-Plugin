-- Copyright (C) 2023 Tria 
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local Bezier = {}

function getBezierPointAtPercent(p: number, ...): Vector3
	local points = { ... }
	while #points > 1 do
		for i = 1, #points - 1 do
			points[i] = points[i]:lerp(points[i + 1], p)
		end
		points[#points] = nil
	end
	return points[1]
end

local function map(
	value: number,
	start: number,
	stop: number,
	newStart: number,
	newEnd: number,
	constrain: boolean
): number
	local alpha = (value - start) / (stop - start)
	local newVal = (1 - alpha) * newStart + alpha * newEnd
	if newStart < newEnd then
		newStart, newEnd = newEnd, newStart
	end
	return if constrain then math.max(math.min(newVal, newStart), newEnd) else newVal
end

function Bezier.createLookup(totalSegments: number, ...): { number }
	local totalDistance = 0
	local sums = {}
	local increment = 1 / totalSegments
	for i = 0, 1, increment do
		local firstPoint = getBezierPointAtPercent(i, ...)
		local secondPoint = getBezierPointAtPercent(i + increment, ...)

		local dist = (secondPoint - firstPoint).Magnitude
		table.insert(sums, totalDistance)
		totalDistance += dist
	end
	return sums
end

function Bezier.calculate(t: number, lookupTable: { number }, points: { Vector3 })
	local arcLength = lookupTable[#lookupTable]
	local targetDist = arcLength * t
	if (t == 0) or (t >= 1) then
		return getBezierPointAtPercent(if t == 0 then 0 else 1, unpack(points))
	end
	for count = 1, #lookupTable - 1 do
		local currentDist = lookupTable[count]
		local nextDist = lookupTable[count + 1]

		if targetDist >= currentDist and targetDist <= nextDist then
			local lerpedT = map(
				targetDist, 
				currentDist, 
				nextDist, 
				count / #lookupTable, 
				(count + 1) / #lookupTable, 
				true
			)
			
			return getBezierPointAtPercent(lerpedT, unpack(points))
		end
	end
end

return Bezier
