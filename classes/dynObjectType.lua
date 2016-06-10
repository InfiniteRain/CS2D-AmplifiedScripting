-- Initializing dynamic object type class.
cas.dynObject.type = cas.class() -- Acts as the inner class of the dynObject class.

--------------------
-- Static methods --
--------------------

-- Turns cs2d item type id into a cas.dynObject.type object.
function cas.dynObject.type.getInstance(objectTypeID)
	if type(objectTypeID) ~= "number" then
		error("Passed \"objectTypeID\" parameter is not valid. Number expected, ".. type(objectTypeID) .." passed.", 2)
	end
	
	for key, value in pairs(cas.dynObject.type) do
		if getmetatable(value) == cas.dynObject.type then
			if value._objectTypeID == objectTypeID then
				return value
			end
		end
	end
	
	error("Passed \"objectTypeID\" value is not valid.", 2)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.dynObject.type:constructor(objectTypeID)
	if type(objectTypeID) ~= "number" then
		error("Passed \"objectTypeID\" parameter is not valid. Number expected, ".. type(objectTypeID) .." passed.", 2)
	end
	
	if not cas.dynObject.type._allowInstantiation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	self._objectTypeID = objectTypeID
end

--== Setters/control ==--

function cas.dynObject.type:spawn(...)
	if self._objectTypeID >= 1 and self._objectTypeID <= 23 then
		local x, y, mode, team, player = ...
		if type(x) ~= "number" then
			error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
		elseif type(y) ~= "number" then
			error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
		elseif type(mode) ~= "number" then
			error("Passed \"mode\" parameter is not valid. Number expected, ".. type(mode) .." passed.", 2)
		elseif type(team) ~= "number" then
			error("Passed \"team\" parameter is not valid. Number expected, ".. type(team) .." passed.", 2)
		elseif getmetatable(player) ~= cas.player then
			error("Passed \"player\" parameter is not an instance of the \"cas.player\" class.", 2)
		end
		
		cas.console.parse("spawnobject", self._objectTypeID, x, y, 0, mode, team, player)
	elseif self._objectTypeID == 30 then
		local npcType, x, y, angle = ...
		if type(npcType) ~= "string" then
			error("Passed \"npcType\" parameter is not valid. String expected, ".. type(npcType) .." passed.", 2)
		elseif type(x) ~= "number" then
			error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
		elseif type(y) ~= "number" then
			error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
		elseif type(angle) ~= "number" then
			error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.", 2)
		end
		
		if not cas.dynObject.type._npcs[npcType] then
			error("Passed \"npcType\" value does not represent a valid npc type.", 2)
		end
		
		cas.console.parse("spawnnpc", cas.dynObject.type._npcs[npcType], x, y, angle)
	elseif self._objectTypeID == 40 then
		error("Objects with the type of image cannot be spawned using this method. Use methods of \"cas.mapImage\", "
			.."\"cas.playerImage\" or \"cas.hudImage\" to spawn images.", 2)
	end
end

-------------------
-- Static fields --
-------------------

cas.dynObject.type._allowInstantiation = true
for key, value in pairs(cas._config.cs2dDynamicObjectTypes) do
	cas.dynObject.type[key] = cas.dynObject.type.new(value)
end
cas.dynObject.type._allowInstantiation = false
cas.dynObject.type._npcs = {
	["zombie"] = 1,
	["headcrab"] = 2,
	["snark"] = 3,
	["vortigaunt"] = 4,
	["soldier"] = 5
}