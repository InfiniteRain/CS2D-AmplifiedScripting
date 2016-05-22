-- Initializing the color class.
cas.color = {}
cas.color.__index = cas.color

--------------------
-- Static methods --
--------------------

-- Constructor. Will create the instance of color and return it.
function cas.color.new(red, green, blue)
	if not (red and green and blue) then
		error("Less than 3 arguments were passed, expected at least 3 arguments.")
	elseif not cas.color.isCorrectFormat(red, green, blue) then
		error("Passed arguments contained unsuitable values for color instance.")
	end
	
	local self = {}
	setmetatable(self, cas.color)
	
	self._red = red
	self._green = green
	self._blue = blue
	
	return self
end

-- Checks if the passed arguments are suitable for color representation. All the passed arguments
-- have to be numbers, being in range of 0 and 255 while not containing a floating point.
function cas.color.isCorrectFormat(...)
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

-- This method will be called whenever a tostring() function is called with the instance of this
-- class as an argument. Returns a string which is used to change the message's color, in the 
-- following format: "�<red><green><blue>", with necessary zeros added.
function cas.color:__tostring()
	return string.format("%c%03d%03d%03d", 169, self._red, self._green, self._blue)
end

--== Setters ==--

-- Sets the color fields of the instance.
function cas.color:setColor(red, green, blue)
	if not (red and green and blue) then
		error("Less than 3 arguments were passed, expected at least 3 arguments.")
	elseif not cas.color.isCorrectFormat(red, green, blue) then
		error("Passed arguments contained unsuitable values for color instance.")
	end
	
	self._red = red
	self._green = green
	self._blue = blue
end

-- Sets the red color field of the instance.
function cas.color:setRed(red)
	if not red then
		error("No arguments were passed, expected at least 1 argument.")
	elseif not cas.color.isCorrectFormat(red) then
		error("Passed argument contained unsuitable value for color instance.")
	end
	
	self._red = red
end

-- Sets the green color field of the instance.
function cas.color:setGreen(green)
	if not red then
		error("No arguments were passed, expected at least 1 argument.")
	elseif not cas.color.isCorrectFormat(red) then
		error("Passed argument contained unsuitable value for color instance.")
	end
	
	self._green = green
end

-- Sets the blue color field of the instance.
function cas.color:setBlue(blue)
	if not red then
		error("No arguments were passed, expected at least 1 argument.")
	elseif not cas.color.isCorrectFormat(red) then
		error("Passed argument contained unsuitable value for color instance.")
	end
	
	self._blue = blue
end

--== Getters ==--

-- Gets the color fields of the instance.
function cas.color:getColor()
	return self._red, self._green, self._blue
end

-- Gets the red color field of the instance.
function cas.color:getRed()
	return self._red
end

-- Gets the green color field of the instance.
function cas.color:getGreen()
	return self._green
end

-- Gets the blue color field of the instance.
function cas.color:getBlue()
	return self._blue
end

-------------------
-- Static fields --
-------------------

--== Preset color values for ease of access ==--

cas.color.white = cas.color.new(255, 255, 255)
cas.color.lightGray = cas.color.new(196, 196, 196)
cas.color.gray = cas.color.new(128, 128, 128)
cas.color.darkGray = cas.color.new(64, 64, 64)
cas.color.black = cas.color.new(0, 0, 0)
cas.color.red = cas.color.new(255, 0, 0)
cas.color.pink = cas.color.new(255, 0, 128)
cas.color.orange = cas.color.new(255, 128, 0)
cas.color.yellow = cas.color.new(255, 255, 0)
cas.color.green = cas.color.new(0, 255, 0)
cas.color.magenta = cas.color.new(255, 0, 255)
cas.color.cyan = cas.color.new(0, 255, 255)
cas.color.blue = cas.color.new(0, 0, 255)