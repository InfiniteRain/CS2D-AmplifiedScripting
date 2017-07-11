-- Initializing dynamic object class.
local DynObject = class()

--------------------
-- Static methods --
--------------------

-- Checks if the dynamic object under the passed ID exists.
function DynObject.idExists(objectID)
	if type(objectID) ~= "number" then
		error("Passed \"objectID\" parameter is not valid. Number expected, ".. type(objectID) .." passed.", 2)
	end
	
	return _META.command.object(objectID, "exists")
end

-- Returns the dynamic object instance from the passed onject ID.
function DynObject.getInstance(dynObjectID)
	if type(dynObjectID) ~= "number" then
		error("Passed \"dynObjectID\" parameter is not valid. Number expected, ".. type(dynObjectID) .." passed.", 2)
	elseif not _META.command.object(dynObjectID, 'exists') then
		error("Passed \"dynObjectID\" parameter represents a non-existent object.", 2)
	end
	
	for key, value in pairs(DynObject._instances) do
		if value._id == dynObjectID then
			DynObject._debug:log("Dynamic object \"".. tostring(value) .."\" was found in \"_instances\" table and returned.")
			return value
		end
	end
	
	DynObject._allowCreation = true
	local dynObject = DynObject.new(dynObjectID)
	DynObject._allowCreation = false
	
	return dynObject
end

-- Returns a table of all the dynamic objects.
function DynObject.dynamicObjects()
	local dynamicObjects = {}
	for key, value in pairs(_META.command.object(0, 'table')) do
		table.insert(dynamicObjects, DynObject.getInstance(value))
	end
	
	return dynObject
end

-- Returns a dynamic object on the position.
function DynObject.getDynamicObjectAt(x, y, dynObjectType)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if dynObjectType then
		if getmetatable(dynObjectType) ~= DynObjectType then
			error("Passed \"dynObjectType\" parameter is not an instance of the \"DynObjectType\" class.", 2)
		end
	end
	
	local dynObject = _META.command.objectat(x, y, dynObjectType and dynObjectType._objectTypeID or nil)
	return dynObject ~= 0 and DynObject.getInstance(dynObject) or false
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a dynamic object instance with corresponding ID.
function DynObject:constructor(dynObjectID)
	if type(dynObjectID) ~= "number" then
		error("Passed \"dynObjectID\" parameter is not valid. Number expected, ".. type(dynObjectID) .." passed.", 2)
	elseif not _META.command.object(dynObjectID, 'exists') then
		error("Passed \"dynObjectID\" parameter represents a non-existent object.", 2)
	end
	
	if not DynObject._allowCreation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	for key, value in pairs(DynObject._instances) do
		if value._id == dynObjectID then
			error("Instance with the same object ID already exists.", 2)
		end
	end
	
	self._id = dynObjectID
	self._killed = false
	
	table.insert(DynObject._instances, self)
	
	DynObject._debug:log("Dynamic object \"".. tostring(self) .."\" was instantiated.")
end

-- Destructor
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
	
	DynObject._debug:log("Dynamic object \"".. tostring(self) .."\" was garbage collected.")
end

--== Getters ==--

-- Gets the ID of the dynamic object.
function DynObject:getID()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on "object" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function DynObject:getTypeName()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'typename')
end

function DynObject:getType()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return DynObjectType.getInstance(_META.command.object(self._id, 'type'))
end

function DynObject:getHealth()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'health')
end

function DynObject:getMode()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'mode')
end

function DynObject:getTeam()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'team')
end

function DynObject:getPlayer()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if self:getType() == 30 then
		error("This dynamic object is an npc, thus does not have an owner.", 2)
	end
	
	return _META.command.object(self._id, 'player')
end

function DynObject:getNPCType()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if self:getType() ~= 30 then
		error("This dynamic object is not an npc, thus does not have an NPC type.", 2)
	end
	
	return _META.command.object(self._id, 'player')
end

function DynObject:getPosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return
		_META.command.object(self._id, 'x'),
		_META.command.object(self._id, 'y')
end

function DynObject:getX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'x')
end

function DynObject:getY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'y')
end

function DynObject:getAngle()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'rot')
end

function DynObject:getTilePosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return
		_META.command.object(self._id, 'tilex'),
		_META.command.object(self._id, 'tiley')
end

function DynObject:getTileX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'tilex')
end

function DynObject:getTileY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'tiley')
end

function DynObject:getCountdown()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'countdown')
end

function DynObject:getOriginalAngle()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'rootrot')
end

function DynObject:getTarget()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	local target = _META.command.object(self._id, 'target')
	return target ~= 0 and Player.getInstance(target) or false
end

function DynObject:getUpgradeVal()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'upgrade')
end

function DynObject:isSpawnedByEntity()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.object(self._id, 'entity')
end

function DynObject:getSpawnEntityPosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if not DynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.", 2)
	end
	
	return
		_META.command.object(self._id, 'entityx'),
		_META.command.object(self._id, 'entityy')
end

function DynObject:getSpawnEntityX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if not DynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.", 2)
	end
	
	return _META.command.object(self._id, 'entityx')
end

function DynObject:getSpawnEntityY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if not DynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.", 2)
	end
	
	return _META.command.object(self._id, 'entityy')
end

--== Setters/control ==--

function DynObject:damage(damage, player)
	if type(damage) ~= "number" then
		error("Passed \"damage\" parameter is not valid. Number expected, ".. type(damage) .." passed.", 2)
	end
	if player then
		if getmetatable(player) ~= Player then
			error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
		end
	end
	
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if self:getType() == DynObjectType.image then
		error("This object is an image, thus it cannot be damaged.", 2)
	end
	
	local player = player or 0
	
	Console.parse("damageobject", self._id, damage, player)
end

function DynObject:kill()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.", 2)
	end
	
	if self:getType() == DynObjectType.image then
		Image.getInstance(self._id):free()
	else
		Console.parse("killobject", self._id)
	end
end

-------------------
-- Static fields --
-------------------

DynObject._allowCreation = false -- Defines if instantiation of this class is allowed.
DynObject._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.
DynObject._debug = Debug.new(Color.yellow, "CAS Dynamic Object") -- Debug for dynamic objects.
DynObject._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return DynObject
