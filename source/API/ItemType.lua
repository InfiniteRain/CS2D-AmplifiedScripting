-- Initializing item type class.
local ItemType = class() 

--------------------
-- Static methods --
--------------------

-- Checks if the item under the passed type ID exists.
function ItemType.typeExists(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(ItemType) do
		if getmetatable(value) == ItemType then
			if value._typeId == typeID then
				return true
			end
		end
	end
	
	return false
end

-- Turns cs2d item type id into a ItemType object.
function ItemType.getInstance(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(ItemType) do
		if getmetatable(value) == ItemType then
			if value._typeId == typeID then
				return value
			end
		end
	end
	
	error("Passed \"typeID\" value is not valid.", 2)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function ItemType:constructor(itemTypeID, passive, rightClickType, projectile)
	if type(itemTypeID) ~= "number" then
		error("Passed \"itemTypeID\" parameter is not valid. Number expected, ".. type(itemTypeID) .." passed.", 2)
	elseif type(passive) ~= "boolean" then
		error("Passed \"passive\" parameter is not valid. Boolean expected, ".. type(passive) .." passed.", 2)
	elseif type(rightClickType) ~= "string" then
		error("Passed \"rightClickType\" parameter is not valid. String expected, ".. type(rightClickType) .." passed.", 2)
	elseif type(projectile) ~= "boolean" then
		error("Passed \"projectile\" parameter is not valid. Boolean expected, ".. type(projectile) .." passed.", 2)
	end
	
	if not ItemType._allowInstantiation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	self._typeId = itemTypeID
	self._passive = passive
	self._rightClickType = rightClickType
	self._projectile = projectile
end

-- Everything that follows is self explanatory.

--== Getters ==--

function ItemType:getType()
	return self._typeId
end

function ItemType:getName()
	return _META.command.itemtype(self._typeId, "name")
end

function ItemType:getDamage()
	return _META.command.itemtype(self._typeId, "dmg")
end

function ItemType:getFirstScopeDamage()
	if not (self._rightClickType == "1scope" or self._rightClickType == "2scopes") then
		error("This weapon does not have first scope damage.", 2)
	end
	
	return _META.command.itemtype(self._typeId, "dmg_z1")
end

function ItemType:getSecondScopeDamage()
	if self._rightClickType ~= "2scopes" then
		error("This weapon does not have second scope damage.", 2)
	end
	
	return _META.command.itemtype(self._typeId, "dmg_z2")
end

function ItemType:getSecondaryAttackDamage()
	if self._rightClickType ~= "attack" then
		error("This weapon does not have secondary attack.", 2)
	end
	
	return _META.command.itemtype(self._typeId, "dmg_z1")
end

function ItemType:getFireRate()
	return _META.command.itemtype(self._typeId, 'rate')
end

function ItemType:getReloadTime()
	return _META.command.itemtype(self._typeId, 'reload')
end

function ItemType:getAmmo()
	return _META.command.itemtype(self._typeId, 'ammo')
end

function ItemType:getAmmoIn()
	return _META.command.itemtype(self._typeId, 'ammoin')
end

function ItemType:getPrice()
	return _META.command.itemtype(self._typeId, 'price')
end

function ItemType:getRange()
	return _META.command.itemtype(self._typeId, 'range')
end

function ItemType:getDispersion()
	return _META.command.itemtype(self._typeId, 'dispersion')
end

function ItemType:getHUDSlot()
	return _META.command.itemtype(self._typeId, 'slot')
end

function ItemType:getRecoil()
	return _META.command.itemtype(self._typeId, 'recoil')
end

--== Setters/control ==--

function ItemType:spawn(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	if not (x >= 0 and y >= 0 and x <= map("xsize") and y <= map("ysize")) then
		error("Position is out of map bounds!", 2)
	end
	
	Console.parse("spawnitem", self._typeId, x, y)
end

function ItemType:spawnProjectile(player, x, y, flyDistance, angle)
	if getmetatable(player) ~= Player then
		error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(flyDistance) ~= "number" then
		error("Passed \"flyDistance\" parameter is not valid. Number expected, ".. type(flyDistance) .." passed.", 2)
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.", 2)
	end
	
	Console.parse("spawnprojectile", player._id, self._typeId, x, y, flyDistance, angle)
end

-------------------
-- Static fields --
-------------------

-- Gets item types loads them as static fields of this class.
ItemType._allowInstantiation = true
for key, value in pairs(_META.config.cs2dItemTypes) do
	ItemType[key] = ItemType.new(unpack(value))
end
ItemType._allowInstantiation = false

-------------------------
-- Returning the class --
-------------------------
return ItemType
