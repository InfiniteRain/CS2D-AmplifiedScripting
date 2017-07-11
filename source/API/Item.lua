-- Initializing the item class.
local Item = class()

--------------------
-- Static methods --
-------------------- 

-- Checks if the item under the passed ID exists.
function Item.idExists(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	end
	
	return _META.command.item(itemID, "exists")
end

-- Returns the item instance from the passed item ID.
function Item.getInstance(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	elseif not _META.command.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.", 2)
	end
	
	for key, value in pairs(Item._instances) do
		if value._id == itemID then
			Item._debug:log("Item \"".. tostring(value) .."\" was found in \"_instances\" table and returned.")
			return value
		end
	end
	
	Item._allowCreation = true
	local item = Item.new(itemID)
	Item._allowCreation = false
	
	return item
end

-- Returns a table of all the items on the ground.
function Item.getItems()
	local items = {}
	for key, value in pairs(_META.command.item(0, "table")) do
		table.insert(items, Item.getInstance(value))
	end
	
	return items
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a item instance with corresponding ID.
function Item:constructor(itemID)
	if type(itemID) ~= "number" then
		error("Passed \"itemID\" parameter is not valid. Number expected, ".. type(itemID) .." passed.", 2)
	elseif not _META.command.item(itemID, "exists") then
		error("Passed \"itemID\" parameter represents a non-existent item.", 2)
	end
	
	if not Item._allowCreation then
		error("Instantiation of this class is not allowed.", 2)
	end
	
	for key, value in pairs(Item._instances) do
		if value._id == itemID then
			error("Instance with the same item ID already exists.", 2)
		end
	end
	
	self._id = itemID
	self._removed = false
	
	self._hasFadeoutTimer = self:hasFadeoutTimer()
	local gm = _META.command.game("sv_gamemode")
	if not (gm == "0" or gm == "4" or not (self._hasFadeoutTimer)) then
		self._lifetime = self:getDropTimer()
		self._fadeoutTimer = Timer.new(function(self)
			self._lifetime = self._lifetime + 1
			if self._lifetime >= tonumber(_META.command.game("mp_weaponfadeout")) then
				Item._debug:log("Item \"".. tostring(self) .."\"'s fade out timer is up.")
			
				self:remove()
			end
		end)
		self._fadeoutTimer:startConstantly(1000, self)
	end
	
	table.insert(Item._instances, self)
	
	Item._debug:log("Item \"".. tostring(self) .."\" was instantiated.")
end

-- Destructor.
function Item:destructor()
	if not self._removed then
		self._removed = true
		if self._fadeoutTimer then
			self._fadeoutTimer:stop()
		end
	end
	
	for key, value in pairs(Item._instances) do
		if value._id == self._id then
			-- Removes the item from the Item._instances table.
			Item._instances[key] = nil
		end
	end
	
	Item._debug:log("Item \"".. tostring(self) .."\" was garbage collected.")
end

--== Getters ==--

-- Gets the item ID of the item.
function Item:getItemID()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Everything else is self explanatory, I based it on "item" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function Item:getName()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "name")
end

function Item:getType()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return ItemType.getInstance(_META.command.item(self._id, "type"))
end

function Item:getPlayer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	local player = _META.command.item(self._id, "player")
	return (player ~= 0 and Player.getInstance(player) or false)
end

function Item:getAmmo()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "ammo")
end

function Item:getAmmoin()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "ammoin")
end

function Item:getMode()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "mode")
end

function Item:getPosition()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return 
		_META.command.item(self._id, "x"),
		_META.command.item(self._id, "y")
end

function Item:getX()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "x")
end

function Item:getY()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "y")
end

function Item:hasFadeoutTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	return _META.command.item(self._id, "dropped")
	-- TODO: add filetrs for modes 0 and 4
end

function Item:getDropTimer()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	if not self:hasFadeoutTimer() then
		error("This item does not have a fadeout timer.", 2)
	end
	
	return _META.command.item(self._id, "droptimer")
end

--== Setters/control ==--

function Item:remove()
	if self._removed then
		error("The item of this instance was already removed. It's better if you dispose of this instance.", 2)
	end
	
	local gm = _META.command.game("sv_gamemode")
	if not (gm == "0" or gm == "4" or (not self._hasFadeoutTimer)) then
		self._fadeoutTimer:stop()
	end
	
	Console.parse("removeitem", self._id)
	self._removed = true
	
	for key, value in pairs(Item._instances) do
		if value._id == self._id then
			-- Removes the item from the Item._instances table.
			Item._debug:log("Item \"".. tostring(value) .."\" was removed.")
			Item._instances[key] = nil
			
			return
		end
	end
	
	-- This error should usually never happen. It does happen when someone has modified the code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with an
	-- underscore ("_") directly and instead use setters/getters for item manipulation as it 
	-- can lead to bugs.
	error("Field \"_removed\" of this instance was set to false yet it wasn't found in the \"_instances\" table.", 2)
end

function Item:setAmmo(ammoin, ammo)
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
	
	Console.parse("setammo", self._id, 0, ammoin and ammoin or 1000, ammo and ammo or 1000)
end

-------------------
-- Static fields --
-------------------

Item._allowCreation = false -- Defines if instantiation of this class is allowed.
Item._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.
Item._debug = Debug.new(Color.yellow, "CAS Item") -- Debug for items.
Item._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return Item
