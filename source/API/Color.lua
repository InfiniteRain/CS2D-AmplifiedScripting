-- Initializing the color class.
local Color = class()

----------------------
-- Instance Methods --
----------------------

---
-- @param red
-- @param green
-- @param blue
--
function Color:constructor(red, green, blue)
  Color._validator:validate({
    { value = red, type = 'color' },
    { value = green, type = 'color' },
    { value = blue, type = 'color' }
  } , 'constructor', 2)

  self._red = red
  self._green = green
  self._blue = blue
end

-- This method will be called whenever a tostring() function is called with the
-- instance of this class as a parameter. Returns a string which is used to
-- change the message's color, in the following format: '�<red><green><blue>',
-- with necessary zeros added.
function Color:__tostring()
  return string.format('%c%03d%03d%03d', 169,
    self._red, self._green, self._blue)
end

--== Setters ==--

-- Sets the color fields of the instance.
function Color:setRGB(red, green, blue)
  Color._validator:validate({
    { value = self, type = Color },
    { value = red, type = 'color' },
    { value = green, type = 'color' },
    { value = blue, type = 'color' }
  } , 'setRGB', 2)

  self._red = red
  self._green = green
  self._blue = blue
end

-- Sets the red color field of the instance.
function Color:setRed(red)
  Color._validator:validate({
    { value = self, type = Color },
    { value = red, type = 'color' }
  } , 'setRed', 2)

  self._red = red
end

-- Sets the green color field of the instance.
function Color:setGreen(green)
  Color._validator:validate({
    { value = self, type = Color },
    { value = green, type = 'color' }
  } , 'setGreen', 2)

  self._green = green
end

-- Sets the blue color field of the instance.
function Color:setBlue(blue)
  Color._validator:validate({
    { value = self, type = Color },
    { value = blue, type = 'color' }
  } , 'setBlue', 2)

  self._blue = blue
end

--== Getters ==--

-- Gets the color fields of the instance.
function Color:getRGB()
  return self._red, self._green, self._blue
end

-- Gets the red color field of the instance.
function Color:getRed()
  return self._red
end

-- Gets the green color field of the instance.
function Color:getGreen()
  return self._green
end

-- Gets the blue color field of the instance.
function Color:getBlue()
  return self._blue
end

-------------------
-- Static fields --
-------------------

-- Validator for argument validation.
Color._validator = Validator()
-- Checks if values are correct representation of color.
Color._validator:addCustomRule('color', function(ruleTable)
  local value = ruleTable.value
  local hasError = not (type(value) == 'number'
      and value >= 0 and value <= 255 and value == math.floor(value))
  local message = 'value is not valid for color representation, has to be an '
      .. 'integer between 0 and 255'

  return hasError, message
end)

--== Preset color values for ease of access ==--

Color.white = Color(255, 255, 255)
Color.lightGray = Color(196, 196, 196)
Color.gray = Color(128, 128, 128)
Color.darkGray = Color(64, 64, 64)
Color.black = Color(0, 0, 0)
Color.red = Color(255, 0, 0)
Color.pink = Color(255, 0, 128)
Color.orange = Color(255, 128, 0)
Color.yellow = Color(255, 255, 0)
Color.green = Color(0, 255, 0)
Color.magenta = Color(255, 0, 255)
Color.cyan = Color(0, 255, 255)
Color.blue = Color(0, 0, 255)

-------------------------
-- Returning the class --
-------------------------
return Color
