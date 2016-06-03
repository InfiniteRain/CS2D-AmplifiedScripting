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
			cas.groundItem._debug:log("Ground item \"".. tostring(value) .."\" was found in \"_instances\" table and returned.")
			return value
		end
	end
	
	cas.groundItem._allowCreation = true
	local groundItem = cas.groundItem.new(itemID)
	cas.groundItem._allowCreation = false
	
	return groundItem
end

-- Returns a table of all the items on the ground.
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
	self._removed = false
	
	self._hasFadeoutTimer = self:hasFadeoutTimer()
	local gm = cas._cs2dCommands.game("sv_gamemode")
	if not (gm == "0" or gm == "4" or not (self._hasFadeoutTimer)) then
		self._lifetime = self:getDropTimer()
		self._fadeoutTimer = cas.timer.new(function(self)
			self._lifetime = self._lifetime + 1
			if self._lifetime >= tonumber(cas._cs2dCommands.game("mp_weaponfadeout")) then
				cas.groundItem._debug:log("Ground item \"".. tostring(self) .."\"'s fade out timer is up.")
			
				self:remove()
			end
		end)
		self._fadeoutTimer:startConstantly(1000, self)
	end
	
	table.insert(cas.groundItem._instances, self)
	
	cas.groundItem._debug:log("Ground item \"".. tostring(self) .."\" was instantiated.")
end

-- Destructor.
function cas.groundItem:destructor()
	if not self._removed then
		self._removed = true
		if self._fadeoutTimer then
			self._fadeoutTimer:stop()
		end
	end
	
	for key, value in pairs(cas.groundItem._instances) do
		if value._id == self._id then
			-- Removes the item from the cas.groundItem._instances table.
			cas.groundItem._instances[key] = nil
		end
	end
	
	cas.groundItem._debug:log("Ground item \"".. tostring(self) .."\" was garbage collected.")
end

--== Getters ==--

-- Gets the item ID of the item.
function cas.groundItem:getItemID()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
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
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "name")
end

function cas.groundItem:getType()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas.itemType.getInstance(cas._cs2dCommands.item(self._id, "type"))
end

function cas.groundItem:getPlayer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	local player = cas._cs2dCommands.item(self._id, "player")
	return (player ~= 0 and player or false)
end

function cas.groundItem:getAmmo()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "ammo")
end

function cas.groundItem:getAmmoin()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "ammoin")
end

function cas.groundItem:getMode()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "mode")
end

function cas.groundItem:getPosition()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return 
		cas._cs2dCommands.item(self._id, "x"),
		cas._cs2dCommands.item(self._id, "y")
end

function cas.groundItem:getX()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "x")
end

function cas.groundItem:getY()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "y")
end

function cas.groundItem:hasFadeoutTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	return cas._cs2dCommands.item(self._id, "dropped")
end

function cas.groundItem:getDropTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	if not self:hasFadeoutTimer() then
		error("This item does not have a fadeout timer.")
	end
	
	return cas._cs2dCommands.item(self._id, "droptimer")
end

--== Setters/control ==--

function cas.groundItem:remove()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	local gm = cas._cs2dCommands.game("sv_gamemode")
	if not (gm == "0" or gm == "4" or (not self._hasFadeoutTimer)) then
		self._fadeoutTimer:stop()
	end
	
	cas.console.parse("removeitem", self._id)
	self._removed = true
	
	for key, value in pairs(cas.groundItem._instances) do
		if value._id == self._id then
			-- Removes the item from the cas.groundItem._instances table.
			cas.groundItem._debug:log("Ground item \"".. tostring(value) .."\" was removed.")
			cas.groundItem._instances[key] = nil
			
			return
		end
	end
	
	-- This error should usually never happen. It does happen when someone has modified the code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with an
	-- underscore ("_") directly and instead use setters/getters for ground item manipulation as it 
	-- can lead to bugs.
	error("Field \"_removed\" of this instance was set to false yet it wasn't found in the \"_instances\" table.")
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
	
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.")
	end
	
	cas.console.parse("setammo", self._id, 0, ammoin, ammo)
end

-------------------
-- Static fields --
-------------------

cas.groundItem._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.groundItem._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.
cas.groundItem._debug = cas.debug.new(cas.color.yellow, "CAS Ground Item") -- Debug for ground items.
cas.groundItem._debug:setActive(true)