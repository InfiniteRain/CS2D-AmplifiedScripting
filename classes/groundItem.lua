-- Initializing the ground item class.
cas.groundItem = cas.class()

--------------------
-- Static methods --
--------------------

-- Checks if the item under the passed ID exists.
function cas.groundItem.idExists(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.")
	end
	
	return cas._cs2dCommands.item(itemID, "exists")
end

-- Returns the ground item instance from the passed item ID.
function cas.groundItem.getInstance(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.")
	elseif not cas._cs2dCommands.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.")
	end
	
	for key, value in pairs(cas.groundItem._instances) do
		if value._id == itemID then
			return value
		end
	end
	
	cas.groundItem._allowCreation = true
	local groundItem = cas.groundItem.new(itemID)
	cas.groundItem._allowCreation = false
	
	return groundItem
end

function cas.groundItem.getGroundItems()
	local groundItems = {}
	for key, value in pairs(cas._cs2dCommands.item(0, "table")) do
		table.insert(groundItems, cas.groundItem.getInstance(value))
	end
	
	return groundItems
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a item instance with corresponding ID.
function cas.groundItem:constructor(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.")
	elseif not cas._cs2dCommands.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.")
	end
	
	if not cas.groundItem._allowCreation then
		error("Instantiation of this class is not allowed.")
	end
	
	for key, value in pairs(cas.groundItem._instances) do
		if value._id == itemID then
			error("Instance with the same item ID already exists.")
		end
	end
	
	self._id = itemID
	table.insert(cas.groundItem._instances, self)
end

-- Destructor.
function cas.groundItem:destructor()
	for key, value in pairs(cas.groundItem._instances) do
		if value._id == self._id then
			-- Removes the item from the cas.groundItem._instances table.
			cas.groundItem._instances[key] = nil
		end
	end
end

--== Getters ==--

-- Gets the item ID of the item.
function cas.groundItem:getItemID()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Everything else is self explanatory, I based it on "item" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cas.groundItem:exists()
	return cas._cs2dCommands.item(self._id, "exists")
end

function cas.groundItem:getName()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "name")
end

function cas.groundItem:getType()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas.itemType.getInstance(cas._cs2dCommands.item(self._id, "type"))
end

function cas.groundItem:getPlayer()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	local player = cas._cs2dCommands.item(self._id, "player")
	return (player ~= 0 and player or false)
end

function cas.groundItem:getAmmo()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "ammo")
end

function cas.groundItem:getAmmoin()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "ammoin")
end

function cas.groundItem:getMode()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "mode")
end

function cas.groundItem:getPosition()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return 
		cas._cs2dCommands.item(self._id, "x"),
		cas._cs2dCommands.item(self._id, "y")
end

function cas.groundItem:getX()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "x")
end

function cas.groundItem:getY()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "y")
end

function cas.groundItem:isDropped()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "dropped")
end

function cas.groundItem:getDropTimer()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.item(self._id, "droptimer")
end

--== Setters/control ==--

function cas.groundItem:remove()
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	cas.console.parse("removeitem", self._id)
end

function cas.groundItem:setAmmo(ammoin, ammo)
	if not ((type(ammoin) == "boolean" and not ammoin) or (type(ammoin) == "number")) then
		error("Passed \"ammoin\" parameter is not valid. False or number expected, ".. type(ammoin) .." passed.")
	elseif not ((type(ammo) == "boolean" and not ammo) or (type(ammo) == "number")) then
		error("Passed \"ammo\" parameter is not valid. False or number expected, ".. type(ammo) .." passed.")
	end
	if ammoin then
		if not (ammoin >= 0 and ammoin <= 999) then
			error("Passed \"ammoin\" value (as a number) has to be in the range of 0 and 999.")
		end
	end
	if ammo then
		if not (ammo >= 0 and ammo <= 999) then
			error("Passed \"ammo\" value (as a number) has to be in the range of 0 and 999.")
		end
	end
	
	if not self:exists() then
		error("Item of this instance doesn't exist.")
	end
	
	cas.console.parse("setammo", self._id, 0, ammoin, ammo)
end

-------------------
-- Static fields --
-------------------

cas.groundItem._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.groundItem._instances = setmetatable({}, {__mode == "kv"}) -- A table of instances of this class.