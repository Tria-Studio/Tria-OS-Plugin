--[[
    The instance that will be in charge of creating the view mode "object" for a type of thing.

    CALLS:

    new() - creates it

    objectType - variable for the type of object its tracking
    _maid - internal cleanup for all instances and  events related to enable()

    setcolor() - updates the color used for visualization
    enable() - starts visualization
    disable() - stops visualization and clears all objects related to it

    destroy() - destroys it (will be used for variants)
]]
