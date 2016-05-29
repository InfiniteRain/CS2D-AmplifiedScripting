-- Initializing item type class.
cas.itemType = cas.class()

--------------------
-- Static methods --
--------------------

-- Turns cs2d item type id into a cas.itemType object.
function cas.itemType.getInstance(typeID)
	if type(typeID) ~= "number" then
		error("Passed \"typeID\" parameter is not valid. Number expected, ".. type(typeID) .." passed.")
	end
	
	for key, value in pairs(cas.itemType) do
		if getmetatable(value) == cas.itemType then
			if value._typeId == typeID then
				return value
			end
		end
	end
	
	error("Passed \"typeID\" value is not valid.")
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.itemType:constructor(itemTypeID, passive, rightClickType, projectile)
	if type(itemTypeID) ~= "number" then
		error("Passed \"itemTypeID\" parameter is not valid. Number expected, ".. type(itemTypeID) .." passed.")
	elseif type(passive) ~= "boolean" then
		error("Passed \"passive\" parameter is not valid. Boolean expected, ".. type(passive) .." passed.")
	elseif type(rightClickType) ~= "string" then
		error("Passed \"rightClickType\" parameter is not valid. String expected, ".. type(rightClickType) .." passed.")
	elseif type(projectile) ~= "boolean" then
		error("Passed \"projectile\" parameter is not valid. Boolean expected, ".. type(projectile) .." passed.")
	end
	
	if not cas.itemType._allowInstantiation then
		error("Instantiation of this class is not allowed.")
	end
	
	self._typeId = itemTypeID
	self._passive = passive
	self._rightClickType = rightClickType
	self._projectile = projectile
end

-- Everything that follows is self explanatory.

function cas.itemType:getName()
	return cas._cs2dCommands.itemtype(self._typeId, "name")
end

function cas.itemType:getDamage()
	return cas._cs2dCommands.itemtype(self._typeId, "dmg")
end

function cas.itemType:getFirstScopeDamage()
	if not (self._rightClickType == "1scope" or self._rightClickType == "2scopes") then
		error("This weapon does not have first scope damage.")
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z1")
end

function cas.itemType:getSecondScopeDamage()
	if self._rightClickType ~= "2scopes" then
		error("This weapon does not have second scope damage.")
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z2")
end

function cas.itemType:getSecondaryAttackDamage()
	if self._rightClickType ~= "attack" then
		error("This weapon does not have secondary attack.")
	end
	
	return cas._cs2dCommands.itemtype(self._typeId, "dmg_z1")
end

function cas.itemType:getFireRate()
	return cas._cs2dCommands.itemtype(self._typeId, 'rate')
end

function cas.itemType:getReloadTime()
	return cas._cs2dCommands.itemtype(self._typeId, 'reload')
end

function cas.itemType:getAmmo()
	return cas._cs2dCommands.itemtype(self._typeId, 'ammo')
end

function cas.itemType:getAmmoIn()
	return cas._cs2dCommands.itemtype(self._typeId, 'ammoin')
end

function cas.itemType:getPrice()
	return cas._cs2dCommands.itemtype(self._typeId, 'price')
end

function cas.itemType:getRange()
	return cas._cs2dCommands.itemtype(self._typeId, 'range')
end

function cas.itemType:getDispersion()
	return cas._cs2dCommands.itemtype(self._typeId, 'dispersion')
end

function cas.itemType:getHUDSlot()
	return cas._cs2dCommands.itemtype(self._typeId, 'slot')
end

function cas.itemType:getRecoil()
	return cas._cs2dCommands.itemtype(self._typeId, 'recoil')
end

-------------------
-- Static fields --
-------------------

-- Gets itemTypes from the config and loads them as static fields of this class.
cas.itemType._allowInstantiation = true
for key, value in pairs(cas._config.cs2dItemTypes) do
	cas.itemType[key] = cas.itemType.new(unpack(value))
end
cas.itemType._allowInstantiation = false