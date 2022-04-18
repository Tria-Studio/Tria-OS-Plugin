local RunService = game:GetService("RunService")

local Maid = require(script.Parent.Other.Maid)
local Signal = require(script.Parent.Other.Signal)

local module = {
	Map = nil,
	UI = script.Parent.Parent.Widget,
	Widget = nil,
	PluginSettings = nil,

	FuncTags = {
		"_Show",
		"_Hide",
		"_Fall",
		"_Explode",
		"_Destroy",
		"_Sound",
	},
	ObjectTags = {
		"_WallRun",
		"_WallJump",
	},
	BoostTags = {
		"_SpeedBooster",
		"_JumpBooster",
	},
	AirTank = "AirTank",
	KillTag = "_Kill",
	DetailTag = "Detail",
	ButtonTag = "_Button",
	WaterTag = "_Liquid",
}



function module.GetTagType(Tag: string): string
	if table.find(module.FuncTags, Tag) then
		return "Button"
	elseif Tag == module.KillTag then
		return "Kill"
	elseif table.find(module.ObjectTags, Tag) then
		return "Object"
	elseif table.find(module.BoostTags, Tag) then
		return "Boost"
	elseif Tag == module.ButtonTag then
		return "ButtonObj"
	elseif Tag == module.WaterTag then
		return "Water"
	elseif Tag == module.AirTank then
		return "AirTank"
	elseif Tag == module.DetailTag then
		return "Detail"
	end
	return ""
end
function module.GetPartsWithTag(Tag: string)
	assert(Tag, "No tag select")
	assert(module.Map, "No map selected.")

	local FindTag = Tag .. "%d"
	local PossibleTags = nil
	
	if table.find(module.FuncTags, FindTag) then
		PossibleTags = module.FuncTags
	elseif table.find(module.ObjectTags, FindTag) then
		PossibleTags = module.ObjectTags
	elseif table.find(module.BoostTags, FindTag) then
		PossibleTags = module.BoostTags
	elseif module.ButtonTag == FindTag then
		PossibleTags = {module.ButtonTag}
	elseif module.WaterTag == FindTag then
		PossibleTags = {module.WaterTag}
	elseif FindTag == module.DetailTag then
		PossibleTags = "Detail"
	end
	assert(PossibleTags, "No possible tags found.")

	local Found = {}
	
	if Tag == "Detail" then
		if module.Map:FindFirstChild("Detail") then
			for _, object in pairs(module.Map.Detail:GetDescendants()) do
				table.insert(Found, object)
			end
		end
	else
		for _, object in pairs(module.Map:GetDescendants()) do
			if object:IsA("ObjectValue") then
				local Name = string.gsub(object.Name, "%d", "%%d")

				if table.find(PossibleTags, Name) then
					table.insert(Found, object)
				end
			end
		end
	end

	return Found
end

function module.GetTag(Part: Instance, Tag: string): Instance | nil
	for _, Object in pairs(Part:GetChildren()) do
		if (Tag == "_Sound" and Object:IsA("Sound") or Tag == "_WallRun" and Object:IsA("NumberValue") or Object:IsA("ObjectValue")) and string.find(Object.Name, Tag, 1, true) then
			return Object
		end
	end
end

