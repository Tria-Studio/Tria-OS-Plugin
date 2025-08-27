local Data = {}
Data.Properties = {Branches = {}}
Data.Methods = {Branches = {}}

for _, module in ipairs(script.Parent.API.Methods:GetChildren()) do
	local moduleData = require(module)
	Data.Methods.Branches[module.Name] = moduleData
end
for _, module in ipairs(script.Parent.API.Props:GetChildren()) do
	local moduleData = require(module)
	Data.Properties.Branches[module.Name] = moduleData
end

return Data