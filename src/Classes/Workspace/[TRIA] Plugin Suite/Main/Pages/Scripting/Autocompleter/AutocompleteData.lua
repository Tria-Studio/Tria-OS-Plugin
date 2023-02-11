local Data = {}
Data.Properties = {branches = {}}
Data.Methods = {branches = {}}

-- TODO: Make this possibly use Github to fetch latest APIs which might be deprecated.

for _, module in ipairs(script.Parent.API.Methods:GetChildren()) do
	local moduleData = require(module)
	Data.Methods.branches[module.Name] = moduleData
end
for _, module in ipairs(script.Parent.API.Props:GetChildren()) do
	local moduleData = require(module)
	Data.Properties.branches[module.Name] = moduleData
end

return Data