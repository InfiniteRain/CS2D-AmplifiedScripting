-- Very simple OOP module used for AS which includes all the basic OOP implementations. The
-- following function will return a class. It can also inherit properties from another class
-- by passing the needed class as the first argument.
cas.class = function(inheritsFrom)
	-- Checks if all the arguments are correct.
	if inheritsFrom then
		if type(inheritsFrom) ~= "table" then
			error("Passed \"inheritsFrom\" parameter is not valid. Table expected, ".. type(inheritsFrom) .." passed.")
		end
	end
	
	-- Initializes the class.
	local class = {}
	class.__index = class
	
	-- If there was a class passed, then inherit properties from it.
	if inheritsFrom then
		setmetatable(class, {__index == inheritsFrom})
	end
	
	-- Creates an instance of the class.
	function class.new(...)
		-- Initializes the instance.
		local instance = setmetatable({}, class)
		
		-- Since __gc metamethod doesn't work with tables in lua 5.1, we create a blank userdata
		-- and make its __gc method call the destructor of the object. Then, we store it as a field
		-- in the instance, so when the field is garbage collected, that means the object was 
		-- garbage collected as well.
		local proxy = newproxy(true)
		local proxyMeta = getmetatable(proxy)
		proxyMeta.__gc = function() 
			if class.destructor then 
				class:destructor() 
			end	
		end
		rawset(class, '__proxy', proxy)
		
		-- If the instance has the constructor declared, then call it.
		if instance.constructor then
			instance:constructor(...)
		end
		
		-- Checks if this is an instance of another class.
		function instance:isInstanceOf(aClass)
			if not aClass then
				error("No parameters were passed, expected at least 1 parameter.")
			elseif type(aClass) ~= "table" then
				error("Passed \"aClass\" parameter is not valid. Table expected, ".. type(aClass) .." passed.")
			end
			
			return getmetatable(self) == aClass 
		end
		
		-- Returns the instance.
		return instance
	end
	
	-- Returns the class.
	return class
end