function module.IsTagged(Part: Instance, Tag: string): boolean
	local Type = module.GetTagType(Tag)

	local Types = {}

	function Types.Button()
		for _, Object in pairs(Part:GetChildren()) do
			if (Tag == "_Sound" and Object:IsA("Sound") or Object:IsA("ObjectValue")) and string.find(Object.Name, Tag, 1, true) then
				return true
			end
		end
	end
	function Types.Object()
		for _, Object in pairs(Part:GetChildren()) do
			if (Tag == "_WallRun" and Object:IsA("NumberValue") or Object:IsA("ObjectValue")) and Object.Name == Tag then
				return true
			end
		end
	end
	function Types.Kill()
		if Part:GetAttribute("_Kill") then
			return true
		end
		for _, Object in pairs(Part:GetChildren()) do
			if Object:IsA("ObjectValue") and Object.Name == Tag then
				return true
			end
		end
	end
	function Types.Boost()
		return Part.Name == Tag
	end
	function Types.Detail()
		if Part:GetAttribute("_Detail") then
			return true
		end
		for _, Object in pairs(Part:GetChildren()) do
			if Object:IsA("ObjectValue") and Object.Name == Tag then
				return true
			end
		end
	end
	function Types.AirTank()
		return Part.Name == "AirTank" and Part:IsA("Model") or Part.Name == "Hitbox" and Part.Parent.Name == "AirTank" and Part.Parent:IsA("Model")
	end
	function Types.ButtonObj()
		local function FindParts(part: Instance): boolean
			return if part:FindFirstChild("Light") and part:FindFirstChild("Hitbox") then true else false
		end

		local Button = string.sub(Part.Name, 1, 7) == "_Button" and Part:IsA("Model") and FindParts(Part) and Part or string.sub(Part.Parent.Name, 1, 7) == "_Button" and Part.Parent:IsA("Model") and FindParts(Part.Parent) and Part.Parent

		if Button then return true end
	end
	function Types.Water()
		return string.find(Part.Name, "_Liquid", 1, true)
	end
	function Types.Detail()
		return module.Map:FindFirstChild("Detail") and Part:IsDescendantOf(module.Map:FindFirstChild("Detail"))
	end

	local Value = Types[Type] and Types[Type]()
	return Value
end

function module.ArePartsTagged(Parts, Tag: string): boolean
	for _, Part in pairs(Parts) do
		if not module.IsTagged(Part, Tag) or not Part:IsDescendantOf(module.Map) then
			return false
		end
	end

	return true
end

function module:Cleanup()

end

function module.Warn(Message: string, WaitForCallback: boolean?, TextOverride: string?, DarkenBack: boolean?)
	local UI = module.UI
	local Texts = {
		"Ok",
		"Ok",
		"Ok",
		"Ok",
		"Ok",
		"K",
		"K",
		"K",
		"Fine",
		"Fine",
		"Fine",
		"Ight",
		"Ight",
		"Ight",
		"Whatever",
	}

	UI.Message.Main.TextLabel.Size = UDim2.new(1, 0, 0, 2000)
	UI.Message.Main.TextLabel.Text = Message
	local Size = game:GetService("TextService"):GetTextSize(Message, 14, Enum.Font.SourceSansBold, Vector2.new(UI.Message.Main.TextLabel.AbsoluteSize.X, UI.Message.Main.TextLabel.AbsoluteSize.X))
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	UI.Message.Main.TextLabel.Size = UDim2.new(1, 0, 0, Size.Y)
	UI.Message.Size = UDim2.new(1, 0, 0, 64 + 0 + Size.Y)
	UI.Message.Visible = true
	UI.Message.Main.TextButton.Text = TextOverride or Texts[math.random(1, #Texts)]

	if DarkenBack then
		UI.Message.Main.Back.Visible = true
	end
	if WaitForCallback then
		UI.Message.Main.TextButton.MouseButton1Click:Wait()
	end
end

function module.DropdownMenu(Frame: Frame)
	Frame.Visible = true
	Frame.Parent._Backdrop.Visible = true
	Frame.Parent.DropButton.Image = "rbxassetid://6031094679"

	local Value
	local Maid = Maid.new()
	local Continue = Signal.new()

	Maid:GiveTask(Frame.Parent.DropButton.MouseButton1Click:Connect(function()
		Continue:Fire()
	end))

	for _, Frame: Instance in pairs(Frame:GetChildren()) do
		if Frame:IsA("TextButton") then
			Maid:GiveTask(Frame.MouseButton1Click:Connect(function()
				Value = Frame:GetAttribute("Value")
				Continue:Fire()
			end))
		elseif Frame:IsA("TextLabel") and Frame.Name == "custom" then
			Maid:GiveTask(Frame.confirm.MouseButton1Click:Connect(function()
				if Frame.TextBox.Text ~= "" then
					Value = Frame.TextBox.Text
					Continue:Fire()
				end
			end))
		end
	end

	Continue:Wait()
	Maid:Destroy()

	Frame.Parent.DropButton.Image = "rbxassetid://6031094687"
	Frame.Visible = false
	Frame.Parent._Backdrop.Visible = false
	return Value
end

module.UI.Message.Main.TextButton.MouseButton1Click:Connect(function()
	module.UI.Message.Visible = false
	module.UI.Message.Main.Back.Visible = false
end)

return module
