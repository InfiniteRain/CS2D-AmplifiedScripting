-- Initializing the console class.
cas.console = cas.class()

--------------------
-- Static methods --
--------------------

-- Parses the passed cs2d command with the passed parameters.
function cas.console.parse(command, ...)
	if type(command) ~= "string" then
		error("Passed \"command\" parameter is not valid. String expected, ".. type(command) .." passed.", 2)
	end
	
	local parameters = {...}
	local commandString = command
	for key, value in pairs(parameters) do
		commandString = commandString .. " \"".. tostring(value) .."\""
	end
	
	cas._cs2dCommands.parse(commandString)
end

----------------------
-- Instance methods --
----------------------

function cas.console:constructor()
	error("Instantiation of this class is not allowed.", 2)
end