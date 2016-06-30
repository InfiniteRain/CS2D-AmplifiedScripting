-- Initializing the item class.
cas.item = cas.class()

--------------------
-- Static methods --
--------------------

-- Checks if the item under the passed ID exists.
function cas.item.idExists(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	end
	
	return cas._cs2dCommands.item(itemID, "exists")
end

-- Returns the item instance from the passed item ID.
function cas.item.getInstance(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	elseif not cas._cs2dCommands.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.", 2)
	end
	
	for key, value in pairs(cas.item._instances) do
		if value._id == itemID then
			cas.item._debug:log("Item \"".. tostring(value) .."\" was found in \"_instances\" table and returned.")
			return value
		end
	end
	
	cas.item._allowCreation = true
	local item = cas.item.new(itemID)
	cas.item._allowCreation = false
	
	return item
end

-- Returns a table of all the items on the ground.
function cas.item.getItems()
	local items = {}
	for key, value in pairs(cas._cs2dCommands.item(0, "table")) do
		table.insert(items, cas.item.getInstance(value))
	end
	
	return items
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a item instance with corresponding ID.
function cas.item:constructor(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	elseif not cas._cs2dCommands.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.", 2)
	end
	
	if not cas.item._allowCreation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	for key, value in pairs(cas.item._instances) do
		if value._id == itemID then
			error("Instance with the same item ID already exists.", 2)
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
				cas.item._debug:log("Item \"".. tostring(self) .."\"'s fade out timer is up.")
			
				self:remove()
			end
		end)
		self._fadeoutTimer:startConstantly(1000, self)
	end
	
	table.insert(cas.item._instances, self)
	
	cas.item._debug:log("Item \"".. tostring(self) .."\" was instantiated.")
end

-- Destructor.
function cas.item:destructor()
	if not self._removed then
		self._removed = true
		if self._fadeoutTimer then
			self._fadeoutTimer:stop()
		end
	end
	
	for key, value in pairs(cas.item._instances) do
		if value._id == self._id then
			-- Removes the item from the cas.item._instances table.
			cas.item._instances[key] = nil
		end
	end
	
	cas.item._debug:log("Item \"".. tostring(self) .."\" was garbage collected.")
end

--== Getters ==--

-- Gets the item ID of the item.
function cas.item:getItemID()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Everything else is self explanatory, I based it on "item" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cas.item:getName()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "name")
end

function cas.item:getType()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas.item.type.getInstance(cas._cs2dCommands.item(self._id, "type"))
end

function cas.item:getPlayer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	local player = cas._cs2dCommands.item(self._id, "player")
	return (player ~= 0 and player or false)
end

function cas.item:getAmmo()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "ammo")
end

function cas.item:getAmmoin()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "ammoin")
end

function cas.item:getMode()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "mode")
end

function cas.item:getPosition()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return 
		cas._cs2dCommands.item(self._id, "x"),
		cas._cs2dCommands.item(self._id, "y")
end

function cas.item:getX()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "x")
end

function cas.item:getY()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "y")
end

function cas.item:hasFadeoutTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "dropped")
end

function cas.item:getDropTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	if not self:hasFadeoutTimer() then
		error("This item does not have a fadeout timer.", 2)
	end
	
	return cas._cs2dCommands.item(self._id, "droptimer")
end

--== Setters/control ==--

function cas.item:remove()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	local gm = cas._cs2dCommands.game("sv_gamemode")
	if not (gm == "0" or gm == "4" or (not self._hasFadeoutTimer)) then
		self._fadeoutTimer:stop()
	end
	
	cas.console.parse("removeitem", self._id)
	self._removed = true
	
	for key, value in pairs(cas.item._instances) do
		if value._id == self._id then
			-- Removes the item from the cas.item._instances table.
			cas.item._debug:log("Item \"".. tostring(value) .."\" was removed.")
			cas.item._instances[key] = nil
			
			return
		end
	end
	
	-- This error should usually never happen. It does happen when someone has modified the code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with an
	-- underscore ("_") directly and instead use setters/getters for item manipulation as it 
	-- can lead to bugs.
	error("Field \"_removed\" of this instance was set to false yet it wasn't found in the \"_instances\" table.", 2)
end

function cas.item:setAmmo(ammoin, ammo)
	if not ((type(ammoin) == "boolean" and not ammoin) or (type(ammoin) == "number")) then
		error("Passed \"ammoin\" parameter is not valid. False or number expected, ".. type(ammoin) .." passed.", 2)
	elseif not ((type(ammo) == "boolean" and not ammo) or (type(ammo) == "number")) then
		error("Passed \"ammo\" parameter is not valid. False or number expected, ".. type(ammo) .." passed.", 2)
	end
	if ammoin then
		if not (ammoin >= 0 and ammoin <= 999) then
			error("Passed \"ammoin\" value (as a number) has to be in the range of 0 and 999.", 2)
		end
	end
	if ammo then
		if not (ammo >= 0 and ammo <= 999) then
			error("Passed \"ammo\" value (as a number) has to be in the range of 0 and 999.", 2)
		end
	end
	
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	cas.console.parse("setammo", self._id, 0, ammoin, ammo)
end

-------------------
-- Static fields --
-------------------

cas.item._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.item._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.
cas.item._debug = cas.debug.new(cas.color.yellow, "CAS Item") -- Debug for items.
--cas.item._debug:setActive(true)