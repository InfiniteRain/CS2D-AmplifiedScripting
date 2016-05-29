-- Initializing the ground item class.
cas.groundItem = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the ground item instance from the passed item ID.
function cas.groundItem.getInstance(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.")
	elseif not cas._cs2dCommands.item(itemID, 'exists') then
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

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a item instance with corresponding ID.
function cas.groundItem:constructor(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.")
	elseif not cas._cs2dCommands.item(itemID, 'exists') then
		error("Passed \"itemID\" parameter represents a non-existent item.")
	end
	
	if not cas.groundItem._allowCreation then
		error("Instantiation of this class is not allowed.")
	end
	
	for key, value in pairs(cas.itemID._instances) do
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

-------------------
-- Static fields --
-------------------

cas.groundItem._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.groundItem._instances = setmetatable({}, {__mode == "kv"}) -- A table of instances of this class.