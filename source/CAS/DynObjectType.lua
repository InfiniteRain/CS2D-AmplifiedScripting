-- Initializing dynamic object type class.
local DynObjectType = class() -- Acts as the inner class of the dynObject class.

--~~~~~~~~~~~~~~~~--
-- Static methods --
--~~~~~~~~~~~~~~~~--

---
-- Turns object type ID into an instance.
--
-- @param objectTypeID (number)
--   The object type ID
-- @return (instance of DynObjectType)
--   If the type ID is valid, returns the instance representing that object type ID
--
function DynObjectType.getInstance(objectTypeID)
    DynObjectType._validator:validate({
        { value = objectTypeID, type = 'number' }
    }, 'getInstance', 2)

    for key, value in pairs(DynObjectType) do
        if getmetatable(value) == DynObjectType then
            if value._objectTypeID == objectTypeID then
                return value
            end
        end
    end

    error('Provided object type ID does not represent a valid object type.', 2)
end

--~~~~~~~~~~~~~~~~~~--
-- Instance methods --
--~~~~~~~~~~~~~~~~~~--

---
-- Constructor. Can only be instantiated at certain times.
--
-- @param objectTypeID
--   The type ID of the object this instance should represent.
--
function DynObjectType:constructor(objectTypeID)
    DynObjectType._validator:validate({
        { value = objectTypeID, type = 'number' }
    }, 'constructor', 2)

    if not DynObjectType._allowInstantiation then
        error('Instantiation of this class is not allowed.', 2)
    end

    self._objectTypeID = objectTypeID
end

--== Setters/control ==--

---
-- Spawns a dynamic object. TODO: probably seperate the Buildings from NPC's?
--
-- @param ...
--
function DynObjectType:spawn(...)
    if self._objectTypeID >= 1 and self._objectTypeID <= 23 then
        local x, y, mode, team, player = ...

        DynObjectType._validator:validate({
            { value = x, type = 'number' },
            { value = y, type = 'number' },
            { value = mode, type = 'number' },
            { value = team, type = 'number' },
            { value = player, type = Player, optional = true }
        }, 'spawn', 2)

        Console.parse('spawnobject', self._objectTypeID, x, y, 0, mode, team, player and player or 0)
    elseif self._objectTypeID == 30 then
        local npcType, x, y, angle = ...

        DynObjectType._validator:validate({
            { value = npcType, type = 'string' },
            { value = x, type = 'number' },
            { value = y, type = 'number' },
            { value = angle, type = 'number' }
        }, 'spawn', 2)

        if not DynObjectType._npcs[npcType] then
            error('Passed "npcType" value does not represent a valid npc type.', 2)
        end

        Console.parse('spawnnpc', DynObjectType._npcs[npcType], x, y, angle)
    elseif self._objectTypeID == 40 then
        error('Objects with the type of image cannot be spawned using this method. Use methods of "MapImage", '
            .. '"PlayerImage" or "HudImage" to spawn images.', 2)
    end
end

--~~~~~~~~~~~~~~~--
-- Static fields --
--~~~~~~~~~~~~~~~--

-- Validator.
DynObjectType._validator = Validator()

-- NPC list.
DynObjectType._npcs = {
    ['zombie'] = 1,
    ['headcrab'] = 2,
    ['snark'] = 3,
    ['vortigaunt'] = 4,
    ['soldier'] = 5
}

--~~~~~~~~~~~~~~~~~~~~~--
-- Returning the class --
--~~~~~~~~~~~~~~~~~~~~~--

return DynObjectType
