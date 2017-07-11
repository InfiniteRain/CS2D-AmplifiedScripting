-- Initializing the debug class
local Debug = class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates an instance of the debug class and returns it. Takes color and tag values 
-- as parameters.
function Debug:constructor(color, tag)
	if getmetatable(color) ~= Color then
		error("Passed \"color\" parameter is not an instance of the \"Color\" class.", 2)
	elseif type(tag) ~= "string" then
		error("Passed \"tag\" parameter is not valid. String expected, ".. type(tag) .." passed.", 2)
	end
	
	self._color = color
	self._tag = tag
	self._active = false
end

-- Will create an entry in the debug log.
function Debug:log(message)
	if type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(tag) .." passed.", 2)
	end
	
	if self._active then
		print(tostring(self._color) .. "Debug log - ".. self._tag ..": ".. message)
	end
end

-- Will show an informational message
function Debug:infoMessage(message)
	if type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(tag) .." passed.", 2)
	end
	
	print(tostring(self._color) .. "Info - ".. self._tag ..": ".. message)
end

--== Setters ==--

-- Sets the active state of the debug logger.
function Debug:setActive(active)
	if type(active) ~= "boolean" then
		error("Passed \"active\" parameter is not valid. Boolean expected, ".. type(active) .." passed.", 2)
	end
	
	self._active = active
end

--== Getters ==--

-- Gets the active state of the debug logger.
function Debug:isActive()
	return self._active
end

-------------------------
-- Returning the class --
-------------------------
return Debug
