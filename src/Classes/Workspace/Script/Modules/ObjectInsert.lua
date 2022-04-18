local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local InsertService = game:GetService("InsertService")

local Maid = require(script.Parent.Other.Maid)
local Signal = require(script.Parent.Other.Signal)
local UtilModule = require(script.Parent.UtilFuncs)

local module = {}


--[[
	TODO
	 - make sure addon isnt already installed
	 - tell the player if it already is
	 - tell the player it successfully installed
]]

for _, Type in pairs(UtilModule.UI.Frames.Insert:GetChildren()) do
	if Type:IsA("Frame") then
		for _, Button in pairs(Type:GetChildren()) do
			if Button:IsA("TextButton") then

				Button.MouseButton1Click:Connect(function()
					if not UtilModule.Map and Type.Name ~= "MapKits" then
						UtilModule.Warn("You need to have a map selected to load map components or map addons.")
						warn("You need to have a map selected to load map components or map addons.")
						return
					end

					if Button:GetAttribute("IsThirdParty") and not Button:GetAttribute("_ThirdPartyAgreed") then
						UtilModule.Warn("[NOTICE] This asset is not made by TRIA or grif_0\n", true, "I understand", true)
						Button:SetAttribute("_ThirdPartyAgreed", true)
					end

					local Types = {}

					function Types.Components()
						local Model = script.Parent.Parent.Inserts[Button.Name]:Clone()
						Model:PivotTo(CFrame.new((workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -10)).Position))
						Model.Parent = UtilModule.Map
						Selection:Set({Model})

						if Button.Name == "MapExit" then
							Selection:Set({Model.ExitBlock, Model.ExitRegion})
							Model.ExitBlock.Parent = UtilModule.Map

							local Folder = UtilModule.Map:FindFirstChild("ExitRegion")
							Model.ExitRegion.Parent = Folder and Folder:IsA("Folder") and Folder or UtilModule.Map
							Model:Destroy()
						elseif Button.Name == "Button" then
							Model.Name = "_Button#"
						end

					end
					function Types.MapKits()
						local Names = {
							JumpKit = "TRIA.os Jumps Kit by epicflamingo100",
							MapKit = "TRIA.os Map Kit by TRIA",
							TextureKit = "Texture Kit by Phexonia",
						}
						local Model = InsertService:LoadAsset(Button:GetAttribute("AssetId")) or script.Parent.Parent.Inserts:FindFirstChild(Button.Name) and script.Parent.Parent.Inserts:FindFirstChild(Button.Name):Clone()
						Model:PivotTo(CFrame.new((workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -10)).Position))
						Model.Parent = workspace

						UtilModule.Warn(string.format("[NOTICE] Successfuly inserted %s \n", Names[Button.Name]) )
						Model.Name = Names[Button.Name]
						Selection:Set({Model})
					end
					function Types.Addons()

						if UtilModule.Map.MapScript:FindFirstChild(Button.Name) then
							UtilModule.Warn("You already have this addon installed.")
							warn("You already have this addon installed.")
							return
						end

						local Model = script.Parent.Parent.Inserts:FindFirstChild(Button.Name) and script.Parent.Parent.Inserts:FindFirstChild(Button.Name):Clone() or InsertService:LoadAsset(Button:GetAttribute("AssetId"))
						Model:PivotTo(CFrame.new((workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -10)).Position))
						Model.Parent = workspace
						Selection:Set({Model})
						Model.Parent = UtilModule.Map
						if Button.Name == "Waterjet" then
							Selection:Set({Model._WaterJet1})
							Model._WaterJet1.Parent  = UtilModule.Map
							Model.WaterJetMod.Parent = UtilModule.Map.MapScript
							Model:Destroy()

							UtilModule.Warn(string.format("[NOTICE] Successfuly installed %s\n", "Waterjet by grif_0") )
							--plugin:OpenScript(UtilModule.Map.MapScript.WaterJetMod, 1)
						elseif Button.Name == "EasyTP" then
							UtilModule.Warn(string.format("[NOTICE] Successfuly installed %s\n", "EasyTP by grif_0") )
							Model.EasyTP.Parent = UtilModule.Map.MapScript
							Model:Destroy()
							--plugin:OpenScript(UtilModule.Map.MapScript.EasyTP, 1)
						end

						warn("Successfully installed " .. Button.Name .. ".")
					end

					game:GetService("ChangeHistoryService"):SetWaypoint("Inserting object...")

					Types[Type.Name]()

					game:GetService("ChangeHistoryService"):SetWaypoint("Inserted object.")
				end)
			end
		end
	end
end
return module