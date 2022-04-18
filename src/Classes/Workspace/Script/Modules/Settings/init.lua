local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Maid = require(script.Parent.Other.Maid)
local Signal = require(script.Parent.Other.Signal)
local UtilModule = require(script.Parent.UtilFuncs)
local SelectMap = require(script.Parent.SelectMap)
local SelectColor = require(script.SelectColor)

local UI = UtilModule.UI
local ColorFrame = UI.ColorWheel.Main

--[[
	TODO
	 - Create UI [DONE]
	 - Dark + Light mode [DONE]
	 - UI hints 
	 - program color selector
	 - Create a dropdown menu thing
	 - Abillity to edit settings
	 - Abillity to listen to settings to update
	 - reset settings
]]

local module = {
	Maid = Maid.new()
}

local function TextToOutput(Frame, Text, Color: boolean?)
	local CurrentText = Frame.TextBox.Text
	local Types = {}

	function Types.String()
		return Text, true
	end
	function Types.Number()
		if tonumber(Text) then
			return tonumber(Text), true
		else
			return Frame:GetAttribute("Last")
		end
	end
	function Types.Color()
		local Mult = 1

		if typeof(Text) == "Color3" then
			local NewText = string.format("%s, %s, %s", tostring(Text.R * 255), tostring(Text.G * 255), tostring(Text.B * 255))
			Text = NewText
		end

		Text = string.gsub(Text, " ", "")
		if string.find(Text, "Color3%.%a%a%a%(", 1) then
			Text = string.gsub(Text, 'Color3%.%a%a%a%(', "")
			Mult = 255
		elseif string.find(Text, "Color3.%a%a%a%a%a%a%a%(", 1) then
			Text = string.gsub(Text, 'Color3%.%a%a%a%a%a%a%a%(', "")
		end
		Text = string.gsub(Text, "%)", "")

		local Texts = string.split(Text, ",")
		for _, Thing in pairs(Texts) do
			if not tonumber(Thing) then
				return Frame:GetAttribute("Last")
			end
		end

		if Color then
			return #Texts == 3 and Color3.fromRGB(math.min(math.floor(Texts[1] * Mult + .5), 255), math.min(math.floor(Texts[2] * Mult + .5), 255), math.min(math.floor(Texts[3] * Mult + .5), 255)), true or Frame:GetAttribute("Last")
		else
			return #Texts == 3 and string.format("%s, %s, %s", tostring(math.min(math.floor(Texts[1] * Mult + .5), 255)), tostring(math.min(math.floor(Texts[2] * Mult + .5), 255)), tostring(math.min(math.floor(Texts[3] * Mult + .5), 255))), true or Frame:GetAttribute("Last")
		end
	end
	function Types.Time()
		local Texts = string.split(Text, ":")

		if #Texts ~= 3 then
			return Frame:GetAttribute("Last")
		end
		for i, Thing in pairs(Texts) do
			if not tonumber(Thing) then
				return Frame:GetAttribute("Last")
			end
			if #Thing == 1 then
				Texts[i] = 0 .. Thing
			elseif tonumber(Thing) and #Thing > 2 then
				Texts[i] = string.sub(Thing, 1, 2)
			end
		end
		return #Texts == 3 and string.format("%s:%s:%s", Texts[1], Texts[2], Texts[3]), true or Frame:GetAttribute("Last")
	end
	function Types.Boolean()
		if tonumber(Text) then
			return tonumber(Text), true
		else
			return Frame:GetAttribute("Last")
		end
	end
	function Types.Dropdown()
		return Text, true
	end

	--print(Frame:GetAttribute("Type"))
	local Val1, Val2 = Types[Frame:GetAttribute("Type")]()
	return Val1, Val2
end



for _, Button in pairs(UI.Frames.Settings:GetDescendants()) do
	if Button.Name == "SelectColor" then
		Button.MouseButton1Click:Connect(function()
			local Frame = Button.Parent
			SelectColor.SelectColor(Frame)
		end)
	end
end

