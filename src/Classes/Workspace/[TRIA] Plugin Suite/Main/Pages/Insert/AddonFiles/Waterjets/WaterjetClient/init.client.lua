local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
if not RunService:IsRunning() then
	return
end

local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local playerScripts = player:WaitForChild("PlayerScripts")
local SwimmingService = require(playerScripts.client.Services.SwimmingService)

local fans = map.Special.Waterjets
local jetConnection

local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = {map}
rayParams.FilterType = Enum.RaycastFilterType.Whitelist

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
overlapParams.FilterDescendantsInstances = map.Special.Fluid:GetChildren()

local function getNearbyFans(): {Instance}
	local nearby = {}

	for _, fan in ipairs(fans:GetChildren()) do
		local localPos = fan.CFrame:ToObjectSpace(humanoidRootPart.CFrame)

		local isEnabled = fan:GetAttribute("Enabled")
		local distance = fan:GetAttribute("Distance")
		local fanShape = fan:GetAttribute("FanShape")

		if localPos.Z < 0 and localPos.Z > -distance and isEnabled then
			local fanTypes = {}

			function fanTypes.Square()
				local X = localPos.X > -fan.Size.X / 2 and localPos.X < fan.Size.X / 2
				local Y = localPos.Y > -fan.Size.Y / 2 and localPos.Y < fan.Size.Y / 2
				return X and Y
			end

			function fanTypes.Cylinder()
				local pos = localPos * Vector3.new(1, 1, 0)
				return pos.Magnitude < math.min(fan.Size.X / 2, fan.Size.Y / 2)
			end

			if fanTypes[fanShape] ~= nil and fanTypes[fanShape]() then
				table.insert(nearby, fan)
			end
		end
	end

	return nearby
end

SwimmingService.OnSwimmingStateChanged:Connect(function(isSwimming: boolean)    
	if isSwimming then
		jetConnection = RunService.Heartbeat:Connect(function(deltaTime: number)
			for _, fan in ipairs(getNearbyFans()) do
				local speed = fan:GetAttribute("FanSpeed")
				local distance = fan:GetAttribute("Distance")

				local raycastResult = workspace:Raycast(humanoidRootPart.Position, -fan.CFrame.LookVector * distance, rayParams)
				if raycastResult then
					local offset = (raycastResult.Position - humanoidRootPart.Position)
					local resistance = if fan:GetAttribute("LinearMovement") then 1 else math.min(1, 1.25 - (math.abs(offset.X) / distance) ^ 3)
					
					humanoidRootPart.CFrame += raycastResult.Normal * speed * deltaTime * resistance
				end
			end
		end)
	else
		local fan = getNearbyFans()[1]
		if fan then
			local speed = fan:GetAttribute("FanSpeed")
			local distance = fan:GetAttribute("Distance")

			local raycastResult = workspace:Raycast(humanoidRootPart.Position, (fan.Position - humanoidRootPart.Position).Unit * distance, rayParams)
			task.wait()
			if raycastResult then
				humanoidRootPart:ApplyImpulse(raycastResult.Normal * speed * 12)
			end
		end
		if jetConnection then
			jetConnection:Disconnect()
			jetConnection = nil
		end
	end
end)

for _, fan in ipairs(fans:GetChildren()) do
	local speed = fan:GetAttribute("FanSpeed")
	local distance = fan:GetAttribute("Distance")
	local particleId = fan:GetAttribute("BubbleParticle")
	local isEnabled = fan:GetAttribute("Enabled")
	local fanShape = fan:GetAttribute("FanShape")

	local emitter = Instance.new("ParticleEmitter")
	emitter.Size = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.5, 0.15), NumberSequenceKeypoint.new(1, 0.35, 0.15)}
	emitter.Speed = NumberRange.new(speed, speed)
	emitter.Lifetime = NumberRange.new(distance / speed, distance / speed)
	emitter.Rate = fan.Size.X * fan.Size.Y / 144 * 32
	emitter.Enabled = isEnabled
	emitter.Name = "FanParticleEmitter"
	emitter.Texture = "rbxassetid://" .. particleId
	emitter.Shape = Enum.ParticleEmitterShape[fanShape == "Cylinder" and "Disc" or "Box"]
	emitter.EmissionDirection = Enum.NormalId.Front
	emitter.Parent = fan
end

character.Humanoid.Died:Connect(function()
	task.wait(4)
	script:Destroy()
end)

task.wait(map.Settings.Main:GetAttribute("MaxTime"))
script:Destroy()
