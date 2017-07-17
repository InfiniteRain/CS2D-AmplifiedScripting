-- Initializing dynamic object type class.
local DynObjectType = class() -- Acts as the inner class of the dynObject class.

--------------------
-- Static methods --
--------------------

-- Turns cs2d item type id into a DynObjectType object.
function DynObjectType.getInstance(objectTypeID)
  if type(objectTypeID) ~= 'number' then
    error('Passed "objectTypeID" parameter is not valid. Number expected, ' .. type(objectTypeID) .. ' passed.', 2)
  end

  for key, value in pairs(DynObjectType) do
    if getmetatable(value) == DynObjectType then
      if value._objectTypeID == objectTypeID then
        return value
      end
    end
  end

  error('Passed "objectTypeID" value is not valid.', 2)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function DynObjectType:constructor(objectTypeID)
  if type(objectTypeID) ~= 'number' then
    error('Passed "objectTypeID" parameter is not valid. Number expected, ' .. type(objectTypeID) .. ' passed.', 2)
  end

  if not DynObjectType._allowInstantiation then
    error('Instantiation of this class is not allowed.', 2)
  end

  self._objectTypeID = objectTypeID
end

--== Setters/control ==--

function DynObjectType:spawn(...)
  if self._objectTypeID >= 1 and self._objectTypeID <= 23 then
    local x, y, mode, team, player = ...
    if type(x) ~= 'number' then
      error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
    elseif type(y) ~= 'number' then
      error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
    elseif type(mode) ~= 'number' then
      error('Passed "mode" parameter is not valid. Number expected, ' .. type(mode) .. ' passed.', 2)
    elseif type(team) ~= 'number' then
      error('Passed "team" parameter is not valid. Number expected, ' .. type(team) .. ' passed.', 2)
    elseif getmetatable(player) ~= Player and player ~= false then
      error('Passed "player" parameter is not valid. False or instance of "Player" expected.', 2)
    end

    Console.parse('spawnobject', self._objectTypeID, x, y, 0, mode, team, player and player or 0)
  elseif self._objectTypeID == 30 then
    local npcType, x, y, angle = ...
    if type(npcType) ~= 'string' then
      error('Passed "npcType" parameter is not valid. String expected, ' .. type(npcType) .. ' passed.', 2)
    elseif type(x) ~= 'number' then
      error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
    elseif type(y) ~= 'number' then
      error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
    elseif type(angle) ~= 'number' then
      error('Passed "angle" parameter is not valid. Number expected, ' .. type(angle) .. ' passed.', 2)
    end

    if not DynObjectType._npcs[npcType] then
      error('Passed "npcType" value does not represent a valid npc type.', 2)
    end

    Console.parse('spawnnpc', DynObjectType._npcs[npcType], x, y, angle)
  elseif self._objectTypeID == 40 then
    error('Objects with the type of image cannot be spawned using this method. Use methods of "MapImage", '
        .. '"PlayerImage" or "HudImage" to spawn images.', 2)
  end
end

-------------------
-- Static fields --
-------------------

DynObjectType._allowInstantiation = true
for key, value in pairs(_META.config.cs2dDynamicObjectTypes) do
  DynObjectType[key] = DynObjectType(value)
end
DynObjectType._allowInstantiation = false
DynObjectType._npcs = {
  ['zombie'] = 1,
  ['headcrab'] = 2,
  ['snark'] = 3,
  ['vortigaunt'] = 4,
  ['soldier'] = 5
}

-------------------------
-- Returning the class --
-------------------------
return DynObjectType
