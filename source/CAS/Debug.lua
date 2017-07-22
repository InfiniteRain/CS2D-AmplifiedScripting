-- Initializing the debug class
local Debug = class()

--~~~~~~~~~~~~~~~~~~--
-- Instance methods --
--~~~~~~~~~~~~~~~~~~--

---
-- Constructor method.
--
-- @param color (instance of CAS.color)
--   Color for the debug messages
-- @param tag (string)
--   Tag for messages
--
function Debug:constructor(color, tag)
    Debug._validator:validate({
        { value = color, type = Color },
        { value = tag, type = 'string' }
    }, 'constructor', 2)

    self._color = color
    self._tag = tag
    self._active = false
end

---
-- Creates an entry in the debug log.
--
-- @param message (string)
--   Log text
--
function Debug:log(message)
    Debug._validator:validate({
        { value = message, type = 'string' },
    }, 'log', 2)

    if self._active then
        print(tostring(self._color) .. 'Debug log - ' .. self._tag .. ': ' .. message)
    end
end

---
-- Shows an informational message
--
-- @param message (string)
--   Message text
--
function Debug:infoMessage(message)
    Debug._validator:validate({
        { value = message, type = 'string' },
    }, 'infoMessage', 2)

    print(tostring(self._color) .. 'Info - ' .. self._tag .. ': ' .. message)
end

--== Setters ==--

---
-- Sets the active state of the debug logger.
--
-- @param active (boolean)
--   Whether or not the debug logger is active
--
function Debug:setActive(active)
    Debug._validator:validate({
        { value = active, type = 'boolean' },
    }, 'active', 2)

    self._active = active
end

--== Getters ==--

---
-- Gets the active state of the debug logger.
--
-- @return (boolean)
--   The active state.
function Debug:isActive()
    return self._active
end

--~~~~~~~~~~~~~~~--
-- Static fields --
--~~~~~~~~~~~~~~~--

-- Validator.
Debug._validator = Validator()

--~~~~~~~~~~~~~~~~~~~~~--
-- Returning the class --
--~~~~~~~~~~~~~~~~~~~~~--

return Debug
