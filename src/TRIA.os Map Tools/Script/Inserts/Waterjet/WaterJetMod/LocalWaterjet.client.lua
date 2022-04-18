local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Lib = script.Map.Value

local RayParams = RaycastParams.new()
local Player = Players.localPlayer
local Character = Player.Character
local HumanoidRootPart: Part = Character.HumanoidRootPart

local lastWater
local lastSwimming
local timeIn = 0

local Fans = {}
local Collisions = {}


script.Parent = Player.PlayerScripts
RayParams.FilterDescendantsInstances = {script.Map.Value}
RayParams.FilterType = Enum.RaycastFilterType.Whitelist


function Collisions.Wedge(Part1, Part2)
	local Point = Part2.CFrame:Inverse() * Part1
	local Size = Part2.Size

	local X = Point.X > -Size.X / 2 and Point.X < Size.X / 2
	local Y = Point.Y < (Size.Y / Size.Z) * Point.Z and Point.Y > -Size.Y / 2
	local Z = Point.Z > (Size.Y / Size.Z) * Point.Y and Point.Z < Size.Z / 2

	return X and Y and Z
end

function Collisions.Block(Part1, Part2, IgnoreY)
	local Point = Part2.CFrame:Inverse() * Part1
	local Size = Part2.Size

	local X = Point.X > -Size.X / 2 and Point.X < Size.X / 2
	local Y = Point.Y > -Size.Y / 2 and Point.Y < Size.Y / 2
	local Z = Point.Z > -Size.Z / 2 and Point.Z < Size.Z / 2

	return X and (IgnoreY or Y) and Z
end

function Collisions.Cylinder(Part1, Part2)
	local Point = Part2.CFrame:Inverse() * Part1
	local CPos = (Point * Vector3.new(0, 1, 1))
	local Size = Part2.Size

	local X = Point.X > -Size.X / 2 and Point.X < Size.X / 2
	local mag = CPos.Magnitude < math.min(Size.Y, Size.Z) / 2

	return X and mag
end

function Collisions.Ball(Part1, Part2)
	local Point = Part2.CFrame:Inverse() * Part1
	local Size = Part2.Size

	local mag = Point.Magnitude < Size.X / 2

	return mag
end

function Collisions.CornerWedge(Part1, Part2)
	local Size = Part2.Size

	local Point1 = (Part2.CFrame * CFrame.Angles(0, math.pi/2, 0)):Inverse() * Part1
	local X1 = Point1.X > -Size.X / 2 and Point1.X < Size.X / 2
	local Y1 = Point1.Y < (Size.Y / Size.Z) * Point1.Z and Point1.Y > -Size.Y / 2
	local Z1 = Point1.Z > (Size.Y / Size.Z) * Point1.Y and Point1.Z < Size.Z / 2

	local Point2 = (Part2.CFrame * CFrame.Angles(0, math.pi, 0)):Inverse() * Part1
	local X2 = Point2.X > -Size.X / 2 and Point2.X < Size.X / 2
	local Y2 = Point2.Y < (Size.Y / Size.Z) * Point2.Z and Point2.Y > -Size.Y / 2
	local Z2 = Point2.Z > (Size.Y / Size.Z) * Point2.Y and Point2.Z < Size.Z / 2

	return X1 and Y1 and Z1 and X2 and Y2 and Z2
end


local function CheckCollision(PosToCheck, Part: BasePart, IgnoreY)

	if Part:IsA("UnionOperation") or Part:IsA("MeshPart") then
		return
	end

	local Position = if typeof(PosToCheck) == "CFrame" then PosToCheck.Position elseif typeof(PosToCheck) == "Vector3" then PosToCheck elseif PosToCheck:IsA("BasePart") then PosToCheck.Position elseif PosToCheck:IsA("Attachment") then PosToCheck.WorldPosition else Vector3.new()
	if Part:IsA("WedgePart") then
		return Collisions.Wedge(Position, Part)
	elseif Part:IsA("CornerWedgePart") then
		return Collisions.CornerWedge(Position, Part)
	elseif Part:IsA("Part") then
		if Part.Shape == Enum.PartType.Block then
			return Collisions.Block(Position, Part, IgnoreY)
		elseif Part.Shape == Enum.PartType.Cylinder then
			return Collisions.Cylinder(Position, Part)
		elseif Part.Shape == Enum.PartType.Ball then
			return Collisions.Ball(Position, Part)
		end
	end

	return
end



