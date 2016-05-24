-- Initializing the debug class
cas.debug = {}
cas.debug.__index = cas.debug

--------------------
-- Static methods --
--------------------

-- Constructor. Creates an instance of the debug class and returns it. Takes color and tag values 
-- as parameters.
function cas.debug.new(color, tag)
	if not (color and tag) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
	elseif type(tag) ~= "string" then
		error("Passed \"tag\" parameter is not valid. String expected, ".. type(tag) .." passed.")
	end
	
	local self = {}
	setmetatable(self, cas.debug)
	
	self._color = color
	self._tag = tag
	self._active = false
	
	return self
end

----------------------
-- Instance methods --
----------------------

-- Will create an entry in the debug log.
function cas.debug:log(message)
	if not message then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(tag) .." passed.")
	end
	
	if self._active then
		print(tostring(self._color) .. "Debug log - ".. self._tag ..": ".. message)
	end
end

-- Will show an informational message
function cas.debug:infoMessage(message)
	if not message then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(tag) .." passed.")
	end
	
	print(tostring(self._color) .. "Info - ".. self._tag ..": ".. message)
end

--== Setters ==--

-- Sets the active state of the debug logger.
function cas.debug:setActive(active)
	if active == nil then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(active) ~= "boolean" then
		error("Passed \"active\" parameter is not valid. Boolean expected, ".. type(active) .." passed.")
	end
	
	self._active = active
end

--== Getters ==--

-- Gets the active state of the debug logger.
function cas.debug:isActive()
	return self._active
end