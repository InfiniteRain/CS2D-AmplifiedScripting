-- Initializing the entity class.
local Entity = class()

--~~~~~~~~~~~~~~~~--
-- Static methods --
--~~~~~~~~~~~~~~~~--

---
-- Checks if the position has an entity on it.
--
-- @param x (number)
--   X tile position
-- @param y (number)
--   Y tile position
--
function Entity.hasEntityOnPosition(x, y)
    Entity._validator:validate({
        { value = x , type = 'number' },
        { value = y , type = 'number' }
    }, 'hasEntityOnPosition', 2)

    return _META.command.entity(x, y, 'exists')
end

---
-- Gets entity on a certain position.
--
-- @param x (number)
--   X tile position
-- @param y
--   Y tile position
--
-- @return (instance of CAS.Entity)
--   If an entity was found on the provided position, returns the instance of CAS.Entity which represents that entity.
--
function Entity.getInstance(x, y)
    Entity._validator:validate({
        { value = x, type = 'number' },
        { value = y, type = 'number' }
    }, 'getInstance', 2)

    for _, value in pairs(Entity._instances) do
        if value:getX() == x and value:getY() == y then
            return value
        end
    end

    error('Entity on the provided position doesn\'t exist.', 2)
end

---
-- Gets a list of all the entities on the map.
--
-- @param typeName (string) (optional)
--   If set, will return entities of only that type.
--
-- @return (table)
--   A list of the entities that were found.
--
function Entity.getEntities(typeName)
    Entity._validator:validate({
        { value = typeName, type = 'entity', optional = true }
    }, 'getEntities', 2)

    local entityTable = {}
    for _, value in pairs(_META.command.entitylist(typeName and Entity.type[typeName] or nil)) do
        table.insert(entityTable, Entity.getInstance(value.x, value.y))
    end

    return entityTable
end

---
-- Returns type name of an entity from its type ID.
--
-- @param typeID (number)
--   The type ID
--
-- @return (string)
--   If a correct type ID was provided, returns the type name of that type ID
--
function Entity.getTypeNameFromID(typeID)
    Entity._validator:validate({
        { value = typeID, type = 'number' }
    }, 'getTypeNameFromID', 2)

    for key, value in pairs(Entity.type) do
        if typeID == value then
            return key
        end
    end

    error('Provided entity type ID does not represent a valid entity type.', 2)
end

---
-- Checks if the position is in an entity zone.
--
-- @param x (number)
--   X tile position
-- @param y (number)
--   Y tile position
-- @param typeName (string)
--   Type name of the entity
--
function Entity.isPositionInEntityZone(x, y, typeName)
    Entity._validator:validate({
        { value = x, type = 'number' },
        { value = y, type = 'number' },
        { value = typeName, type = 'string' },
    }, 'isPositionInEntityZone', 2)

    if not Entity.type[typeName] then
        error('Provided entity type is not valid.', 2)
    end

    return _META.command.inentityzone(x, y, Entity.type[typeName])
end

--~~~~~~~~~~~~~~~~~~--
-- Instance methods --
--~~~~~~~~~~~~~~~~~~--

---
-- Constructor.
--
-- @param x (number)
--   X tile position of the entity
-- @param y (number)
--   Y tile position of the entity
--
function Entity:constructor(x, y)
    Entity._validator:validate({
        { value = x, type = 'number' },
        { value = y, type = 'number' }
    }, 'constructor', 2)

    if not Entity._allowCreation then
        error('Instantiation of this class is not allowed.', 2)
    end

    if not _META.command.entity(x, y, 'exists') then
        error('Entity on provided position doesn\'t exist.', 2)
    end

    self._x = x
    self._y = y

    table.insert(Entity._instances, self)
end

--== Getters ==--

---
-- Returns the X position of the entity.
--
-- @return (number)
--
function Entity:getX()
    return self._x
end

---
-- Returns the Y position of the entity.
--
-- @return (number)
--
function Entity:getY()
    return self._y
end

---
-- Returns the position of the entity.
--
-- @return
--   2 values:
--     X tile position (number),
--     Y tile position (number)
--
function Entity:getPosition()
    return self._x, self._y
end

---
-- Returns the type name of the entity.
--
-- @return (string)
--
function Entity:getTypeName()
    return _META.command.entity(self._x, self._y, 'typename')
end

---
-- Returns the type ID of the entity.
--
-- @return (number)
--
function Entity:getTypeID()
    return _META.command.entity(self._x, self._y, 'type')
end

---
-- Returns the field name of the entity.
--
-- @return (string)
--
function Entity:getNameField()
    return _META.command.entity(self._x, self._y, 'name')
end

---
-- Returns the trigger field of the entity.
--
-- @return (string)
--
function Entity:getTriggerField()
    return _META.command.entity(self._x, self._y, 'trigger')
end

---
-- Returns the state of the entity (true is visible, false is invisible)
--
-- @return (boolean)
--
function Entity:getState()
    return not _META.command.entity(self._x, self._y, 'state')
end

---
-- Returns the integer setting of the entity.
--
-- @return (number)
--
function Entity:getIntegerSetting(key)
    Entity._validator:validate({
        { value = key , type = 'settingKey' }
    }, 'getIntegerSetting', 2)

    return _META.command.entity(self._x, self._y, 'int' .. key)
end

---
-- Returns the string setting of the entity.
--
-- @return (string)
--
function Entity:getStringSetting(key)
    Entity._validator:validate({
        { value = key , type = 'settingKey' }
    }, 'getStringSetting', 2)

    return _META.command.entity(self._x, self._y, 'string' .. key)
end

---
-- Returns the entity AI state.
--
-- @return (number)
--
function Entity:getAIState()
    return _META.command.entity(self._x, self._y, 'aistate')
end

--== Setters/control ==--

---
-- Sets the AI state of the entity.
--
-- @param state (number)
--   The AI state
--
function Entity:setAIState(state)
    Entity._validator:validate({
        { value = state, type = 'number' },
    }, 'setAIState', 2)

    _META.command.setentityaistate(self._x, self._y, state)
end

--~~~~~~~~~~~~~~~--
-- Static fields --
--~~~~~~~~~~~~~~~--

-- Validator.
Entity._validator = Validator()
-- Checks if the value is a correct entity type.
Entity._validator:addCustomRule('entity', function(ruleTable)
    local value = ruleTable.value
    local hasError = Entity.type[value] == nil
    local message = 'not a valid entity type'

    return hasError, message
end)
-- Checks if setting key is correct.
Entity._validator:addCustomRule('settingKey', function(ruleTable)
    local value = ruleTable.value
    local hasError = not (type(value) == 'number' and value >= 1 and value <= 9 and math.floor(value) == value)
    local message = 'value has to be in the range from 1 to 9, and with no floating point'

    return hasError, message
end)

-- Holds all the data of entities on the map.
Entity._instances = {}
-- Defines if instantiation of this class is allowed.
Entity._allowCreation = true
-- Holds types of the entities
Entity.type = _META.config.cs2dEntityTypes
for _, value in pairs(_META.command.entitylist()) do
    Entity(value.x, value.y)
end
Entity._allowCreation = false

--~~~~~~~~~~~~~~~~~~~~~--
-- Returning the class --
--~~~~~~~~~~~~~~~~~~~~~--

return Entity
