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
	
	-- Identifies if any of the tween actions are happening.
	self._tMoving = false
	self._tRotating = false
	self._tChangingScale = false
	self._tChangingColor = false
	self._tChangingAlpha = false
	self._tRotatingConstantly = false
	
	-- Values tween functions trying to reach. (F stands for finishing.)
	self._tMovingFPosition = {0, 0}
	self._tRotatingFAngle = 0
	self._tChangingScaleFScale = {0, 0}
	self._tChangingColorFColor = {0, 0, 0}
	self._tChangingAlphaFAlpha = 0
	
	-- Values tween functions started with. (S stand for starting.)
	self._tChangingScaleSScale = {0, 0}
	self._tChangingColorSColor = {0, 0, 0}
	self._tChangingAlphaSAlpha = 0
	
	-- Information about timers for tweens functions.
	-- S stands for the millisecond the timer started at. (starting)
	-- N stands for the milliseconds the timer has to run for. (needed)
	self._tChangingAlphaTimerS = 0
	self._tChangingAlphaTimerN = 0
	
	-- Timers needed for each tween action.
	self._tMovingTimer = cas.timer.new(function(self) 
		self._tMoving = false 
		self._x = self._tMovingFPosition[1]
		self._y = self._tMovingFPosition[2]
	end)
	self._tRotatingTimer = cas.timer.new(function(self) 
		self._tRotating = false 
		self._angle = self._tRotatingFAngle
	end)
	self._tChangingScaleTimer = cas.timer.new(function(self) 
		self._tChangingScale = false
	end)
	self._tChangingColorTimer = cas.timer.new(function(self) 
		self._tChangingColor = false 
	end)
	self._tChangingAlphaTimer = cas.timer.new(function(self) 
		self._tChangingAlpha = false 
		self._alpha = self._tChangingAlphaFAlpha
	end)
	
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

--== Tween functions, starters ==--

function cas.mapImage:tweenMove(time, x, y)
	if not (time and x and y) then
		error("Less than 3 parameters were passed, expected at least 3 parameters.")
	elseif type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tMoving then
		error("This map image is already being moved.")
	end
	
	self._tMoving = true
	self._tMovingFPosition = {x, y}
	cas._cs2dCommands.tweenMove(self._id, time, x, y)
	self._tMovingTimer:start(time, 1, self)
end

function cas.mapImage:tweenRotate(time, angle)
	if not (time and angle) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotating then
		error("This map image is already being rotated.")
	elseif self._tRotatingConstantly then
		error("This map image is already being rotated, but constantly.")
	end
	
	self._tRotating = true
	self._tRotatingFAngle = angle
	cas._cs2dCommands.tween_rotate(self._id, time, angle)
	self._tRotatingTimer:start(time, 1, self)
end

function cas.mapImage:tweenRotateConstantly(speed)
	if not speed then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(speed) ~= "number" then
		error("Passed \"speed\" parameter is not valid. Number expected, ".. type(speed) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotatingConstantly then
		error("This map image is already being rotated constantly.")
	elseif self._tRotating then
		error("This map image is already being rotated, but not constantly.")
	end
	
	self._tRotatingConstantly = true
	cas._cs2dCommands.tween_rotateconstantly(self._id, speed)
end

function cas.mapImage:tweenAlpha(time, alpha)
	if not (time and alpha) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.")
	end
	
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tChangingAlpha then
		error("Alpha of this map image is already being changed.")
	end
	
	self._tChangingAlpha = true
	self._tChangingAlphaFAlpha = alpha
	self._tChangingAlphaSAlpha = self._alpha
	self._tChangingAlphaTimerS = os.clock() * 1000
	self._tChangingAlphaTimerN = time
	cas._cs2dCommands.tween_alpha(self._id, time, alpha)
	self._tChangingAlphaTimer:start(time, 1, self)
end

--== Tween functions, stoppers ==--

function cas.mapImage:stopMoving()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tMoving then
		error("This map image is not being moved.")
	end
	
	local nx, ny = self:getPosition()
	cas._cs2dCommands.tween_move(self._id, 0, nx, ny)
	self._x = nx
	self._y = ny
	self._tMovingTimer:stop()
	self._tMoving = false
end

function cas.mapImage:stopRotating()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tRotating then
		if self._tRotatingConstantly then
			error("This map image is not being rotated constantly.")
		else
			error("This map image is not being rotated.")
		end
	end
	
	cas._cs2dCommands.tween_rotate(self._id, 0, self:getAngle())
	self._angle = self:getAngle()
	self._tRotatingTimer:stop()
	self._tRotating = false
end

function cas.mapImage:stopRotatingConstantly()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tRotatingConstantly then
		error("This map image is not being rotated constantly.")
	end
	
	cas._cs2dCommands.tween_rotateconstantly(self._id, 0)
	self._angle = self:getAngle()
	self._tRotatingConstantly = false
end

function cas.mapImage:stopChangingAlpha()
	if self._freed then
		error("This map image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tChangingAlpha then
		error("Alpha of this map image is not being changed.")
	end
	
	cas._cs2dCommands.tween_alpha(self._id, 0, self:getAlpha())
	self._alpha = self:getAlpha()
	self._tChangingAlphaTimer:stop()
	self._tChangingAlpha = false
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
	
	if self._tMoving then
		error("This map image is being moved, stop the tween function before settings its position.")
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
	
	if self._tRotating then
		error("This map image is being rotated, stop the tween function before setting its angle.")
	elseif self._tRotatingConstantly then
		error("This map image is being rotated constantly, stop the tween function before setting its angle.")
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
		local angle = cas._cs2dCommands.object(self._id, 'rot') % 360
		return angle <= 180 and angle or -180 + (angle - 180)
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
	
	if self._tChangingAlpha then
		local starting, finishing = self._tChangingAlphaSAlpha, self._tChangingAlphaFAlpha
		local timerStarted, timerNeeded = self._tChangingAlphaTimerS, self._tChangingAlphaTimerN
		local multiplier = (((os.clock() * 1000) - timerStarted) / timerNeeded)
		return self._tChangingAlphaSAlpha + (self._tChangingAlphaFAlpha - self._tChangingAlphaSAlpha) * multiplier
	else
		return self._alpha
	end
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