local Signal = require(script.Signal)
local Maid = require(script.Maid)

local util = {
    Signal = Signal,
    Maid = Maid,

    mapModel = nil,
    MapChanged = Signal.new(),

    
}

return util