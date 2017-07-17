-- Initializing dynamic object class.
local DynObject = class()

--------------------
-- Static methods --
--------------------

-- Checks if the dynamic object under the passed ID exists.
function DynObject.idExists(dynObjectID)
  DynObject._validator:validate({
    { value = dynObjectID, type = 'number' }
  }, 'idExists', 2)

  return _META.command.object(dynObjectID, 'exists')
end

-- Returns the dynamic object instance from the passed onject ID.
function DynObject.getInstance(dynObjectID)
  DynObject._validator:validate({
    { value = dynObjectID, type = 'number' }
  }, 'getInstance', 2)

  if not _META.command.object(dynObjectID, 'exists') then
    error('Dynamic object with the passed ID was not fund.', 2)
  end

  for key, value in pairs(DynObject._instances) do
    if value._id == dynObjectID then
      DynObject._debug:log('Dynamic object "' .. tostring(value) .. '" was ' ..
          'found in "_instances" table and returned.')
      return value
    end
  end

  DynObject._allowCreation = true
  local dynObject = DynObject(dynObjectID)
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
  DynObject._validator:validate({
    { value = x, type = 'number' },
    { value = y, type = 'number' },
    { value = dynObjectType, type = DynObjectType, optional = true }
  }, 'getDynamicObjectAt', 2)

  local dynObject = _META.command.objectat(x, y, dynObjectType and dynObjectType._objectTypeID or nil)
  print(dynObject)
  return dynObject ~= 0 and DynObject.getInstance(dynObject) or false
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a dynamic object instance with corresponding ID.
function DynObject:constructor(dynObjectID)
  DynObject._validator:validate({
    { value = dynObjectID, type = 'constructor' }
  }, 'constructor', 2)

  if not _META.command.object(dynObjectID, 'exists') then
    error('Dynamic object with the passed ID was not fund.', 2)
  end

  for key, value in pairs(DynObject._instances) do
    if value._id == dynObjectID then
      error('Instance with the same object ID already exists.', 2)
    end
  end

  self._id = dynObjectID
  self._killed = false

  table.insert(DynObject._instances, self)

  DynObject._debug:log('Dynamic object "' .. tostring(self) .. '" was ' ..
      'instantiated.')
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

  DynObject._debug:log('Dynamic object "' .. tostring(self) .. '" was ' ..
      'garbage collected.')
end

-- Raises an error if the object is need of being disposed.
function DynObject:errorIfNeedsDisposing()
  if self._killed then
    error('The dynamic object of this instance was already killed. ' ..
        'It\'s better to dispose of this instance.', 2)
  end
end

--== Getters ==--

-- Gets the ID of the dynamic object.
function DynObject:getID()
  self:errorIfNeedsDisposing()

  return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on 'object' function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function DynObject:getTypeName()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'typename')
end

function DynObject:getType()
  self:errorIfNeedsDisposing()

  return DynObjectType.getInstance(_META.command.object(self._id, 'type'))
end

function DynObject:getHealth()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'health')
end

function DynObject:getMode()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'mode')
end

function DynObject:getTeam()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'team')
end

function DynObject:getPlayer()
  self:errorIfNeedsDisposing()

  if self:getType() == 30 then
    error('This dynamic object is an npc, thus does not have an owner.', 2)
  end

  return _META.command.object(self._id, 'player')
end

function DynObject:getNPCType()
  self:errorIfNeedsDisposing()

  if self:getType() ~= 30 then
    error('This dynamic object is not an npc, thus does not have an NPC type.',
      2)
  end

  return _META.command.object(self._id, 'player')
end

function DynObject:getPosition()
  self:errorIfNeedsDisposing()

  return
  _META.command.object(self._id, 'x'),
  _META.command.object(self._id, 'y')
end

function DynObject:getX()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'x')
end

function DynObject:getY()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'y')
end

function DynObject:getAngle()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'rot')
end

function DynObject:getTilePosition()
  self:errorIfNeedsDisposing()

  return
  _META.command.object(self._id, 'tilex'),
  _META.command.object(self._id, 'tiley')
end

function DynObject:getTileX()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'tilex')
end

function DynObject:getTileY()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'tiley')
end

function DynObject:getCountdown()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'countdown')
end

function DynObject:getOriginalAngle()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'rootrot')
end

function DynObject:getTarget()
  self:errorIfNeedsDisposing()

  local target = _META.command.object(self._id, 'target')
  return target ~= 0 and Player.getInstance(target) or false
end

function DynObject:getUpgradeVal()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'upgrade')
end

function DynObject:isSpawnedByEntity()
  self:errorIfNeedsDisposing()

  return _META.command.object(self._id, 'entity')
end

function DynObject:getSpawnEntityPosition()
  self:errorIfNeedsDisposing()

  if not DynObject:isSpawnedByEntity() then
    error('This dynamic object wasn\'t spawned by an entity.', 2)
  end

  return
     _META.command.object(self._id, 'entityx'),
     _META.command.object(self._id, 'entityy')
end

function DynObject:getSpawnEntityX()
  self:errorIfNeedsDisposing()

  if not DynObject:isSpawnedByEntity() then
    error('This dynamic object wasn\'t spawned by an entity.', 2)
  end

  return _META.command.object(self._id, 'entityx')
end

function DynObject:getSpawnEntityY()
  self:errorIfNeedsDisposing()

  if not DynObject:isSpawnedByEntity() then
    error('This dynamic object wasn\'t spawned by an entity.', 2)
  end

  return _META.command.object(self._id, 'entityy')
end

--== Setters/control ==--

function DynObject:damage(damage, player)
  DynObject._validator:validate({
    { value = damage, type = 'number' },
    { value = player, type = Player, optional = true }
  }, 'damage', 2)

  self:errorIfNeedsDisposing()

  if self:getType() == DynObjectType.image then
    error('This object is an image, thus it cannot be damaged.', 2)
  end

  local player = player or 0

  Console.parse('damageobject', self._id, damage, player)
end

function DynObject:kill()
  self:errorIfNeedsDisposing()

  if self:getType() == DynObjectType.image then
    Image.getInstance(self._id):free()
  else
    Console.parse('killobject', self._id)
  end
  self._killed = true;
end

-------------------
-- Static fields --
-------------------

-- Validator for argument validation.
DynObject._validator = Validator()

-- Defines if instantiation of this class is allowed.
DynObject._allowCreation = false
-- A table of instances of this class.
DynObject._instances = setmetatable({}, { __mode = 'kv' })
-- Debug for dynamic objects.
DynObject._debug = Debug(Color.yellow, 'CAS Dynamic Object')
DynObject._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return DynObject
