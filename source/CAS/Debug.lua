-- Initializing the debug class
local Debug = class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates an instance of the debug class and returns it. Takes
-- color and tag values as parameters.
function Debug:constructor(color, tag)
  Debug._validator:validate({
    { value = color, type = Color },
    { value = tag, type = 'string' }
  }, 'constructor', 2)

  self._color = color
  self._tag = tag
  self._active = false
end

-- Will create an entry in the debug log.
function Debug:log(message)
  Debug._validator:validate({
    { value = message, type = 'string' },
  }, 'log', 2)

  if self._active then
    print(tostring(self._color) .. 'Debug log - ' .. self._tag .. ': '
        .. message)
  end
end

-- Will show an informational message
function Debug:infoMessage(message)
  Debug._validator:validate({
    { value = message, type = 'string' },
  }, 'infoMessage', 2)

  print(tostring(self._color) .. 'Info - ' .. self._tag .. ': '
      .. message)
end

--== Setters ==--

-- Sets the active state of the debug logger.
function Debug:setActive(active)
  Debug._validator:validate({
    { value = active, type = 'boolean' },
  }, 'active', 2)

  self._active = active
end

--== Getters ==--

-- Gets the active state of the debug logger.
function Debug:isActive()
  return self._active
end

-------------------
-- Static fields --
-------------------

-- Validator for argument validation.
Debug._validator = Validator()

-------------------------
-- Returning the class --
-------------------------
return Debug
