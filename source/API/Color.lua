-- Initializing the color class.
local Color = class()

--------------------
-- Static methods --
--------------------

-- Checks if the passed parameters are suitable for color representation. All the passed parameters
-- have to be numbers, being in range of 0 and 255 while not containing a floating point.
function Color.isCorrectFormat(...)
	local numbers = {...}
	local correctFormat = true
	
	for key, value in pairs(numbers) do
		if not (type(value) == "number" and value >= 0 and value <= 255 and value == math.floor(value)) then
			correctFormat = false
			break
		end
	end
	
	return correctFormat
end

----------------------
-- Instance Methods --
----------------------

-- Constructor. Takes RGB color values as parameters to define color the instance is supposed
-- to represent.
function Color:constructor(red, green, blue)
	if not Color.isCorrectFormat(red, green, blue) then
		error("Passed parameters contained unsuitable values for color instance.", 2)
	end
	
	self._red = red
	self._green = green
	self._blue = blue
end

-- This method will be called whenever a tostring() function is called with the instance of this
-- class as an parameter. Returns a string which is used to change the message's color, in the 
-- following format: "©<red><green><blue>", with necessary zeros added.
function Color:__tostring()
	return string.format("%c%03d%03d%03d", 169, self._red, self._green, self._blue)
end

--== Setters ==--

-- Sets the color fields of the instance.
function Color:setRGB(red, green, blue)
	if not Color.isCorrectFormat(red, green, blue) then
		error("Passed parameters contained unsuitable values for color instance.", 2)
	end
	
	self._red = red
	self._green = green
	self._blue = blue
end

-- Sets the red color field of the instance.
function Color:setRed(red)
	if not Color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
	self._red = red
end

-- Sets the green color field of the instance.
function Color:setGreen(green)
	if not Color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
	self._green = green
end

-- Sets the blue color field of the instance.
function Color:setBlue(blue)
	if not Color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
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

--== Preset color values for ease of access ==--

Color.white = Color.new(255, 255, 255)
Color.lightGray = Color.new(196, 196, 196)
Color.gray = Color.new(128, 128, 128)
Color.darkGray = Color.new(64, 64, 64)
Color.black = Color.new(0, 0, 0)
Color.red = Color.new(255, 0, 0)
Color.pink = Color.new(255, 0, 128)
Color.orange = Color.new(255, 128, 0)
Color.yellow = Color.new(255, 255, 0)
Color.green = Color.new(0, 255, 0)
Color.magenta = Color.new(255, 0, 255)
Color.cyan = Color.new(0, 255, 255)
Color.blue = Color.new(0, 0, 255)

-------------------------
-- Returning the class --
-------------------------
return Color
