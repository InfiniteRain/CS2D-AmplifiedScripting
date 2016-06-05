-- Initializing dynamic object class.
cas.dynObject = cas.class()

--------------------
-- Static methods --
--------------------

-- Checks if the dynamic object under the passed ID exists.
function cas.dynObject.idExists(objectID)
	if type(objectID) ~= "number" then
		error("Passed \"objectID\" parameter is not valid. Number expected, ".. type(objectID) .." passed.")
	end
	
	return cas._cs2dCommands.object(objectID, "exists")
end

-- Returns the dynamic object instance from the passed onject ID.
function cas.dynObject.getInstance(dynObjectID)
	if type(dynObjectID) ~= "number" then
		error("Passed \"dynObjectID\" parameter is not valid. Number expected, ".. type(dynObjectID) .." passed.")
	elseif not cas._cs2dCommands.object(dynObjectID, 'exists') then
		error("Passed \"dynObjectID\" parameter represents a non-existent object.")
	end
	
	for key, value in pairs(cas.dynObject._instances) do
		if value._id == dynObjectID then
			cas.dynObject._debug:log("Dynamic object \"".. tostring(value) .."\" was found in \"_instances\" table and returned.")
			return value
		end
	end
	
	cas.dynObject._allowCreation = true
	local dynObject = cas.dynObject.new(dynObjectID)
	cas.dynObject._allowCreation = false
	
	return dynObject
end

-- Returns a table of all the dynamic objects.
function cas.dynObject.dynamicObjects()
	local dynamicObjects = {}
	for key, value in pairs(cas._cs2dCommands.object(0, 'table')) do
		table.insert(dynamicObjects, cas.dynObject.getInstance(value))
	end
	
	return dynObject
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a dynamic object instance with corresponding ID.
function cas.dynObject:constructor(dynObjectID)
	if type(dynObjectID) ~= "number" then
		error("Passed \"dynObjectID\" parameter is not valid. Number expected, ".. type(dynObjectID) .." passed.")
	elseif not cas._cs2dCommands.object(dynObjectID, 'exists') then
		error("Passed \"dynObjectID\" parameter represents a non-existent object.")
	end
	
	if not cas.dynObject._allowCreation then
		error("Instantiation of this class is not allowed.")
	end
	
	for key, value in pairs(cas.dynObject._instances) do
		if value._id == dynObjectID then
			error("Instance with the same object ID already exists.")
		end
	end
	
	self._id = dynObjectID
	self._killed = false
	
	table.insert(cas.dynObject._instances, self)
	
	cas.dynObject._debug:log("Dynamic object \"".. tostring(self) .."\" was instantiated.")
end

-- Destructor
function cas.dynObject:destructor()
	if not self._killed then
		self._killed = true
	end
	
	for key, value in pairs(cas.dynObject._instances) do
		if value._id == self._id then
			-- Removes the dynamic object from the cas.dynObject._instances table.
			cas.dynObject._instances[key] = nil
		end
	end
	
	cas.dynObject._debug:log("Dynamic object \"".. tostring(self) .."\" was garbage collected.")
end

--== Getters ==--

-- Gets the ID of the dynamic object.
function cas.dynObject:getID()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on "object" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cas.dynObject:getTypeName()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'typename')
end

function cas.dynObject:getType()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'type')
end

function cas.dynObject:getHealth()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'health')
end

function cas.dynObject:getMode()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'mode')
end

function cas.dynObject:getTeam()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'team')
end

function cas.dynObject:getPlayer()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	if self:getType() == 30 then
		error("This dynamic object is an npc, thus does not have an owner.")
	end
	
	return cas._cs2dCommands.object(self._id, 'player')
end

function cas.dynObject:getNPCType()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	if self:getType() ~= 30 then
		error("This dynamic object is not an npc, thus does not have an NPC type.")
	end
	
	return cas._cs2dCommands.object(self._id, 'player')
end

function cas.dynObject:getPosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'x'),
		cas._cs2dCommands.object(self._id, 'y')
end

function cas.dynObject:getX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'x')
end

function cas.dynObject:getY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'y')
end

function cas.dynObject:getAngle()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'rot')
end

function cas.dynObject:getTilePosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'tilex'),
		cas._cs2dCommands.object(self._id, 'tiley')
end

function cas.dynObject:getTileX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'tilex')
end

function cas.dynObject:getTileY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'tiley')
end

function cas.dynObject:getCountdown()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'countdown')
end

function cas.dynObject:getOriginalAngle()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'rootrot')
end

function cas.dynObject:getTarget()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	local target = cas._cs2dCommands.object(self._id, 'target')
	return target ~= 0 and cas.player.getInstance(target) or false
end

function cas.dynObject:getUpgradeVal()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'upgrade')
end

function cas.dynObject:isSpawnedByEntity()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entity')
end

function cas.dynObject:getSpawnEntityPosition()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'entityx'),
		cas._cs2dCommands.object(self._id, 'entityy')
end

function cas.dynObject:getSpawnEntityX()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entityx')
end

function cas.dynObject:getSpawnEntityY()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entityy')
end

--== Setters/control ==--

function cas.dynObject:damage(damage, player)
	if type(damage) ~= "number" then
		error("Passed \"damage\" parameter is not valid. Number expected, ".. type(damage) .." passed.")
	end
	if player then
		if getmetatable(player) ~= cas.player then
			error("Passed \"player\" parameter is not an instance of the \"cas.player\" class.")
		end
	end
	
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	local player = player or 0
	
	cas.console.parse("damageobject", self._id, damage, player)
end

function cas.dynObject:kill()
	if self._killed then
		error("The dynamic object of this instance was already killed. It's better if you dispose of this instance.")
	end
	
	cas.console.parse("killobject", self._id)
end

-------------------
-- Static fields --
-------------------

cas.dynObject._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.dynObject._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.
cas.dynObject._debug = cas.debug.new(cas.color.yellow, "CAS Dynamic Object") -- Debug for dynamic objects.
cas.dynObject._debug:setActive(true)