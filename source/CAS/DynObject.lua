-- Initializing dynamic object class.
local DynObject = class()

--~~~~~~~~~~~~~~~~--
-- Static methods --
--~~~~~~~~~~~~~~~~--

---
-- Checks if the dynamic object with the passed ID exists.
--
-- @param dynObjectID (number)
--   Numberic object ID
--
function DynObject.idExists(dynObjectID)
    DynObject._validator:validate({
        { value = dynObjectID, type = 'number' }
    }, 'idExists', 2)

    return _META.command.object(dynObjectID, 'exists')
end

---
-- Returns the CAS.DynObject instance from the passed object ID.
--
-- @param dynObjectID (number)
--   Numeric dyn object ID
-- @return (instance of CAS.DynObject)
--   The instance which represents the dyn object with that ID
--
function DynObject.getInstance(dynObjectID)
    DynObject._validator:validate({
        { value = dynObjectID, type = 'number' }
    }, 'getInstance', 2)

    if not _META.command.object(dynObjectID, 'exists') then
        error('Dynamic object with the passed ID was not fund.', 2)
    end

    for _, value in pairs(DynObject._instances) do
        if value._id == dynObjectID then
            DynObject._debug:log('Dynamic object "' .. tostring(value)
                .. '" was found in "_instances" table and returned.')
            return value
        end
    end

    DynObject._allowCreation = true
    local dynObject = DynObject(dynObjectID)
    DynObject._allowCreation = false

    return dynObject
end

---
-- Returns a table containing all the dynamic objects currently spawned.
--
-- @return (table)
--
function DynObject.dynamicObjects()
    local dynamicObjects = {}
    for _, value in pairs(_META.command.object(0, 'table')) do
        table.insert(dynamicObjects, DynObject.getInstance(value))
    end

    return dynamicObjects
end

---
-- Returns a dynamic object on the position.
--
-- @return (instance of CAS.DynObject)
--   On success, the instance representing a dyn object on that position
-- @return (boolean)
--   On failure, false
--
function DynObject.getDynamicObjectAt(x, y, dynObjectType)
    DynObject._validator:validate({
        { value = x, type = 'number' },
        { value = y, type = 'number' },
        { value = dynObjectType, type = DynObjectType, optional = true }
    }, 'getDynamicObjectAt', 2)

    local dynObject = _META.command.objectat(x, y, dynObjectType and dynObjectType._objectTypeID or nil)
    return dynObject ~= 0 and DynObject.getInstance(dynObject) or false
end

--~~~~~~~~~~~~~~~~~~--
-- Instance methods --
--~~~~~~~~~~~~~~~~~~--

---
-- Constructor.
--
-- @param dynObjectID (number)
--   The numeric ID of the dyn object which this instance should represent
--
function DynObject:constructor(dynObjectID)
    DynObject._validator:validate({
        { value = dynObjectID, type = 'number' }
    }, 'constructor', 2)

    if not _META.command.object(dynObjectID, 'exists') then
        error('Dynamic object with the passed ID was not fund.', 2)
    end

    for _, value in pairs(DynObject._instances) do
        if value._id == dynObjectID then
            error('Instance with the same object ID already exists.', 2)
        end
    end

    self._id = dynObjectID
    self._killed = false

    table.insert(DynObject._instances, self)

    DynObject._debug:log('Dynamic object "' .. tostring(self) .. '" was instantiated.')
end

---
-- Destructor. Properly disposes of the instance.
--
function DynObject:destructor()
    if not self._killed then
        self._killed = true
    end

    for key, value in pairs(DynObject._instances) do
        if value._id == self._id then
            -- Removes the dynamic object from the DynObject._instances table.
            DynObject._instances[key] = nil
        end
    end

    DynObject._debug:log('Dynamic object "' .. tostring(self) .. '" was garbage collected.')
end

---
-- Checking if the object was killed in game and needs to be disposed of, and if it is the case, raising an error.
--
function DynObject:errorIfNeedsDisposing()
    if self._killed then
        error('The dynamic object of this instance was already killed. It\'s better to dispose of this instance.', 3)
    end
end

--== Getters ==--

---
-- Returns the ID of the dynamic object.
--
-- @return (number)
-- The numeric ID of the dyn object
--
function DynObject:getID()
    self:errorIfNeedsDisposing()

    return self._id
end

---
-- Returns the type name of the dynamic object.
--
-- @return (string)
--
function DynObject:getTypeName()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'typename')
end

---
-- Returns the type of the dynamic object.
--
-- @return (instance of CAS.DynObjectType)
--
function DynObject:getType()
    self:errorIfNeedsDisposing()

    return DynObjectType.getInstance(_META.command.object(self._id, 'type'))
end

---
-- Returns health of the dynamic object.
--
-- @return (number)
--
function DynObject:getHealth()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'health')
end

---
-- Returns mode of the dynamic object.
--
-- @return (number)
--
function DynObject:getMode()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'mode')
end

---
-- Returns the team of the dynamic object.
--
-- @return (number)
--
function DynObject:getTeam()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'team')
end

---
-- Returns the player by whom the dynamic object was created, if the dyn object is not an NPC.
--
-- @return (instance of CAS.Player)
--
function DynObject:getPlayer()
    self:errorIfNeedsDisposing()

    if self:getType() == 30 then
        error('This dynamic object is an npc, thus does not have an owner.', 2)
    end

    return Player.getInstance(_META.command.object(self._id, 'player'))
end

