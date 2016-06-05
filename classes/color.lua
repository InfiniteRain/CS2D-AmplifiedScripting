-- Initializing the color class.
cas.color = cas.class()

--------------------
-- Static methods --
--------------------

-- Checks if the passed parameters are suitable for color representation. All the passed parameters
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

-- Constructor. Creates an instance of the color class and returns it. Takes RGB color values as 
-- parameters to define the color the instance is supposed to represent.
function cas.color:constructor(red, green, blue)
	if not cas.color.isCorrectFormat(red, green, blue) then
		error("Passed parameters contained unsuitable values for color instance.", 2)
	end
	
	self._red = red
	self._green = green
	self._blue = blue
end

-- This method will be called whenever a tostring() function is called with the instance of this
-- class as an parameter. Returns a string which is used to change the message's color, in the 
-- following format: "©<red><green><blue>", with necessary zeros added.
function cas.color:__tostring()
	return string.format("%c%03d%03d%03d", 169, self._red, self._green, self._blue)
end

--== Setters ==--

-- Sets the color fields of the instance.
function cas.color:setRGB(red, green, blue)
	if not cas.color.isCorrectFormat(red, green, blue) then
		error("Passed parameters contained unsuitable values for color instance.", 2)
	end
	
	self._red = red
	self._green = green
	self._blue = blue
end

-- Sets the red color field of the instance.
function cas.color:setRed(red)
	if not cas.color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
	self._red = red
end

-- Sets the green color field of the instance.
function cas.color:setGreen(green)
	if not cas.color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
	self._green = green
end

-- Sets the blue color field of the instance.
function cas.color:setBlue(blue)
	if not cas.color.isCorrectFormat(red) then
		error("Passed parameter contained unsuitable value for color instance.", 2)
	end
	
	self._blue = blue
end

--== Getters ==--

-- Gets the color fields of the instance.
function cas.color:getRGB()
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