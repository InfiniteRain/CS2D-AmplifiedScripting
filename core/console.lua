-- Initializing the console class.
cas.console = cas.class()

--------------------
-- Static methods --
--------------------

-- Parses the passed cs2d command with the passed parameters.
function cas.console.parse(command, ...)
	if not command then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(command) ~= "string" then
		error("Passed \"command\" parameter is not valid. String expected, ".. type(command) .." passed.")
	end
	
	local parameters = {...}
	local commandString = command
	for key, value in pairs(parameters) do
		commandString = commandString .. " \"".. tostring(value) .."\""
	end
	
	cas._cs2dCommands.parse(commandString)
end

-- Sends a message to every client's console.
function cas.console.writeToEveryone(message, color)
	if not message then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(message) .." passed.")
	end
	if color then
		if getmetatable(color) ~= cas.color then
			error("Passed \"color\" parameter is not valid. String expected, ".. type(color) .." passed.")
		end
	end
	
	cas.console.parse("cmsg", (color and tostring(color) or "") .. message)
end

----------------------
-- Instance methods --
----------------------

function cas.console:constructor()
	error("Instantiation of this class is not allowed.")
end