-- Initializing the debug class.
cas.hook = cas.class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Event represents the cs2d hook name, func is the actual function (not a string!)
-- and priority is the optional priority value for the cs2d hook. Label is the name the hook
-- function will have in the cas.hook._hooks table.
function cas.hook:constructor(event, func, priority, label)
	-- Checks if all the passed parameters were correct.
	if type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.", 2)
	elseif type(event) ~= "string" then
		error("Passed \"event\" parameter is not valid. String expected, ".. type(event) .." passed.", 2)
	end
	if priority then
		if type(priority) ~= "number" then
			error("Passed \"priority\" parameter is not valid. Number expected, ".. type(priority) .." passed.", 2)
		end
	end
	if label then
		if type(label) ~= "string" then
			error("Passed \"label\" parameter is not valid. String expected, ".. type(label) .." passed.", 2)
		elseif string.find(label, "^[%a_]+[%a%d_]*$") == nil then
			error("Passed \"label\" parameter has to start with a letter and contain no special/punctuational characters.", 2)
		end
	end
	
	-- Checks if the passed event is a correct cs2d hook.
	local match = false
	for key, value in pairs(cas._config.cs2dHooks) do
		if event == key then
			match = true
			break
		end
	end	
	if not match then
		error("Passed \"event\" value was not found in the \"cs2dHooks\" table in the config.", 2)
	end
	
	if label then
		-- Checks if passed label is not in use by any other hook.
		if cas.hook._hooks[label] then
			error("Passed \"label\" value is already in use by other hook(s).", 2)
		end
	end
	
	-- Assigning necessary fields.
	self._func = func
	self._event = event
	self._priority = priority or 0
	self._freed = false
	self._label = label or event -- If label wasn't provided, the script generates one.
	
	local count = 1
	while cas.hook._hooks[self._label] do -- This loop shouldn't happen if the label was provided.
		count = count + 1
		self._label = event .. count
	end
	
	cas.hook._hooks[self._label] = {
		originalFunc = func,
		func = function(...)
			local params = {...}
			-- Changing all the image ID's into instances of cas._image.
			if cas._config.cs2dHooks[self._event].image then
				for key, value in pairs(cas._config.cs2dHooks[self._event].image) do
					local imageID = params[value]
					params[value] = cas._image.getInstance(imageID)
				end
			end
			
			-- Changing all the player ID's into instances of cas.player.
			if cas._config.cs2dHooks[self._event].player then
				for key, value in pairs(cas._config.cs2dHooks[self._event].player) do
					local playerID = params[value]
					if playerID >= 1 and playerID <= 32 then
						params[value] = cas.player.getInstance(playerID)
					else
						params[value] = false
					end
				end
			end
			
			-- Changing all the item type ID's into instances of cas.item.type.
			if cas._config.cs2dHooks[self._event].itemType then
				for key, value in pairs(cas._config.cs2dHooks[self._event].itemType) do
					local itemType = params[value]
					if cas.item.type.typeExists(itemType) then
						params[value] = cas.item.type.getInstance(itemType)
					end			
				end
			end
			
			-- Changing all the item ID's into instances of cas.item.
			if cas._config.cs2dHooks[self._event].item then
				for key, value in pairs(cas._config.cs2dHooks[self._event].item) do
					local item = params[value]
					params[value] = cas.item.getInstance(item)
				end
			end
			
			-- Changing all the dynamic object ID's into instances of cas.dynObject.
			if cas._config.cs2dHooks[self._event].dynObject then
				for key, value in pairs(cas._config.cs2dHooks[self._event].dynObject) do
					local object = params[value]
					params[value] = object ~= 0 and cas.dynObject.getInstance(object) or false
				end
			end
			
			-- Changing all the entity positions into instances of cas.entity.
			if cas._config.cs2dHooks[self._event].entity then
				for key, value in pairs(cas._config.cs2dHooks[self._event].entity) do
					local position = {params[value[1]], params[value[2]]}
					params[value[1]] = cas.entity.getInstance(position[1], position[2])
					params[value[2]] = nil
				end
			end
			
			-- Changing all the reqcldModes into its string counterpart.
			if cas._config.cs2dHooks[self._event].reqcldMode then
				for key, value in pairs(cas._config.cs2dHooks[self._event].reqcldMode) do
					local mode = params[value]
					for k, v in pairs(cas.player._clientDataModes) do
						if v == value then
							params[value] = k
							break
						end
					end
				end
			end
			
			local returnValue = cas.hook._hooks[self._label].originalFunc(unpack(params))
			local returnString = ""
			if self._event == "spawn" then
				if getmetatable(returnValue) == cas.item.type then
					returnString = tostring(returnValue:getType())
				elseif type(returnValue) == "table" then
					for key, value in pairs(returnValue) do
						if getmetatable(value) == cas.item.type then
							returnString = returnString .. "," .. value:getType()
						end
					end
				elseif type(returnValue) == "string" and returnValue == "x" then
					returnString = "x"
				end
				
				return returnString
			else
				return returnValue
			end
		end
	}
	
	cas._cs2dCommands.addhook(event, "cas.hook._hooks." .. self._label ..".func", self._priority) -- Adds the hook.
	cas.hook._debug:infoMessage("Hook with '".. self._event .."' event, labeled as '".. self._label .."' was initialized.")
end

-- Destructor.
function cas.hook:destructor()
	if not self._freed then
		self:free()
	end
end

-- Frees the hook, meaning that cs2d will stop executing the hooked function.
function cas.hook:free()
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.", 2)
	end
	
	cas._cs2dCommands.freehook(self._event, "cas.hook._hooks." .. self._label)
	cas.hook._hooks[self._label] = nil
	
	cas.hook._debug:infoMessage("Hook with '".. self._event .."' event, labeled as '".. self._label .."' was freed.")
end

--== Getters ==--

-- Gets hooked function.
function cas.hook:getFunction()
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.", 2)
	end

	return self._func
end

--== Setters ==--

-- Sets the hooked function.
function cas.hook:setFunction(func)
	if type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.", 2)
	end
	
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.", 2)
	end
	
	self._func = func
	cas.hook._hooks[self._label] = func
end

-------------------
-- Static fields --
-------------------

cas.hook._hooks = {}
cas.hook._debug = cas.debug.new(cas.color.new(115, 110, 255), "CAS Hook")