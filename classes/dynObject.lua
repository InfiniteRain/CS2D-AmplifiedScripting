-- Initializing dynamic object class.
cas.dynObject = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the dynamic object instance from the passed onject ID.
function cas.dynObject.getInstance(dynObjectID)
	if type(dynObjectID) ~= "number" then
		error("Passed \"dynObjectID\" parameter is not valid. Number expected, ".. type(dynObjectID) .." passed.")
	elseif not cas._cs2dCommands.object(dynObjectID, 'exists') then
		error("Passed \"dynObjectID\" parameter represents a non-existent object.")
	end
	
	for key, value in pairs(cas.dynObject._instances) do
		if value._id == dynObjectID then
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
	table.insert(cas.dynObject._instances, self)
end

function cas.dynObject:destructor()
	for key, value in pairs(cas.dynObject._instances) do
		if value._id == self._id then
			-- Removes the dynamic object from the cas.dynObject._instances table.
			cas.dynObject._instances[key] = nil
		end
	end
end

--== Getters ==--

-- Gets the ID of the dynamic object.
function cas.dynObject:getID()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on "object" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cas.dynObject:exists()
	return cas._cs2dCommands.object(self._id, 'exists')
end

function cas.dynObject:getTypeName()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'typename')
end

function cas.dynObject:getType()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'type')
end

function cas.dynObject:getHealth()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'health')
end

function cas.dynObject:getMode()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'mode')
end

function cas.dynObject:getTeam()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'team')
end

function cas.dynObject:getPlayer()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	if self:getType() == 30 then
		error("This dynamic object is an npc, thus does not have an owner.")
	end
	
	return cas._cs2dCommands.object(self._id, 'player')
end

function cas.dynObject:getNPCType()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	if self:getType() ~= 30 then
		error("This dynamic object is not an npc, thus does not have an NPC type.")
	end
	
	return cas._cs2dCommands.object(self._id, 'player')
end

function cas.dynObject:getPosition()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'x'),
		cas._cs2dCommands.object(self._id, 'y')
end

function cas.dynObject:getX()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'x')
end

function cas.dynObject:getY()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'y')
end

function cas.dynObject:getAngle()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'rot')
end

function cas.dynObject:getTilePosition()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'tilex'),
		cas._cs2dCommands.object(self._id, 'tiley')
end

function cas.dynObject:getTileX()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'tilex')
end

function cas.dynObject:getTileY()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'tiley')
end

function cas.dynObject:getCountdown()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'countdown')
end

function cas.dynObject:getOriginalAngle()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'rootrot')
end

function cas.dynObject:getTarget()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	local target = cas._cs2dCommands.object(self._id, 'target')
	return target ~= 0 and cas.player.getInstance(target) or false
end

function cas.dynObject:getUpgradeVal()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'upgrade')
end

function cas.dynObject:isSpawnedByEntity()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entity')
end

function cas.dynObject:getSpawnEntityPosition()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return
		cas._cs2dCommands.object(self._id, 'entityx'),
		cas._cs2dCommands.object(self._id, 'entityy')
end

function cas.dynObject:getSpawnEntityX()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entityx')
end

function cas.dynObject:getSpawnEntityY()
	if not self:exists() then
		error("Dynamic object of this instance doesn't exist.")
	end
	
	if not cas.dynObject:isSpawnedByEntity() then
		error("This dynamic object wasn't spawned by an entity.")
	end
	
	return cas._cs2dCommands.object(self._id, 'entityy')
end

-------------------
-- Static fields --
-------------------

cas.dynObject._allowCreation = false
cas.dynObject._instances = setmetatable({}, {__mode = "kv"})