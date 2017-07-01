-- Initializing the OOP.
local cas = {}
cas.location = ...
cas.config = require(cas.location .. '.config')
cas.loadedClasses = {}

-- Tries to load a class from a namespace.
cas.loadClass = function(class, namespace)
	local ns = namespace

	-- Checking if the file exists.
	local filePath = cas.location:gsub('%.+', '/') .. '/classes/' .. ns .. '/' .. class .. '.lua'
	local file = io.open(filePath, 'r')
	if file == nil then
		return false, 0, 'File at path \'' .. filePath .. '\' does not exist.'
	end
	file:close()

	-- Checking if the file returns a class.
	local requirePath = cas.location .. '.classes.' .. ns .. '.' .. class
	local class = require(requirePath)
	if not (class ~= nil and type(class) == 'table' and class.__IS_CLASS) then
		return false, 1, 'File at path \'' .. filePath .. '\' does not return a class.'
	end

	return class
end

-- Very simple OOP implementation. The following function will return a class. 
-- It can also inherit properties from another class by passing the needed 
-- class as the first argument.
class = function(inheritsFrom)
	-- Checks if all the arguments are correct.
	if inheritsFrom then
		if type(inheritsFrom) ~= 'table' then
			error(
				'Passed \'inheritsFrom\' parameter is not valid. Table expected, '.. 
					type(inheritsFrom) ..' passed.',
				2
			)
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

	-- Class identifier
	class.__IS_CLASS = true
	
	-- Returns the class.
	return class
end

-- The following returns a namespace table, which will return classes of that
-- namespace when indexed.
use = function(namespace)
	print(debug.getinfo(2).source)
	return setmetatable({}, {
		__index = function(self, index)
			local potentialClass = cas.loadClass(index, namespace)
			if potentialClass then
				return potentialClass
			end
		end
	})
end

-- The following metatable declaration makes it so that if a call for an undefined 
-- global variable was found, then before anything, it checks if a class exists
-- within the current namespace, and if it does, loads it.
_G = setmetatable(_G, {
	__index = function(self, index)
		local namespace = debug.getinfo(2).source
			:sub(4, -5):gsub('[\\/]', '.')
			:sub(#(cas.location .. '.classes.') + 1, -1)
			:gsub('(.*)%.(.*)$','%1')

		local potentialClass = cas.loadClass(index, namespace)
		if potentialClass then
			return potentialClass
		end
	end
})

-- Initiator function which lets script know about which class to use the main method from.
return function()
	local class, errorNumber, errorMessage = cas.loadClass(
		cas.config.mainClass:gsub('(.*)%.(.*)$','%2'), 
		cas.config.mainClass:gsub('(.*)%.(.*)$','%1')
	)
	if not class then
		error(errorMessage, 2)
	else
		class.main()
	end
end
