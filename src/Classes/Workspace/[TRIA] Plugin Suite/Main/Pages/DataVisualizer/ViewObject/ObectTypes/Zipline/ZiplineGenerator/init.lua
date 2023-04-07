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

	local customizationFolder = rope:FindFirstChild("Customization")
	local data = {
		Rope = ropeModel,
		Length = 0,
	}

	local points = {}
	for _, part in ipairs(rope:GetChildren()) do
		if tonumber(part.Name) then
			table.insert(points, part)
		end
	end
	points = RopeFuncs.sortPointsArray(points)

	if #points < 2 then
		ropeModel:Destroy()
		return false, "Not enough points!"
	end
	if points[1]:GetAttribute("_action") ~= "Zipline" then
		ropeModel:Destroy()
		return false, "No _action attribute!"
	end

	ropeModel.WorldPivot = rope.WorldPivot
	RopeFuncs.generateRope(ropeModel, customizationFolder, unpack(points))
	ropeModel.Parent = Util._DebugView.debugObjectsFolder
	return true, data
end

return ZiplineService
