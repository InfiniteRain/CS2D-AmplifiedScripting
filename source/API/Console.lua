-- Initializing the console class.
local Console = class()

--------------------
-- Static methods --
--------------------

-- Parses the passed cs2d command with the passed parameters.
function Console.parse(command, ...)
	if type(command) ~= "string" then
		error("Passed \"command\" parameter is not valid. String expected, ".. type(command) .." passed.", 2)
	end
	
	local parameters = {...}
	local commandString = command
	for key, value in pairs(parameters) do
		commandString = commandString .. " \"".. tostring(value) .."\""
	end
	
	_META.command.parse(commandString)
end

-- Prints console message.
function Console.print(message, color)
	if type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(message) .." passed.", 2)
	end
	if color then
		if getmetatable(color) ~= Color then
			error("Passed \"color\" parameter is not valid. String expected, ".. type(color) .." passed.", 2)
		end
	end
	
	print((color and tostring(color) or "") .. message)
end

----------------------
-- Instance methods --
----------------------

function Console:constructor()
	error("Instantiation of this class is not allowed.", 2)
end

-------------------------
-- Returning the class --
-------------------------
return Console
