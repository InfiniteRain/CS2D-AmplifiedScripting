-- Initializing entity class.
local Entity = class()

--------------------
-- Static methods --
--------------------

-- Checks if the position has an entity.
function Entity.hasEntityOnPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	return _META.command.entity(x, y, 'exists')
end

-- Gets entity on a certain position.
function Entity.getInstance(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	for key, value in pairs(Entity._instances) do
		if value:getX() == x and value:getY() == y then
			return value
		end
	end
	
	error("Entity on provided position doesn't exist.", 2)
end

-- Gets list of the entities on the map.
function Entity.getEntities(typeName)
	if typeName then
		if type(typeName) ~= "string" then
			error("Passed \"typeName\" parameter is not valid. String expected, ".. type(typeName) .." passed.", 2)
		end
		
		if not Entity.type[typeName] then
			error("Passed \"typeName\" parameter represents a non-existent entity type.", 2)
		end
	end
	
	local entityTable = {}
	for key, value in pairs(_META.command.entitylist(typeName and Entity.type[typeName] or nil)) do
		table.insert(entityTable, Entity.getInstance(value.x, value.y))
	end
	
	return entityTable
end

-- Gets returns type name from type ID.
function Entity.getTypeNameFromID(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(Entity.type) do
		if typeID == value then
			return key
		end
	end
	
	error("Parameter \"typeID\" represents a non-valid entity type ID.", 2)
end

-- Checks if the position is in entity zone.
function Entity.isPositionInEntityZone(x, y, typeName)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(typeName) ~= "string" then
		error("Passed \"typeName\" parameter is not valid. Number expected, ".. type(typeName) .." passed.", 2)
	end
	
	if not Entity.type[typeName] then
		error("Passed \"typeName\" parameter represents a non-existent entity type.", 2)
	end
	
	return _META.command.inentityzone(x, y, Entity.type[typeName])
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function Entity:constructor(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if not Entity._allowCreation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	if not _META.command.entity(x, y, 'exists') then
		error("Entity on provided position doesn't exist.", 2)
	end
	
	self._x = x
	self._y = y
	
	table.insert(Entity._instances, self)
end

--== Getters ==--

-- Gets the X position of the entity.
function Entity:getX()
	return self._x
end

-- Gets the Y position of the entity.
function Entity:getY()
	return self._y
end

-- Gets the position of the entity.
function Entity:getPosition()
	return self._x, self._y
end

-- Gets the type name of the entity.
function Entity:getTypeName()
	return _META.command.entity(self._x, self._y, "typename")
end

-- Gets the type of the entity.
function Entity:getType()
	return _META.command.entity(self._x, self._y, "type")
end

-- Gets the field name of the entity.
function Entity:getNameField()
	return _META.command.entity(self._x, self._y, "name")
end

-- Gets the trigger field of the entity.
function Entity:getTriggerField()
	return _META.command.entity(self._x, self._y, "trigger")
end

-- Gets the state of the entity (true is visible, false is invisible)
function Entity:getState()
	return not _META.command.entity(self._x, self._y, "state")
end

-- Gets the integer setting of the entity.
function Entity:getIntegerSetting(key)
	if type(key) ~= "number" then
		error("Passed \"key\" parameter is not valid. Number expected, ".. type(key) .." passed.", 2)
	end
	
	if not (key >= 0 and key <= 9 and math.floor(key) == key) then
		error("Passed \"key\" value has to be in the range of 0 - 255 with no floating point.", 2)
	end
	
	return _META.command.entity(self._x, self._y, "int" .. key)
end

-- Gets the string setting of the entity.
function Entity:getStringSetting(key)
	if type(key) ~= "number" then
		error("Passed \"key\" parameter is not valid. Number expected, ".. type(key) .." passed.", 2)
	end
	
	if not (key >= 0 and key <= 9 and math.floor(key) == key) then
		error("Passed \"key\" value has to be in the range of 0 - 255 with no floating point.", 2)
	end
	
	return _META.command.entity(self._x, self._y, "string" .. key)
end

-- Gets the AI state.
function Entity:getAIState()
	return _META.command.entity(self._x, self._y, "aistate")
end

--== Setters/control ==--

-- Sets AI state of the entity.
function Entity:setAIState(state)
	if type(state) ~= "number" then
		error("Passed \"state\" parameter is not valid. Number expected, ".. type(state) .." passed.", 2)
	end
	
	_META.command.setentityaistate(self._x, self._y, state)
end

-------------------
-- Static fields --
-------------------

Entity._allowCreation = true -- Defines if instantiation of this class is allowed.
Entity._instances = {} -- Holds all the entities on the map.
Entity.type = _META.config.cs2dEntityTypes -- Holds types of the entities
for key, value in pairs(_META.command.entitylist()) do
	Entity.new(value.x, value.y)
end
Entity._allowCreation = false

-------------------------
-- Returning the class --
-------------------------
return Entity
