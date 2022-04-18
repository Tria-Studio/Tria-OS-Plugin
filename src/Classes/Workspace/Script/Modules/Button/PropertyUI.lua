--[[
	Handles all tag-specific data, and altering of that data. Works in parody with the Button class.
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local UtilFuncs = require(script.Parent.Parent.UtilFuncs)
local Maid = require(script.Parent.Parent.Other.Maid)
local Signal = require(script.Parent.Parent.Other.Signal)

propertyUI = {}
propertyUI.__index = propertyUI



function propertyUI.new(Main)
	local self = {
		BtnHandler = Main,
		Maid = Maid.new()
	}

	self.BtnHandler.Updated:Connect(function(AllActivated, Selected)
		self.Maid:DoCleaning()

		if typeof(Selected) == "Instance" then
			Selected = {Selected}
		end

		local UI = self.BtnHandler.UIProperties
		local Types = {}

		function Types.Button()
			if self.BtnHandler.Name == "_Sound" then
				UI.Main.SoundId.SoundNum.Text = ""

				local SoundMaid = Maid.new()

				local function ObjectChanged()
					local Val = ""

					for _, Sound in pairs(Selected) do
						if not Sound:IsDescendantOf(UtilFuncs.Map) then
							continue
						end

						local Tag = UtilFuncs.GetTag(Sound, self.BtnHandler.Name)
						if not Tag then
							return
						end

						if Val == "" then 
							Val = Tag.SoundId
						end

						if Val ~= Tag.SoundId then
							UI.Main.SoundId.SoundNum.Text = ""
							return
						end
					end

					UI.Main.SoundId.SoundNum.Text = string.gsub(Val, "[^%d]+", "")
				end

				if AllActivated then
					for _, Part in pairs(Selected) do
						local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)

						SoundMaid:GiveTask(Tag:GetPropertyChangedSignal("SoundId"):Connect(ObjectChanged))

						local function AncestorChanged()
							if not Tag or not Tag.Parent then
								ObjectChanged()
								UI.Visible = false
								SoundMaid:DoCleaning()
							end
						end

						SoundMaid:GiveTask(Tag.AncestryChanged:Connect(AncestorChanged))
					end
				end
				ObjectChanged()

				local function UpdateSound()
					local Number = string.gsub(UI.Main.SoundId.SoundNum.Text, "[^%d]+", "")
					local SoundId = "rbxassetid://" .. Number

					if not Number or Number == "" then 
						UI.Main.SoundId.SoundNum.Text = ""
						return 
					end

					ChangeHistoryService:SetWaypoint("Changing Tag '_Sound' SoundId to " .. Number)

					for _, Part in pairs(Selected) do
						local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
						Tag.SoundId = SoundId
					end

					UI.Main.SoundId.SoundNum.Text = Number

					ChangeHistoryService:SetWaypoint("Changed Tag '_Sound' SoundId to " .. Number)
				end

				SoundMaid:GiveTask(UI.Main.SoundId.SoundNum.FocusLost:Connect(UpdateSound))
				self.Maid:GiveTask(SoundMaid)
			end

			UI.Main.Button.ButtonNum.Text = ""
			UI.Main.Delay.DelayNum.Text = ""


			-- ==== BUTTON NUM ==== --

			local ButtonMaid = Maid.new()

			local function ButtonNumChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
					if not Tag then
						return
					end

					if Val == "" then 
						Val = Tag.Name
					end

					if Val ~= Tag.Name then
						UI.Main.Button.ButtonNum.Text = ""
						return
					end
				end

				local Text = string.gsub(Val, "[^%d]+", "")
				UI.Main.Button.ButtonNum.Text = Text
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)

					ButtonMaid:GiveTask(Tag:GetPropertyChangedSignal("Name"):Connect(ButtonNumChanged))
				end
			end
			ButtonNumChanged()

			local function UpdateButtonNum()
				local Text = string.gsub(UI.Main.Button.ButtonNum.Text, "[^%d]+", "")
				if not Text or Text == "" then return end

				local Number = math.max(tonumber(Text), 1)

				if not Number or Number == "" then 
					UI.Main.Button.ButtonNum.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Button to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
					Tag.Name = self.BtnHandler.Name .. Number
				end

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Button to %s", self.BtnHandler.Name, Number))
			end 

			ButtonMaid:GiveTask(UI.Main.Button.ButtonNum.FocusLost:Connect(UpdateButtonNum))
			self.Maid:GiveTask(ButtonMaid)

			-- ==== DELAY NUM ==== --

			--[[
				- If theres a _Delay object, then update
				- Listen for an ObjectValue created, and if its name is _Delay
				- listen for the object being deleted and update 
				
			]]

			local DelayMaid = Maid.new()

			local function DelayNumChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
					if not Tag then return end

					local DelayTag = Tag:FindFirstChild("_Delay")
					if not DelayTag then
						UI.Main.Delay.DelayNum.Text = ""
						return 
					end

					if Val == "" then 
						Val = DelayTag.Value
					end

					if Val ~= DelayTag.Value then
						UI.Main.Delay.DelayNum.Text = ""
						return
					end
				end

				UI.Main.Delay.DelayNum.Text = Val
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
					local DelayTag = Tag:FindFirstChild("_Delay")

					if DelayTag then
						DelayMaid:GiveTask(DelayTag:GetPropertyChangedSignal("Value"):Connect(DelayNumChanged))
						DelayNumChanged()

						local function AncestorChanged()
							if not Tag:FindFirstChild("_Delay") then
								DelayNumChanged()
							end
						end
						DelayMaid:GiveTask(Tag:FindFirstChild("_Delay").AncestryChanged:Connect(AncestorChanged))
					end
				end
			end

			local function UpdateDelay()
				local Number = string.gsub(UI.Main.Delay.DelayNum.Text, "[^%d%p]+", "")

				if not tonumber(Number) or Number == "" then 
					UI.Main.Delay.DelayNum.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Delay to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
					local DelayTag = Tag:FindFirstChild("_Delay")

					if not DelayTag then
						DelayTag = Instance.new("NumberValue")
						DelayTag.Name = "_Delay"
						DelayTag.Parent = Tag

						DelayMaid:GiveTask(DelayTag:GetPropertyChangedSignal("Value"):Connect(DelayNumChanged))

						local function AncestorChanged()
							if not Tag:FindFirstChild("_Delay") then
								DelayNumChanged()
							end
						end
						DelayMaid:GiveTask(Tag:FindFirstChild("_Delay").AncestryChanged:Connect(AncestorChanged))
					end

					ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Delay to %s", self.BtnHandler.Name, Number))

					DelayTag.Value = Number
				end

				UI.Main.Delay.DelayNum.Text = Number
			end 

			self.Maid:GiveTask(UI.Main.Delay.DelayNum.FocusLost:Connect(UpdateDelay))
			self.Maid:GiveTask(DelayMaid)
		end
		function Types.ButtonObj()
			UI.Main.Button.ButtonNum.Text = ""
			UI.Main.Group.ImageButton.Image = "rbxassetid://6031068420"

			-- ==== BUTTON NUM/PATH ==== --

			local ButtonMaid = Maid.new()

			local function ButtonNumChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					local function FindParts(part: Instance): boolean
						return if part:FindFirstChild("Light") and part:FindFirstChild("Hitbox") then true else false
					end

					local Button = string.sub(Part.Name, 1, 7) == "_Button" and Part:IsA("Model") and FindParts(Part) and Part or string.sub(Part.Parent.Name, 1, 7) == "_Button" and Part.Parent:IsA("Model") and FindParts(Part.Parent) and Part.Parent
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					if not Button then
						return
					end

					if Val == "" then 
						Val = Button.Name
					end

					if Val ~= Button.Name then
						UI.Main.Button.ButtonNum.Text = ""
						return
					end
				end

				local Text = string.gsub(Val, "_Button", "")
				local Path = string.gsub(Text, "%d", "")
				Text = string.gsub(Text, "%a", "")

				UI.Main.Button.ButtonNum.Text = Text
				UI.Main.Path.PathNum.Text = Path
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					ButtonMaid:GiveTask(Part:GetPropertyChangedSignal("Name"):Connect(ButtonNumChanged))
				end
			end
			ButtonNumChanged()

			local function UpdateButtonNum()
				local Text = string.gsub(UI.Main.Button.ButtonNum.Text, "[^%d]+", "")
				if not Text or Text == "" then
					UI.Main.Button.ButtonNum.Text = ""
					return 
				end
				local Number = math.max(tonumber(Text), 0)
				local Path = UI.Main.Path.PathNum.Text

				if not Number or Number == "" then 
					UI.Main.Button.ButtonNum.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Number to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					local function FindParts(part: Instance): boolean
						return if part:FindFirstChild("Light") and part:FindFirstChild("Hitbox") then true else false
					end

					local Button = string.sub(Part.Name, 1, 7) == "_Button" and Part:IsA("Model") and FindParts(Part) and Part or string.sub(Part.Parent.Name, 1, 7) == "_Button" and Part.Parent:IsA("Model") and FindParts(Part.Parent) and Part.Parent

					if Button then
						Button.Name = "_Button" .. Number .. Path
					end
				end

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Number to %s", self.BtnHandler.Name, Number))
			end 
			ButtonMaid:GiveTask(UI.Main.Button.ButtonNum.FocusLost:Connect(UpdateButtonNum))
			ButtonMaid:GiveTask(UI.Main.Path.PathNum.FocusLost:Connect(UpdateButtonNum))


			-- ==== GROUP BUTTON ==== --


			local function GroupChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					local function FindParts(part: Instance): boolean
						return if part:FindFirstChild("Light") and part:FindFirstChild("Hitbox") then true else false
					end

					local Button = string.sub(Part.Name, 1, 7) == "_Button" and Part:IsA("Model") and FindParts(Part) and Part or string.sub(Part.Parent.Name, 1, 7) == "_Button" and Part.Parent:IsA("Model") and FindParts(Part.Parent) and Part.Parent

					if not Button or not Button:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					if Val == "" then 
						Val = Button:GetAttribute("Group")
					end

					if Val ~= Button:GetAttribute("Group") then
						UI.Main.Group.ImageButton.Image = "rbxassetid://6031068420"
						return
					end
				end

				UI.Main.Group.ImageButton.Image = Val and "rbxassetid://6031068421" or "rbxassetid://6031068420"
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					ButtonMaid:GiveTask(Part:GetAttributeChangedSignal("Group"):Connect(GroupChanged))
				end
			end
			GroupChanged()

			local function UpdateGroup()
				local State = UI.Main.Group.ImageButton.Image == "rbxassetid://6031068421"
				State = not State

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Group to %s", self.BtnHandler.Name, tostring(State)))

				for _, Part in pairs(Selected) do
					Part:SetAttribute("Group", State)
				end

				UI.Main.Group.ImageButton.Image = State and "rbxassetid://6031068421" or "rbxassetid://6031068420"

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Group to %s", self.BtnHandler.Name, tostring(State)))
			end 
			ButtonMaid:GiveTask(UI.Main.Group.ImageButton.MouseButton1Click:Connect(UpdateGroup))

			self.Maid:GiveTask(ButtonMaid)
		end

		function Types.Object()
			local Types = {}

			function Types._WallRun()
				UI.Main.Speed.SpeedNum.Text = ""

				-- ==== WALLRU NSPEED ==== --

				local SpeedMaid = Maid.new()

				local function SpeedChanged()
					local Val = ""

					for _, Part in pairs(Selected) do
						if not Part:IsDescendantOf(UtilFuncs.Map) then
							continue
						end

						local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
						if not Tag then
							return
						end

						if Val == "" then 
							Val = Tag.Value
						end

						if Val ~= Tag.Value then
							UI.Main.Speed.SpeedNum.Text = ""
							return
						end
					end

					if Val == "" or not Val then
						UI.Main.Speed.SpeedNum.Text = ""
						return
					end

					local Text = string.gsub(Val, "[^%d]+", "")
					UI.Main.Speed.SpeedNum.Text = Text
				end

				if AllActivated then
					for _, Part in pairs(Selected) do
						local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)

						SpeedMaid:GiveTask(Tag:GetPropertyChangedSignal("Value"):Connect(SpeedChanged))
					end
				end
				SpeedChanged()

				local function UpdateSpeed()
					local Text = string.gsub(UI.Main.Speed.SpeedNum.Text, "[^%d]+", "")
					local Number = math.max(tonumber(Text), 1)

					if not Number or Number == "" then 
						UI.Main.Speed.SpeedNum.Text = ""
						return 
					end

					ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Speed to %s", self.BtnHandler.Name, Number))

					for _, Part in pairs(Selected) do
						local Tag = UtilFuncs.GetTag(Part, self.BtnHandler.Name)
						Tag.Value = Number
					end

					ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Speed to %s", self.BtnHandler.Name, Number))
				end 

				SpeedMaid:GiveTask(UI.Main.Speed.SpeedNum.FocusLost:Connect(UpdateSpeed))
				self.Maid:GiveTask(SpeedMaid)

			end
			if Types[self.BtnHandler.Name] then
				Types[self.BtnHandler.Name]()
			else
				warn(self.BtnHandler.Name)
			end

		end
		function Types.Boost()
			UI.Main.Speed.SpeedNum.Text = ""

			-- ==== BOOST SPEED ==== --

			local SpeedMaid = Maid.new()

			local function SpeedChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					UI.Main.Speed.SpeedNum.Text = Part:GetAttribute("Speed") or ""
				end

				

				
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					SpeedMaid:GiveTask(Part:GetAttributeChangedSignal("Speed"):Connect(SpeedChanged))
				end
			end
			SpeedChanged()

			local function UpdateSpeed()
				local Text = string.gsub(UI.Main.Speed.SpeedNum.Text, "[^%d]+", "")
				local Number = math.max(tonumber(Text), 1)

				if not Number or Number == "" then 
					UI.Main.Speed.SpeedNum.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Speed to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					Part:SetAttribute("Speed", Number)
				end

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Speed to %s", self.BtnHandler.Name, Number))
			end 

			SpeedMaid:GiveTask(UI.Main.Speed.SpeedNum.FocusLost:Connect(UpdateSpeed))
			self.Maid:GiveTask(SpeedMaid)
		end

		function Types.Water()
			local function ResetColors()
				UI.Main.LiquidType.Types.acid.TextColor3 = Color3.fromRGB(0, 214, 14)
				UI.Main.LiquidType.Types.acid.TextStrokeTransparency = 1
				UI.Main.LiquidType.Types.acid.TextSize = 14
				UI.Main.LiquidType.Types.custom.TextColor3 = Color3.fromRGB(132, 7, 209)
				UI.Main.LiquidType.Types.custom.TextStrokeTransparency = 1
				UI.Main.LiquidType.Types.custom.TextSize = 14
				UI.Main.LiquidType.Types.lava.TextColor3 = Color3.fromRGB(176, 44, 0)
				UI.Main.LiquidType.Types.lava.TextStrokeTransparency = 1
				UI.Main.LiquidType.Types.lava.TextSize = 14
				UI.Main.LiquidType.Types.water.TextColor3 = Color3.fromRGB(2, 112, 181)
				UI.Main.LiquidType.Types.water.TextStrokeTransparency = 1
				UI.Main.LiquidType.Types.water.TextSize = 14
			end
			ResetColors()

			-- ==== WATER NUM ==== --

			local WaterMaid = Maid.new()

			local function WaterNumChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					if not string.find(Part.Name, "_Liquid", 1, true) then
						return
					end

					if Val == "" then 
						Val = Part.Name
					end

					if Val ~= Part.Name then
						UI.Main.LiquidNum.LiquidNum.Text = ""
						return
					end
				end

				local Text = string.gsub(Val, "_Liquid", "")
				UI.Main.LiquidNum.LiquidNum.Text = Text
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					WaterMaid:GiveTask(Part:GetPropertyChangedSignal("Name"):Connect(WaterNumChanged))
				end
			end
			WaterNumChanged()

			local function UpdateWaterNum()
				local Text = string.gsub(UI.Main.LiquidNum.LiquidNum.Text, "[^%d]+", "")
				if not Text then
					UI.Main.LiquidNum.LiquidNum.Text = ""
					return 
				end
				local Number = math.max(tonumber(Text), 0)

				if not Number or Number == "" then 
					UI.Main.LiquidNum.LiquidNum.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Number to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					Part.Name = "_Liquid" .. Number
				end

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Number to %s", self.BtnHandler.Name, Number))
			end 
			WaterMaid:GiveTask(UI.Main.LiquidNum.LiquidNum.FocusLost:Connect(UpdateWaterNum))

			-- ==== WATER STATE ==== --

			local States = {
				"water",
				"acid",
				"lava",
				"custom"
			}

			local function WaterStateChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					if not Part or not Part:GetAttribute("Type") or not string.find(Part.Name, "_Liquid", 1, true) and not table.find(States, Part:GetAttribute("Type")) then
						ResetColors()
						return
					end

					if Val == "" then 
						Val = Part:GetAttribute("Type")
					end

					if Val ~= Part:GetAttribute("Type") or not table.find(States, Part:GetAttribute("Type")) then
						ResetColors()
						return
					end
				end

				if Val == "" then
					ResetColors()
					return
				end

				UI.Main.LiquidType.Types[Val].TextStrokeTransparency = 0
				UI.Main.LiquidType.Types[Val].TextSize = 16
			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					WaterMaid:GiveTask(Part:GetAttributeChangedSignal("Type"):Connect(WaterStateChanged))
				end
			end
			WaterStateChanged()

			local function UpdateWaterState(state)
				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' State to %s", self.BtnHandler.Name, state))

				for _, Part in pairs(Selected) do
					Part:SetAttribute("Type", state)
				end

				ResetColors()
				UI.Main.LiquidType.Types[state].TextStrokeTransparency = 0
				UI.Main.LiquidType.Types[state].TextSize = 16

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' State to %s", self.BtnHandler.Name, state))
			end 

			for _, Button in pairs(UI.Main.LiquidType.Types:GetChildren()) do
				if Button:IsA("GuiButton") then
					WaterMaid:GiveTask(Button.MouseButton1Click:Connect(function()
						UpdateWaterState(Button.Name)
					end))
				end
			end

			self.Maid:GiveTask(WaterMaid)
		end


		function Types.AirTank()
			UI.Main.Oxygen.OxygenText.Text = ""

			-- ==== BOOST SPEED ==== --

			local SpeedMaid = Maid.new()

			local function OxygenChanged()
				local Val = ""

				for _, Part in pairs(Selected) do
					if not Part:IsDescendantOf(UtilFuncs.Map) then
						continue
					end

					local Tank = Part.Name == "AirTank" and Part:IsA("Model") and Part or Part.Name == "Hitbox" and Part.Parent.Name == "AirTank" and Part.Parent:IsA("Model") and Part.Parent

					if Tank then

						UI.Main.Oxygen.OxygenText.Text = Tank:GetAttribute("Oxygen") or ""
					end
				end


			end

			if AllActivated then
				for _, Part in pairs(Selected) do
					SpeedMaid:GiveTask(Part:GetAttributeChangedSignal("Value"):Connect(OxygenChanged))
				end
			end
			OxygenChanged()

			local function UpdateOxygen()
				local Text = string.gsub(UI.Main.Oxygen.OxygenText.Text, "[^%d]+", "")
				local Number = math.max(tonumber(Text), 1)

				if not Number or Number == "" then 
					UI.Main.Oxygen.OxygenText.Text = ""
					return 
				end

				ChangeHistoryService:SetWaypoint(string.format("Changing Tag '%s' Speed to %s", self.BtnHandler.Name, Number))

				for _, Part in pairs(Selected) do
					local Tank = Part.Name == "AirTank" and Part:IsA("Model") and Part or Part.Name == "Hitbox" and Part.Parent.Name == "AirTank" and Part.Parent:IsA("Model") and Part.Parent

					if Tank then
						Tank:SetAttribute("Oxygen", Number)
					end
				end

				ChangeHistoryService:SetWaypoint(string.format("Changed Tag '%s' Speed to %s", self.BtnHandler.Name, Number))
			end 

			SpeedMaid:GiveTask(UI.Main.Oxygen.OxygenText.FocusLost:Connect(UpdateOxygen))
			self.Maid:GiveTask(SpeedMaid)
		end


		Types[self.BtnHandler.Type]()

		if not AllActivated then return end
	end)

	return setmetatable(self, propertyUI)
end

function propertyUI:Destroy()
	self.Maid:DoCleaning()
end


return propertyUI