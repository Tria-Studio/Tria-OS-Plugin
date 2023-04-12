return {
	AutocompleteArgs= {"featureName"},
	Name = "GetFeature",
	Branches = nil,
	Documentation = {
		value = "Allows you to get a specific Feature from the MapLib"
	},
	CodeSample = [[
AVALIABLE_FEATURES = {
	"Skills", -- Interact with the skills (sliding, etc.) that the map uses
	"Settings", -- Get local player settings (ex. level of detail)
}

-- Get the Skills feature
local Skills = MapLib:GetFeature(\"Skills\")]],
}