local function GetNearbyFans()
	local NearbyFans = {}
	local Position = HumanoidRootPart.Position

	for _, Fan in pairs(Fans) do
		local localPos = Fan.CFrame:Inverse() * Position

		if localPos.Z < 0 and localPos.Z > -Fan:GetAttribute("Distance") and Fan.Enabled.Value then
			local Types = {}

			function Types.Square()
				local X = localPos.X > -Fan.Size.X / 2 and localPos.X < Fan.Size.X / 2
				local Y = localPos.Y > -Fan.Size.Y / 2 and localPos.Y < Fan.Size.Y / 2
				return X and Y
			end

			function Types.Cylinder()
				local Pos = localPos * Vector3.new(1, 1, 0)
				return Pos.Magnitude < math.min(Fan.Size.X / 2, Fan.Size.Y / 2)
			end

			if Types[Fan:GetAttribute("Shape")]() then
				table.insert(NearbyFans, Fan)
			end
		end
	end

	return NearbyFans
end

local function GetWater()
	for _, Part: BasePart in pairs(workspace:GetPartsInPart(HumanoidRootPart)) do
		if Part.Name:sub(1, 7) == "_Liquid" then
			return Part
		end
	end
end

RunService.Heartbeat:Connect(function(deltaTime: number)
	local Water = lastWater or GetWater()

	if Water and CheckCollision(HumanoidRootPart, Water) then
		lastWater = Water
		lastSwimming = true
		timeIn = math.min(timeIn + deltaTime * 2, 1)

		for _, Fan: BasePart in pairs(GetNearbyFans()) do
			local localPos = Fan.CFrame:Inverse() * HumanoidRootPart.Position

			local Raycast = workspace:Raycast(HumanoidRootPart.Position, -Fan.CFrame.LookVector * Fan:GetAttribute("Distance"), RayParams)

			if Raycast then
				local Normal = Raycast.Normal

				HumanoidRootPart.CFrame += Normal * Fan:GetAttribute("Speed") * deltaTime * timeIn
			end
		end
	else
		if lastSwimming then
			local Fans = GetNearbyFans()
			local Fan = Fans and Fans[1]

			if Fan then
				local Raycast = workspace:Raycast(HumanoidRootPart.Position, (Fan.Position - HumanoidRootPart.Position).Unit * Fan:GetAttribute("Distance"), RayParams)

				HumanoidRootPart:ApplyImpulse(Raycast.Normal * Fan:GetAttribute("Speed") * 12)
			end

			lastSwimming = false
		end

		timeIn = 0
		lastWater = nil
	end
end)


-- initiate


for _, part: Instance in pairs(script.Map.Value:GetDescendants()) do
	if part:IsA("BasePart") and not (part:IsA("UnionOperation") or part:IsA("MeshPart")) then
		if part.Name:sub(1, 9) == "_WaterJet" then
			if part:GetAttribute("Shape") ~= "Square" and part:GetAttribute("Shape") ~= "Cylinder" then
				warn(string.format("%s is not a valid waterjet shape for fan %s.", part:GetAttribute("Shape") or "No shape defined", part:GetFullName()))
				continue
			end

			table.insert(Fans, part)

			part.Enabled.Changed:Connect(function()
				if part:FindFirstChild("FanParticleEmitter") then
					part.FanParticleEmitter.Enabled = part.Enabled.Value
				end
			end)

			if part:GetAttribute("ParticleId") ~= 0 then
				local ParticleEmitter = script.ParticleEmitter:Clone()
				ParticleEmitter.Speed = NumberRange.new(part:GetAttribute("Speed"), part:GetAttribute("Speed"))
				ParticleEmitter.Lifetime = NumberRange.new(part:GetAttribute("Distance") / part:GetAttribute("Speed"), part:GetAttribute("Distance") / part:GetAttribute("Speed"))
				ParticleEmitter.Rate = part.Size.X * part.Size.Y / 144 * 32
				ParticleEmitter.Enabled = part.Enabled.Value
				ParticleEmitter.Parent = part
				ParticleEmitter.Name = "FanParticleEmitter"
				ParticleEmitter.Texture = "rbxassetid://" .. part:GetAttribute("ParticleId")
				ParticleEmitter.Shape = Enum.ParticleEmitterShape[part:GetAttribute("Shape") == "Cylinder" and "Disc" or "Box"]
			end
		end
	end
end

Player.Character.Humanoid.Died:Connect(function()
	task.wait(4)
	script:Destroy()
end)

task.wait(script.Map.Value.Settings.Main:GetAttribute("MaxTime"))
script:Destroy()