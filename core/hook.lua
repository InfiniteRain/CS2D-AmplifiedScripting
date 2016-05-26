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
	if not (func and event) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.")
	elseif type(event) ~= "string" then
		error("Passed \"event\" parameter is not valid. String expected, ".. type(event) .." passed.")
	end
	if priority then
		if type(priority) ~= "number" then
			error("Passed \"priority\" parameter is not valid. Number expected, ".. type(priority) .." passed.")
		end
	end
	if label then
		if type(label) ~= "string" then
			error("Passed \"label\" parameter is not valid. String expected, ".. type(label) .." passed.")
		elseif string.find(label, "^[%a_]+[%a%d_]*$") == nil then
			error("Passed \"label\" parameter has to start with a letter and contain no special/punctuational characters.")
		end
	end
	
	-- Checks if the passed event is a correct cs2d hook.
	local match = false
	for key, value in pairs(cas._config.cs2dHooks) do
		if event == value[1] then
			match = true
			break
		end
	end	
	if not match then
		error("Passed \"event\" value was not found in the \"cs2dHooks\" table in the config.")
	end
	
	if label then
		-- Checks if passed label is not in use by any other hook.
		if cas.hook._hooks[label] then
			error("Passed \"label\" value is already in use by other hook(s).")
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
	
	cas.hook._hooks[self._label] = func -- Inserts the provided hook function into the cas.hook._hooks table.
	cas._cs2dCommands.addhook(event, "cas.hook._hooks." .. self._label, self._priority) -- Adds the hook.
	cas.hook._debug:infoMessage("Hook with '".. self._event .."' event, labeled as '".. self._label .."' was initialized.")
end

-- Destructor.
function cas.hook:destructor()
	pcall(self:free())
end

-- Frees the hook, meaning that cs2d will stop executing the hooked function.
function cas.hook:free()
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.")
	end
	
	cas._cs2dCommands.freehook(self._event, "cas.hook._hooks." .. self._label)
	cas.hook._hooks[self._label] = nil
	
	cas.hook._debug:infoMessage("Hook with '".. self._event .."' event, labeled as '".. self._label .."' was freed.")
end

--== Getters ==--

-- Gets hooked function.
function cas.hook:getFunction()
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.")
	end

	return self._func
end

--== Setters ==--

-- Sets the hooked function.
function cas.hook:setFunction(func)
	if not func then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.")
	end
	
	if self._freed then
		error("This hook was already freed. It's better if you dispose of this instance.")
	end
	
	self._func = func
	cas.hook._hooks[self._label] = func
end

-------------------
-- Static fields --
-------------------

cas.hook._hooks = {}
cas.hook._debug = cas.debug.new(cas.color.new(115, 110, 255), "AS Hook")