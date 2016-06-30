-- Very simple OOP module used for CAS which includes all the basic OOP implementations. The
-- following function will return a class. It can also inherit properties from another class
-- by passing the needed class as the first argument.
cas.class = function(inheritsFrom)
	-- Checks if all the arguments are correct.
	if inheritsFrom then
		if type(inheritsFrom) ~= "table" then
			error("Passed \"inheritsFrom\" parameter is not valid. Table expected, ".. type(inheritsFrom) .." passed.", 2)
		end
	end
	
	-- Initializes the class.
	local class = {}
	class.__index = class
	
	-- If there was a class passed, then inherit properties from it.
	if inheritsFrom then
		-- Creating a table which hold original (non-overriden) properties.
		class.super = setmetatable({}, {
			__index = inheritsFrom, 
			__call = function(_, ...) -- If it was called as a function, then call the constructor.
				inheritsFrom.constructor(...) 
			end})
		setmetatable(class, {__index = inheritsFrom}) -- Inherit properties.
	end
	
	-- Creates a new instance of the class.
	function class.new(...)
		-- Initializes the instance.
		local instance = setmetatable({}, class)
		
		-- If the instance has the constructor declared, then call it.
		if instance.constructor then
			local success, errorString = pcall(instance.constructor, instance, ...)
			if not success then
				error(errorString, 2)
			end
		end
		
		-- Since __gc metamethod doesn't work with tables in lua 5.1, we create a blank userdata
		-- and make its __gc method call the destructor of the object. Then, we store it as a field
		-- in the instance, so when the field is garbage collected, that means the object was 
		-- garbage collected as well.
		local proxy = newproxy(true)
		local proxyMeta = getmetatable(proxy)
		proxyMeta.__gc = function() 
			if instance.destructor then 
				local success, errorString = pcall(instance.destructor, instance) 
				if not success then
					error(errorString, 2)
				end
			end
		end
		rawset(instance, '__proxy', proxy)
		
		-- Returns the instance.
		return instance
	end
	
	-- Returns the class.
	return class
end