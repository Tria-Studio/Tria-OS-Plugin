--[[
	Button handler. Handles the selection of objects, and changes the object accordingly to user input.
	
	Adds or removes the tags / object to the selected parts. Does not handle with the tag-specific data.
]]
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Maid = require(script.Parent.Other.Maid)
local Signal = require(script.Parent.Other.Signal)
local SelectMap = require(script.Parent.SelectMap)
local UtilModule = require(script.Parent.UtilFuncs)
local ButtonPropHandler = require(script.PropertyUI)

local UI = UtilModule.UI

button = {}
button.__index = button



function button.new(Name, Type)
	local self = {
		Activated = false,
		Maid = Maid.new(),
		Name = Name,
		Type = Type,
		UI = UI.Frames:FindFirstChild(Name, true),
		UIProperties = UI.Frames:FindFirstChild(Name .. "Frame", true),
		Updated = Signal.new()
	}

	if self.UIProperties then
		self.PropHandler = ButtonPropHandler.new(self)
	end

	local function ThemeChanged()
		local Color = self.Activated and settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected) or settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Mid)
		self.UI.BackgroundColor3 = Color
	end
	settings().Studio.ThemeChanged:Connect(ThemeChanged)
	ThemeChanged()

	local function UpdateProperties()
		local Types = {}

		function Types.Button()
			if self.Name == "_Sound" then

			else

			end
		end
		function Types.Object()
			local Types = {}

			function Types.WallRun()

			end
			function Types.WallJump()

			end
			function Types._SpeedBooster()

			end
			function Types._JumpBooster()

			end

			Types[self.Name]()
		end
		function Types.ButtonObj()

		end
		function Types.Water()

		end
		Types[self.Type]()
	end

	local function SelectionChanged()
		if not UtilModule.Map then return end

		local Selected = Selection:Get()

		if #Selected == 0 then
			self.Activated = false
		else
			self.Activated = UtilModule.ArePartsTagged(Selected, self.Name)
		end

		local Color = self.Activated and settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected) or settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Mid)
		self.UI.BackgroundColor3 = Color

		if self.UIProperties then
			self.UIProperties.Visible = self.Activated
		end

		self.Updated:Fire(UtilModule.ArePartsTagged(Selected, self.Name), Selected)
	end
	if self.Type then
		Selection.SelectionChanged:Connect(SelectionChanged)

		SelectMap.MapChanged:Connect(function(Map)
			if Map then
				SelectionChanged()
			else
				self.Activated = false
				local Color = self.Activated and settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected) or settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Mid)
				self.UI.BackgroundColor3 = Color

				if self.UIProperties then
					self.UIProperties.Visible = false
				end
			end
		end)
	end

	local function ButtonClicked()
		if not UtilModule.Map then return end

		if #Selection:Get() == 0 then return end

		ChangeHistoryService:SetWaypoint(string.format("Updating %s part(s) with %s tag.", tostring(#Selection:Get()), self.Name))

		self.Activated = not self.Activated

		if self.Activated then
			local Types = {}

			function Types.Button()
				for _, Part in pairs(Selection:Get()) do
					local CurrentTag = UtilModule.GetTag(Part, self.Name)

					if not CurrentTag then
						local Tag = self.Name == "_Sound" and Instance.new("Sound") or Instance.new("ObjectValue")
						Tag.Name = self.Name .. 1
						Tag.Parent = Part
					end
				end
			end
			function Types.Object()
				for _, Part in pairs(Selection:Get()) do
					local CurrentTag = UtilModule.GetTag(Part, self.Name)

					if not CurrentTag then
						local Tag = self.Name == "_WallRun" and Instance.new("NumberValue") or Instance.new("ObjectValue")
						Tag.Name = self.Name
						Tag.Parent = Part
					end
				end
			end
			function Types.Kill()
				Types.Object()
			end
			function Types.ButtonObj()
				self.Activated = not self.Activated
			end
			function Types.Water()
				for _, Part in pairs(Selection:Get()) do
					if Part:IsA("BasePart") then
						Part.Name = "_Liquid0"
						Part:SetAttribute("Type", "water")
					end
				end
			end
			function Types.AirTank()
				self.Activated = not self.Activated
			end
			function Types.Detail()
				if not UtilModule.Map:FindFirstChild("Detail") then
					local Folder = Instance.new("Folder")
					Folder.Parent = UtilModule.Map
					Folder.Name = "Detail"
				end
				
				for _, Part in pairs(Selection:Get()) do
					Part.Parent = UtilModule.Map.Detail
				end
			end
			function Types.Boost()
				for _, Part in pairs(Selection:Get()) do
					Part.Name = self.Name
					Part:SetAttribute("Speed", 0)
				end
			end

			Types[self.Type]()
		else
			local Types = {}

			function Types.Button()
				for _, Part in pairs(Selection:Get()) do
					local Tag = UtilModule.GetTag(Part, self.Name)
					if Tag then
						Tag.Parent = nil
					end
				end
			end
			function Types.Object()
				for _, Part in pairs(Selection:Get()) do
					local Tag = UtilModule.GetTag(Part, self.Name)
					if Tag then
						Tag.Parent = nil
					end
				end
			end
			function Types.Kill()
				Types.Object()
			end
			function Types.ButtonObj()
				self.Activated = not self.Activated
			end
			function Types.Water()
				for _, Part in pairs(Selection:Get()) do
					if Part:IsA("BasePart") then
						Part.Name = Part.ClassName
						Part:SetAttribute("Type", nil)
					end
				end
			end
			function Types.AirTank()

			end
			function Types.Detail()
				local Folder = UtilModule.Map:FindFirstChild("Geometry")
				
				if not Folder then
					Folder = Instance.new("Folder")
					Folder.Parent = UtilModule.Map
					Folder.Name = "Geometry"
				end
				
				for _, Part in pairs(Selection:Get()) do
					Part.Parent = Folder
					Part:SetAttribute("_Detail", false)
				end
			end
			function Types.Boost()
				for _, Part in pairs(Selection:Get()) do
					Part.Name = Part.ClassName
					Part:SetAttribute("Speed", nil)
				end
			end

			Types[self.Type]()
		end

		local Color = self.Activated and settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.CurrentMarker, Enum.StudioStyleGuideModifier.Selected) or settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.Mid)
		self.UI.BackgroundColor3 = Color

		if self.UIProperties then
			self.UIProperties.Visible = self.Activated
		end

		ChangeHistoryService:SetWaypoint(string.format("Updated %s part(s) with %s tag.", tostring(#Selection:Get()), self.Name))
	end
	self.UI.MouseButton1Click:Connect(ButtonClicked)

	return setmetatable(self, button)
end

function button:Destroy()
	self.Maid:DoCleaning()

	if self.UIProperties then
		self.PropHandler:Destroy()
	end
end

return button
