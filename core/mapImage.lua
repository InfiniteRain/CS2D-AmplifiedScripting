-- Initializing the map image class
cas.mapImage = {}
cas.mapImage.__index = cas.mapImage

--------------------
-- Static methods --
--------------------

-- Constructor. Loads an image from path with corresponding mode. You can also show it only to access
-- single player by using "visibleToPlayer" parameter.
function cas.mapImage.new(path, mode, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if not (path and mode) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.")
	elseif type(mode) ~= "string" then
		error("Passed \"mode\" parameter is not valid. String expected, ".. type(mode) .." passed.")
	end
	if visibleToPlayer then
		if type(visibleToPlayer) ~= "number" then
			error("Passed \"visibleToPlayer\" parameter is not valid. Number expected, ".. type(visibleToPlayer) .." passed.")
		end
	end
	
	-- Checks if the image exists.
	local file = io.open(path, 'r')
	if file == nil then
		error("Could not load image at \"".. path .."\".")
	else
		file:close()
	end
	
	-- Checks if the passed mode exists.
	if not cas.mapImage._modes[mode] then
		error("Passed \"mode\" value does not represent a valid mode.")
	end
	
	-- Creates the instance itself.
	local self = {}
	setmetatable(self, cas.mapImage)
	
	local proxy = newproxy(true)
	local proxyMeta = getmetatable(proxy)
	proxyMeta.__gc = function() if self.destructor then self:destructor() end end
	rawset(self, '__proxy', proxy)
	
	-- Assigning necessary fields.
	self._path = path
	self._mode = mode
	self._visibleToPlayer = 0
	
	self._x = 0
	self._y = 0
	self._scaleX = 1
	self._scaleY = 1
	self._angle = 0
	
	self._alpha = 1
	self._blend = 0
	self._color = cas.color.white
	
	self._tMoving = false
	self._tRotating = false
	self._tRotatingConstantly = false
	
	-- Creating the image.
	self._id = cas._cs2dCommands.image(path, 0, 0, cas.mapImage._modes[mode], visibleToPlayer)
	self._freed = false
	
	-- Adds the image into the "_images" table.
	table.insert(cas.mapImage._images, self)
	
	return self
end

----------------------
-- Instance methods --
----------------------

-- Destructor.
function cas.mapImage:destructor()
	pcall(self:free()) -- Freeing the map image upon garbage collection.
end

-- Frees the image and removes it from the "_images" table. "_images" table is necessary to free
-- every map image on startround.
function cas.mapImage:free()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	-- Frees the image.
	cas._cs2dCommands.freeimage(self._id)
	self._freed = true
	
	-- Finds it in the "_images" table and removes it.
	local found = false
	for key, value in pairs(cas.mapImage._images) do
		if value == self then
			cas.mapImage._images[key] = nil
			found = true
			break
		end
	end
	
	-- This error should usually never happen. It does happen when someone has modified the code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with 
	-- underscore ("_") directly and instead use setters/getters for image manipulation as it can
	-- lead to bugs.
	if not found then
		error("Field \"_freed\" of the instance was set to true yet it wasn't found in the \"_images\" table.")
	end
end

--== Setters ==--

-- Sets the position of the map image.
function cas.mapImage:setPosition(x, y)
	if not (x and y) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	self._x = x
	self._y = y
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
end

-- Sets the angle of the map image.
function cas.mapImage:setAngle(angle)
	if not angle then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	self._angle = angle
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
end

-- Sets the scale of the map image.
function cas.mapImage:setScale(scaleX, scaleY)
	if not (scaleX and scaleY) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(scaleX) ~= "number" then
		error("Passed \"scaleX\" parameter is not valid. Number expected, ".. type(scaleX) .." passed.")
	elseif type(scaleY) ~= "number" then
		error("Passed \"scaleY\" parameter is not valid. Number expected, ".. type(scaleY) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	self._scaleX = scaleX
	self._scaleY = scaleY
	
	cas._cs2dCommands.imagescale(self._id, self._scaleX, self._scaleY)
end

-- Sets the color of the map image.
function cas.mapImage:setColor(color)
	if not color then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	self._color = color
	
	cas._cs2dCommands.imagecolor(self._id, self._color:getRGB())
end

-- Sets the alpha of the map image.
function cas.mapImage:setAlpha(alpha)
	if not alpha then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.")
	elseif not (alpha >= 0 and alpha <= 1) then
		error("Passed \"alpha\" value has to be in the range of 0 - 1.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	self._alpha = alpha
	
	cas._cs2dCommands.imagealpha(self._id, self._alpha)
end

-- Sets the blend of the map image.
function cas.mapImage:setBlend(blend)
	if not blend then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(blend) ~= "string" then
		error("Passed \"blend\" parameter is not valid. String expected, ".. type(blend) .." passed.")
	end
	
	if not cas.mapImage._blendModes[blend] then
		error("Passed \"blend\" value does not represent a valid blend mode.")
	end
	
	self._blend = cas.mapImage._blendModes[blend]
	
	cas._cs2dCommands.imageblend(self._id, self._blend)
end

--== Getters ==--

-- Gets the position of the map image.
function cas.mapImage:getPosition()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tMoving then
		return cas._cs2dCommands.object(self._id, 'x'), cas._cs2dCommands.object(self._id, 'y')
	else
		return self._x, self._y
	end
end

-- Gets the angle of the map image.
function cas.mapImage:getAngle()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotating or self._tRotatingConstantly then
		return -180 + (cas._cs2dCommands.object(self._id, 'rot') % 360) 
	else
		return self._angle
	end
end

-- Gets the scale of the map image.
function cas.mapImage:getScale()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	return self._scaleX, self._scaleY
end

-- Gets the color of the map image.
function cas.mapImage:getColor()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	return self._color
end

-- Gets the alpha of the map image.
function cas.mapImage:getAlpha()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	return self._alpha
end

-- Gets the blend of the map image.
function cas.mapImage:getBlend()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	for key, value in pairs(cas.mapImage._blendModes) do
		if self._blend == value then
			return key
		end
	end
end

-- Gets whether or not this image is visible to everyone or only a single player.
function cas.mapImage:isVisibleToEveryone()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	return self._visibleToPlayer == 0
end

-- Gets the player this image is visible to.
function cas.mapImage:getPlayer()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end

	if self._visibleToPlayer == 0 then
		error("This map image is visible to everyone.")
	end
end

-------------------
-- Static fields --
-------------------

cas.mapImage._images = setmetatable({}, {__mode = "kv"}) -- Holds the loaded images, also serves as
														 -- a weak table.
cas.mapImage._modes = { -- Holds the image modes.
	["floor"] = 0, 
	["top"] = 1, 
	["supertop"] = 3
} 
cas.mapImage._blendModes = { -- Holds the image blend modes.
	["normal"] = 0,
	["light"] = 1,
	["shade"] = 2,
	["solid"] = 3
}