SelectMap.MapChanged:Connect(function(Map)
	module.Maid:DoCleaning()
	ColorFrame.Parent.Visible = false

	if not Map then
		for _, Frame in pairs(UI.Frames.Settings:GetDescendants()) do
			if Frame:IsA("TextBox") then
				Frame.Parent:SetAttribute("Last", "")
				Frame.Text = ""

				if Frame.Parent:GetAttribute("Type") == "Boolean" then
					Frame.Parent.Image.Image = "rbxassetid://6031068420"
				end
			end
		end
	else
		local MapSettings = Map.Settings

		for _, Frame in pairs(UI.Frames.Settings:GetDescendants()) do
			if Frame:IsA("TextBox") then
				Frame.Parent:SetAttribute("Last", "")
				Frame.Text = ""
			end
		end

		for _, Frame in pairs(UI.Frames.Settings:GetDescendants()) do
			if Frame:IsA("TextBox") then
				local Parents = {}

				if Frame.Parent.Parent.Parent.Parent.Name == "Settings" then
					table.insert(Parents, Frame.Parent.Parent.Parent.Name)
					table.insert(Parents, Frame.Parent.Parent.Name)
				else
					table.insert(Parents, Frame.Parent.Parent.Name)
				end

				local Continue
				local Value
				local Setting = MapSettings
				for _, Parent in pairs(Parents) do
					if Frame.Parent.Name ~= "custom" then
						if not Setting:FindFirstChild(Parent) then
							Frame.TextEditable = false
							Frame.TextColor3 = Color3.new()
							Frame.TextStrokeColor3 = Color3.fromRGB(178, 178, 178)
							Frame.TextStrokeTransparency = .25
							Frame:SetAttribute("BlockTextColor", true)
							Frame.Text = "[no setting found]"
							Continue = true
							break
						end
						Setting = Setting[Parent]
					end
				end

				local Name = Frame.Parent.Name

				if Continue then
					continue
				end

				Frame:SetAttribute("BlockTextColor", false)
				if Frame and Frame.Parent and Frame.Parent:GetAttribute("Type") ~= "Color" then
					Frame.TextStrokeTransparency = 1

					local StudioTheme = settings().Studio.Theme
					local Color = Frame:GetAttribute("Theme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("Theme")])
					local TextColor  = Frame:GetAttribute("TextTheme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("TextTheme")])
					local TextStrokeColor  = Frame:GetAttribute("TextStrokeTheme") and StudioTheme:GetColor(Enum.StudioStyleGuideColor[Frame:GetAttribute("TextStrokeTheme")])

					if TextColor and not Frame:GetAttribute("BlockTextColor") then
						Frame.TextColor3 = TextColor
					end
					if Color then
						Frame.BackgroundColor3 = Color
					end
					if TextStrokeColor and not Frame:GetAttribute("BlockTextColor") then
						Frame.TextStrokeColor3 = TextStrokeColor
					end
					Frame.BorderColor3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
				end

				module.Maid:GiveTask(
					Setting:GetAttributeChangedSignal(Name):Connect(function()
						local Output = Setting:GetAttribute(Name)

						Frame.Parent:SetAttribute("Last", Frame.Text)

						if Frame.Parent:GetAttribute("Type") == "Color" then
							Frame.Text = string.format("%s, %s, %s", tostring(math.floor(Output.R * 255 + .5)), tostring(math.floor(Output.G * 255 + .5)), tostring(math.floor(Output.B * 255 + .5)))
							Frame.TextColor3 = Output
						elseif Frame.Parent:GetAttribute("Type") == "Boolean" then
							Frame.Parent.Image.Image = if Setting:GetAttribute(Name) then "rbxassetid://6031068421" else "rbxassetid://6031068420"
						elseif Frame.Parent:GetAttribute("Type") == "Dropdown" then
							Frame.Text = Output
						end
					end)
				)

				if not Frame.Parent:GetAttribute("NoEdit") then
					if Frame.Parent:GetAttribute("Type") == "Boolean" then
						module.Maid:GiveTask(
							Frame.Parent.Image.MouseButton1Click:Connect(function()

								ChangeHistoryService:SetWaypoint(string.format("Changing map settings %s.", Frame.Parent.Name))

								local currentState = Frame:GetAttribute("Value")
								local NewValue = not currentState

								local Output, Success = TextToOutput(Frame.Parent, NewValue)

								Frame:SetAttribute("Value", NewValue)
								if Success then
									Frame.Parent:SetAttribute("Last", currentState)
									Setting:SetAttribute(Frame.Parent.Name, Output)
								end

								Frame.Parent.Image.Image = if NewValue then "rbxassetid://6031068421" else "rbxassetid://6031068420"
								Setting:SetAttribute(Frame.Parent.Name, NewValue)
								ChangeHistoryService:SetWaypoint(string.format("Changed map settings %s.", Frame.Parent.Name))
							end))
					elseif Frame.Parent:GetAttribute("Type") == "Dropdown" then
						module.Maid:GiveTask(Frame.Parent.DropButton.MouseButton1Click:Connect(function()
							if not Frame:GetAttribute("Dropdown") then
								Frame:SetAttribute("Dropdown", true)
								local Current = Frame.Text
								local Value = UtilModule.DropdownMenu(Frame.Parent.Dropdown)

								if Value then
									local Output, Success = TextToOutput(Frame.Parent, Value)

									if Success then
										ChangeHistoryService:SetWaypoint(string.format("Changing map settings %s.", Frame.Parent.Name))
										Frame.Text = Value
										Frame.Parent:SetAttribute("Last", Current)

										Setting:SetAttribute(Frame.Parent.Name, Output)
										ChangeHistoryService:SetWaypoint(string.format("Changed map settings %s.", Frame.Parent.Name))
									end
								end

								task.wait()
								Frame:SetAttribute("Dropdown", false)
							end
						end))
					else
						if Frame.Parent.Name ~= "custom" then
							module.Maid:GiveTask(
								Frame.FocusLost:Connect(function()

									ChangeHistoryService:SetWaypoint(string.format("Changing map settings %s.", Frame.Parent.Name))

									local Text = Frame.Text
									local Output, Success = TextToOutput(Frame.Parent, Frame.Text)
									Frame.Text = Output

									if Success then
										Frame.Parent:SetAttribute("Last", Text)
									end
									if Frame.Parent:GetAttribute("Type") == "Color" then
										Frame.TextColor3 = SelectColor.GetColorFromString(Output)
										Setting:SetAttribute(Frame.Parent.Name, SelectColor.GetColorFromString(Output))
									else
										Setting:SetAttribute(Frame.Parent.Name, Output)
									end

									ChangeHistoryService:SetWaypoint(string.format("Changed map settings %s.", Frame.Parent.Name))
								end))
						end
					end
				end


				if Frame.Parent:GetAttribute("Type") == "Color" then
					local Color = Setting:GetAttribute(Frame.Parent.Name)
					if not Color then
						continue
					end
					Value = string.format("%s, %s, %s", tostring(math.floor(Color.R * 255 + .5)), tostring(math.floor(Color.G * 255 + .5)), tostring(math.floor(Color.B * 255 + .5)))
				elseif Frame.Parent:GetAttribute("Type") == "Time" then
					Value = Setting:GetAttribute("TimeOfDay") or Setting:GetAttribute("ClockTime")
				elseif Frame.Parent:GetAttribute("Type") == "Boolean" then
					Frame:SetAttribute("Value", Setting:GetAttribute(Frame.Parent.Name) or Frame.Parent:GetAttribute("Default"))
					Frame.Parent.Image.Image = if Frame:GetAttribute("Value") then "rbxassetid://6031068421" else "rbxassetid://6031068420"
				else
					Value = Setting:GetAttribute(Frame.Parent.Name)
				end

				if not Value then
					continue
				end

				Frame.Text = TextToOutput(Frame.Parent, Value)
				Frame.Parent:SetAttribute("Last", Frame.Text or "")
				if Frame.Parent:GetAttribute("Type") == "Color" then
					Frame.TextColor3 = TextToOutput(Frame.Parent, Value, true)
				end

			end
		end

		module.Maid:GiveTask(
			UI.Frames.Settings.Lighting.Import.TextButton.MouseButton1Click:Connect(function()

				ChangeHistoryService:SetWaypoint("Importing settings from lighting to map")

				for _, Frame in pairs(UI.Frames.Settings.Lighting:GetChildren()) do
					if Frame:IsA("Frame") then
						local Value = Lighting[Frame:GetAttribute("Type") == "Time" and "TimeOfDay" or Frame.Name]

						Frame:SetAttribute("Last", Frame.TextBox.Text)
						local Output, Success = TextToOutput(Frame, Value)
						if Success then
							Frame.TextBox.Text = Output
						end

						if Frame:GetAttribute("Type") == "Color" then
							Frame.TextBox.TextColor3 = Value
						end
					end
				end

				ChangeHistoryService:SetWaypoint("Imported settings from lighting to map")
			end)
		)

		module.Maid:GiveTask(
			UI.Frames.Settings.Lighting.Export.TextButton.MouseButton1Click:Connect(function()

				ChangeHistoryService:SetWaypoint("Exporting settings from lighting to map")

				for _, Frame in pairs(UI.Frames.Settings.Lighting:GetChildren()) do
					if Frame:IsA("Frame") then
						local Name = Frame:GetAttribute("Type") == "Time" and "TimeOfDay" or Frame.Name
						local Value = MapSettings.Lighting:GetAttribute(Name)

						if Value then
							Lighting[Name] = Value 
						end
					end
				end

				ChangeHistoryService:SetWaypoint("Exported settings from lighting to map")
			end)
		)
	end
end)

return module
