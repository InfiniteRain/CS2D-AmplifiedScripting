-- Initializing the class.
local Console = class()

--~~~~~~~~~~~~~~~~--
-- Static methods --
--~~~~~~~~~~~~~~~~--

---
-- Parses the passed cs2d command with the passed parameters.
--
-- @param command
--   Console command to parse
-- @param ...
--   Command parameters
--
function Console.parse(command, ...)
    Console._validator:validate({
        { value = command, type = 'string' }
    }, 'parse', 2)

    local parameters = { ... }
    local commandString = command
    for _, value in pairs(parameters) do
        commandString = commandString .. ' "' .. tostring(value) .. '"'
    end

    _META.command.parse(commandString)
end

---
-- Prints a console message.
--
-- @param message
--   Message to display
-- @param color
--   Message color (instance of CAS.Color)
--
function Console.print(message, color)
    Console._validator:validate({
        { value = message, type = 'string' },
        { value = color, type = Color, optional = true }
    }, 'print', 2)

    print((color and tostring(color) or '') .. message)
end

--~~~~~~~~~~~~~~~~~~--
-- Instance methods --
--~~~~~~~~~~~~~~~~~~--

---
-- Constructor which forbids instantiation of this class.
--
function Console.constructor()
    error('Instantiation of this class is not allowed.', 2)
end

--~~~~~~~~~~~~~~~--
-- Static fields --
--~~~~~~~~~~~~~~~--

-- Validator.
Console._validator = Validator()

--~~~~~~~~~~~~~~~~~~~~~--
-- Returning the class --
--~~~~~~~~~~~~~~~~~~~~~--

return Console
