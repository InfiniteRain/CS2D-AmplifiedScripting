-- Initializing entity class.
cas.entity = cas.class()

--------------------
-- Static methods --
--------------------

-- Checks if the position has an entity.
function cas.entity.hasEntityOnPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	return cas._cs2dCommands.entity(x, y, 'exists')
end

-- Gets entity on a certain position.
function cas.entity.getInstance(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	for key, value in pairs(cas.entity._instances) do
		if value:getX() == x and value:getY() == y then
			return value
		end
	end
	
	error("Entity on provided position doesn't exist.", 2)
end

-- Gets list of the entities on the map.
function cas.entity.getEntities(typeName)
	if typeName then
		if type(typeName) ~= "string" then
			error("Passed \"typeName\" parameter is not valid. String expected, ".. type(typeName) .." passed.", 2)
		end
		
		if not cas.entity.type[typeName] then
			error("Passed \"typeName\" parameter represents a non-existent entity type.", 2)
		end
	end
	
	local entityTable = {}
	for key, value in pairs(cas._cs2dCommands.entitylist(typeName and cas.entity.type[typeName] or nil)) do
		table.insert(entityTable, cas.entity.getInstance(value.x, value.y))
	end
	
	return entityTable
end

-- Gets returns type name from type ID.
function cas.entity.getTypeNameFromID(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(cas.entity.type) do
		if typeID == value then
			return key
		end
	end
	
	error("Parameter \"typeID\" represents a non-valid entity type ID.", 2)
end

-- Checks if the position is in entity zone.
function cas.entity.isPositionInEntityZone(x, y, typeName)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(typeName) ~= "string" then
		error("Passed \"typeName\" parameter is not valid. Number expected, ".. type(typeName) .." passed.", 2)
	end
	
	if not cas.entity.type[typeName] then
		error("Passed \"typeName\" parameter represents a non-existent entity type.", 2)
	end
	
	return cas._cs2dCommands.inentityzone(x, y, cas.entity.type[typeName])
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.entity:constructor(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if not cas.entity._allowCreation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	if not cas._cs2dCommands.entity(x, y, 'exists') then
		error("Entity on provided position doesn't exist.", 2)
	end
	
	self._x = x
	self._y = y
	
	table.insert(cas.entity._instances, self)
end

--== Getters ==--

-- Gets the X position of the entity.
function cas.entity:getX()
	return self._x
end

-- Gets the Y position of the entity.
function cas.entity:getY()
	return self._y
end

-- Gets the position of the entity.
function cas.entity:getPosition()
	return self._x, self._y
end

-- Gets the type name of the entity.
function cas.entity:getTypeName()
	return cas._cs2dCommands.entity(self._x, self._y, "typename")
end

-- Gets the type of the entity.
function cas.entity:getType()
	return cas._cs2dCommands.entity(self._x, self._y, "type")
end

-- Gets the field name of the entity.
function cas.entity:getNameField()
	return cas._cs2dCommands.entity(self._x, self._y, "name")
end

-- Gets the trigger field of the entity.
function cas.entity:getTriggerField()
	return cas._cs2dCommands.entity(self._x, self._y, "trigger")
end

-- Gets the state of the entity (true is visible, false is invisible)
function cas.entity:getState()
	return not cas._cs2dCommands.entity(self._x, self._y, "state")
end

-- Gets the integer setting of the entity.
function cas.entity:getIntegerSetting(key)
	if type(key) ~= "number" then
		error("Passed \"key\" parameter is not valid. Number expected, ".. type(key) .." passed.", 2)
	end
	
	if not (key >= 0 and key <= 9 and math.floor(key) == key) then
		error("Passed \"key\" value has to be in the range of 0 - 255 with no floating point.", 2)
	end
	
	return cas._cs2dCommands.entity(self._x, self._y, "int" .. key)
end

-- Gets the string setting of the entity.
function cas.entity:getStringSetting(key)
	if type(key) ~= "number" then
		error("Passed \"key\" parameter is not valid. Number expected, ".. type(key) .." passed.", 2)
	end
	
	if not (key >= 0 and key <= 9 and math.floor(key) == key) then
		error("Passed \"key\" value has to be in the range of 0 - 255 with no floating point.", 2)
	end
	
	return cas._cs2dCommands.entity(self._x, self._y, "string" .. key)
end

-- Gets the AI state.
function cas.entity:getAIState()
	return cas._cs2dCommands.entity(self._x, self._y, "aistate")
end

--== Setters/control ==--

-- Sets AI state of the entity.
function cas.entity:setAIState(state)
	if type(state) ~= "number" then
		error("Passed \"state\" parameter is not valid. Number expected, ".. type(state) .." passed.", 2)
	end
	
	cas._cs2dCommands.setentityaistate(self._x, self._y, state)
end

-------------------
-- Static fields --
-------------------

cas.entity._allowCreation = true -- Defines if instantiation of this class is allowed.
cas.entity._instances = {} -- Holds all the entities on the map.
cas.entity.type = cas._config.cs2dEntityTypes -- Holds types of the entities
for key, value in pairs(cas._cs2dCommands.entitylist()) do
	cas.entity.new(value.x, value.y)
end
cas.entity._allowCreation = false