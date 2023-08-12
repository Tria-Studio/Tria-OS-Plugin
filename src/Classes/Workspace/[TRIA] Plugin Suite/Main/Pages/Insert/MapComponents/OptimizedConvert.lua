local Package = script.Parent.Parent.Parent.Parent
local Util = require(Package.Util)
local TagUtils = require(Package.Util.TagUtils)

local function OptimizedConvert()
    local Map = Util.mapModel:get()
    local Special = Map:FindFirstChild("Special")

    -- Spawn

    if Map:FindFirstChild("Spawn") then
        Map.Spawn.Parent = Special
    end

    for i, object in pairs(Map:GetDescendants()) do
        -- Exit reigon(s) + block(s)

        if object.Name == "ExitRegion" and object:IsA("BasePart") then
            object.Parent = Special.Exit.ExitRegion
        elseif object.Name == "ExitBlock" and object:IsA("BasePart") then
            object.Parent = Special.Exit.ExitBlock
        end

        -- buttons
        if object:IsA("Model") and TagUtils:PartHasTag(object, "_Button") then
            object.Parent = Special.Button
        end

        -- buttonTags

        if TagUtils:PartHasTag(object, "_Show") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end
        if TagUtils:PartHasTag(object, "_Hide") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end
        if TagUtils:PartHasTag(object, "_Fall") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end
        if TagUtils:PartHasTag(object, "_Explode") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end
        if TagUtils:PartHasTag(object, "_Destroy") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end
        if TagUtils:PartHasTag(object, "_Sound") and not object:IsDescendantOf(Special.Button) then
            object.Parent = Special.Button
        end

        -- fluids

        if TagUtils:PartHasTag(object, "_Liquid") then
            object.Parent = Special.Fluid
        end
        if TagUtils:PartHasTag(object, "_Gas") then
            object.Parent = Special.Fluid
        end

        -- rail

        if TagUtils:PartHasTag(object, "Rail") then
            object.Parent = Special.Rail
        end

        -- zipline

        if TagUtils:PartHasTag(object, "Zipline") then
            object.Parent = Special.Rail
        end

        -- interactables

        if TagUtils:PartHasTag(object, "Orb") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "_WallJump") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "_WallRun") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "_Kill") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "Teleporter") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "_SpeedBooster") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "_JumpBooster") then
            object.Parent = Special.Interactable
        end
        if TagUtils:PartHasTag(object, "AirTank") then
            object.Parent = Special.Interactable
        end
        

    end

    task.delay(0.25, function()
        Util:ShowMessage("Finished Converting", "Your map has finished converting to OptimizedStructure.\n\nHOWEVER, any scripts that might have referenced any TRIA.os objets (ie. Liquids) will need to get rescripted to the new path. ", {Text = "I Understand", Callback = function() end})
    end)
end

return OptimizedConvert
