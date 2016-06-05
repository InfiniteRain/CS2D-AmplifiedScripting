-- Initializing item type class.
cas.item.type = cas.class() -- Acts as the inner class of the item class.

--------------------
-- Static methods --
--------------------

-- Checks if the item under the passed type ID exists.
function cas.item.type.typeExists(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(cas.item.type) do
		if getmetatable(value) == cas.item.type then
			if value._typeId == typeID then
				return true
			end
		end
	end
	
	return false
end

-- Turns cs2d item type id into a cas.item.type object.
function cas.item.type.getInstance(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.", 2)
	end
	
	for key, value in pairs(cas.item.type) do
		if getmetatable(value) == cas.item.type then
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
function cas.item.type:constructor(itemTypeID, passive, rightClickType, projectile)
	if type(itemTypeID) ~= "number" then
		error("Passed \"itemTypeID\" parameter is not valid. Number expected, ".. type(itemTypeID) .." passed.", 2)
	elseif type(passive) ~= "boolean" then
		error("Passed \"passive\" parameter is not valid. Boolean expected, ".. type(passive) .." passed.", 2)
	elseif type(rightClickType) ~= "string" then
		error("Passed \"rightClickType\" parameter is not valid. String expected, ".. type(rightClickType) .." passed.", 2)
	elseif type(projectile) ~= "boolean" then
		error("Passed \"projectile\" parameter is not valid. Boolean expected, ".. type(projectile) .." passed.", 2)
	end
	
	if not cas.item.type._allowInstantiation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	self._typeId = itemTypeID
	self._passive = passive
	self._rightClickType = rightClickType
	self._projectile = projectile
end

-- Everything that follows is self explanatory.

--== Getters ==--

function cas.item.type:getName()
	return cas._cs2dCommands.itemtype(self._typeId, "name")
end

function cas.item.type:getDamage()
	return cas._cs2dCommands.itemtype(self._typeId, "dmg")
end

function cas.item.type:getFirstScopeDamage()
	if not (self._rightClickType == "1scope" or self._rightClickType == "2scopes") then
		error("This weapon does not have first scope damage.", 2)
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z1")
end

function cas.item.type:getSecondScopeDamage()
	if self._rightClickType ~= "2scopes" then
		error("This weapon does not have second scope damage.", 2)
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z2")
end

function cas.item.type:getSecondaryAttackDamage()
	if self._rightClickType ~= "attack" then
		error("This weapon does not have secondary attack.", 2)
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z1")
end

function cas.item.type:getFireRate()
	return cas._cs2dCommands.itemtype(self._typeId, 'rate')
end

function cas.item.type:getReloadTime()
	return cas._cs2dCommands.itemtype(self._typeId, 'reload')
end

function cas.item.type:getAmmo()
	return cas._cs2dCommands.itemtype(self._typeId, 'ammo')
end

function cas.item.type:getAmmoIn()
	return cas._cs2dCommands.itemtype(self._typeId, 'ammoin')
end

function cas.item.type:getPrice()
	return cas._cs2dCommands.itemtype(self._typeId, 'price')
end

function cas.item.type:getRange()
	return cas._cs2dCommands.itemtype(self._typeId, 'range')
end

function cas.item.type:getDispersion()
	return cas._cs2dCommands.itemtype(self._typeId, 'dispersion')
end

function cas.item.type:getHUDSlot()
	return cas._cs2dCommands.itemtype(self._typeId, 'slot')
end

function cas.item.type:getRecoil()
	return cas._cs2dCommands.itemtype(self._typeId, 'recoil')
end

--== Setters/control ==--

function cas.item.type:spawn(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	if not (x >= 0 and y >= 0 and x <= map("xsize") and y <= map("ysize")) then
		error("Position is out of map bounds!", 2)
	end
	
	cas.console.parse("spawnitem", self._typeId, x, y)
end

-------------------
-- Static fields --
-------------------

-- Gets item types from the config and loads them as static fields of this class.
cas.item.type._allowInstantiation = true
for key, value in pairs(cas._config.cs2dItemTypes) do
	cas.item.type[key] = cas.item.type.new(unpack(value))
end
cas.item.type._allowInstantiation = false