---
-- Returns the type of NPC the dynamic object is (if the object is an NPC).
--
-- @return (number)
--
function DynObject:getNPCType()
    self:errorIfNeedsDisposing()

    if self:getType() ~= 30 then
        error('This dynamic object is not an npc, thus does not have an NPC type.', 2)
    end

    return _META.command.object(self._id, 'player')
end

---
-- Returns the position of the dynamic object.
--
-- @return
--   2 values:
--     X position (number),
--     Y position (number)
--
function DynObject:getPosition()
    self:errorIfNeedsDisposing()

    return
    _META.command.object(self._id, 'x'),
    _META.command.object(self._id, 'y')
end

---
-- Returns the X position of the dynamic object.
--
-- @return (number)
--
function DynObject:getX()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'x')
end

---
-- Returns the Y position of the dynamic object.
--
-- @return (number)
--
function DynObject:getY()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'y')
end

---
-- Returns the rotation of the dynamic object.
--
-- @return (number)
--
function DynObject:getRotation()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'rot')
end

---
-- Returns the tile position of the dynamic object.
--
-- @return
--   2 values:
--     X tile position,
--     Y tile position
--
function DynObject:getTilePosition()
    self:errorIfNeedsDisposing()

    return
    _META.command.object(self._id, 'tilex'),
    _META.command.object(self._id, 'tiley')
end

---
-- Returns the X tile position of the dynamic object.
--
-- @return (number)
--
function DynObject:getTileX()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'tilex')
end

---
-- Returns the Y tile position of the dynamic object.
--
-- @return (number)
--
function DynObject:getTileY()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'tiley')
end

---
-- Returns the countdown variable of the dynamic object.
--
-- @return (number)
--
function DynObject:getCountdown()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'countdown')
end

---
-- Returns the root rotation of the dynamic object.
--
-- @return (number)
--
function DynObject:getRootRotation()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'rootrot')
end

---
-- Returns the target of the dynamic object.
--
-- @return (instance of CAS.Player)
--   If there is a target, returns the player
-- @return (boolean)
--   If there is no target, returns false
--
function DynObject:getTarget()
    self:errorIfNeedsDisposing()

    local target = _META.command.object(self._id, 'target')
    return target ~= 0 and Player.getInstance(target) or false
end

---
-- Returns the update value of the dynamic object.
--
-- @return (number)
--
function DynObject:getUpgradeVal()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'upgrade')
end

---
-- Returns a boolean which signifies whether or not the dynamic object was spawned by an entity.
--
-- @return (boolean)
--
function DynObject:isSpawnedByEntity()
    self:errorIfNeedsDisposing()

    return _META.command.object(self._id, 'entity')
end

---
-- If the dynamic object was spawned by an entity, returns the spawn tile position.
--
-- @return
--   2 values:
--     X tile position (number),
--     Y tile position (number)
--
function DynObject:getSpawnEntityPosition()
    self:errorIfNeedsDisposing()

    if not DynObject:isSpawnedByEntity() then
        error('This dynamic object wasn\'t spawned by an entity.', 2)
    end

    return
    _META.command.object(self._id, 'entityx'),
    _META.command.object(self._id, 'entityy')
end

---
-- If the dynamic object was spawned by an entity, returns the spawn X tile position.
--
-- @return (number)
--
function DynObject:getSpawnEntityX()
    self:errorIfNeedsDisposing()

    if not DynObject:isSpawnedByEntity() then
        error('This dynamic object wasn\'t spawned by an entity.', 2)
    end

    return _META.command.object(self._id, 'entityx')
end

---
-- If the dynamic object was spawned by an entity, returns the spawn Y tile position.
--
-- @return (number)
--
function DynObject:getSpawnEntityY()
    self:errorIfNeedsDisposing()

    if not DynObject:isSpawnedByEntity() then
        error('This dynamic object wasn\'t spawned by an entity.', 2)
    end

    return _META.command.object(self._id, 'entityy')
end

--== Setters/control ==--

---
-- Damages the dynamic object.
--
-- @param damage (number)
--   The damage amount
-- @param player (instance of CAS.Player) (optional)
--   The player who inflicted the damage
--
function DynObject:damage(damage, player)
    DynObject._validator:validate({
        { value = damage, type = 'number' },
        { value = player, type = Player, optional = true }
    }, 'damage', 2)

    self:errorIfNeedsDisposing()

    if self:getType() == DynObjectType.image then
        error('This object is an image, thus it cannot be damaged.', 2)
    end

    player = player or 0

    Console.parse('damageobject', self._id, damage, player)
end

---
-- Kills the dynamic object.
--
function DynObject:kill()
    self:errorIfNeedsDisposing()

    if self:getType() == DynObjectType.image then
        Image.getInstance(self._id):free()
    else
        Console.parse('killobject', self._id)
    end

    self._killed = true;
end

--~~~~~~~~~~~~~~~--
-- Static fields --
--~~~~~~~~~~~~~~~--

-- Validator.
DynObject._validator = Validator()

-- Defines if instantiation of this class is allowed.
DynObject._allowCreation = false
-- A table of instances of this class.
DynObject._instances = setmetatable({}, { __mode = 'kv' })
-- Debug for dynamic objects.
DynObject._debug = Debug(Color.yellow, 'CAS Dynamic Object')
DynObject._debug:setActive(_META.config.debugMode)

--~~~~~~~~~~~~~~~~~~~~~--
-- Returning the class --
--~~~~~~~~~~~~~~~~~~~~~--

return DynObject
