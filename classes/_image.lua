-- Initializing the _image class
cas._image = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the image instance from the passed image ID.
function cas._image.getInstance(imageID) 
	if type(imageID) ~= "number" then
		error("Passed \"imageID\" parameter is not valid. Number expected, ".. type(imageID) .." passed.", 2)
	end

	for key, value in pairs(cas._image._images) do
		if imageID == value._id then
			return value
		end
	end
	
	error("Passed \"imageID\" parameter represents a non-existent image.", 2)
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Loads an image from path with corresponding mode. You can also show it only to access
-- single player by using "visibleToPlayer" parameter.
function cas._image:constructor(path, mode, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	elseif type(mode) ~= "number" then
		error("Passed \"mode\" parameter is not valid. Number expected, ".. type(mode) .." passed.", 2)
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= cas.player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"cas.player\" class.", 2)
		end
		
		if visibleToPlayer._left then
			error("The player of this instance has already left the server. It's better if you dispose of this instance.", 2)
		end
 	end
	
	-- Checks if the image exists.
	local file = io.open(path, 'r')
	if file == nil then
		error("Could not load image at \"".. path .."\".", 2)
	else
		file:close()
	end
	
	-- Checks if the passed mode exists.
	if not ((mode >= 0 and mode <= 3) or (mode >= 101 and mode <= 164) or (mode >= 201 and mode <= 232)) then
		error("Passed \"mode\" value does not represent a valid mode.", 2)
	end
	
	-- Assigning necessary fields.
	self._visibleToPlayer = visibleToPlayer
	self._path = path
	self._mode = mode
	
	self._x = 0
	self._y = 0
	self._scaleX = 1
	self._scaleY = 1
	self._angle = 0
	
	self._alpha = 1
	self._blend = 0
	self._color = cas.color.white
	
	self._hasHitzone = false
	
	-- Fields, which are necessary for tween functionality.
	self._tMove = {
		active = false, -- Whether or not this tween function is active.
		finalPosition = {0, 0}, -- Sets the final (wanted) result of the tween function.
		timer = cas.timer.new(function(self) -- The timer function, which updates the fields upon
											 -- finising the tween function.
			self._tMove.active = false 
			self._x = self._tMove.finalPosition[1]
			self._y = self._tMove.finalPosition[2]
		end)
	}
	
	self._tRotate = {
		active = false,
		finalAngle = 0,
		timer = cas.timer.new(function(self) 
			self._tRotate.active = false 
			self._angle = self._tRotate.finalAngle
		end)
	}
	
	self._tRotateConstantly = {
		active = false
	}
	
	self._tScale = {
		active = false,
		finalScale = {0, 0},
		startingScale = {0, 0}, -- Starting parameters of the tween function.
		timerStartingMS = 0, -- Defines the millisecond the tween function started on.
		timerLifetime = 0, -- Defines the time (in ms) during which the tween function has to do its job.
		timer = cas.timer.new(function(self) 
			self._tScale.active = false
			self._scaleX = self._tScale.finalScale[1]
			self._scaleY = self._tScale.finalScale[2]
		end)
	}
	
	self._tColor = {
		active = false,
		finalColor = {0, 0, 0},
		startingColor = {0, 0, 0},
		timerStartingMS = 0,
		timerLifetime = 0,
		timer = cas.timer.new(function(self)
			self._tColor.active = false
			self._color = cas.color.new(self._tColor.finalColor[1], self._tColor.finalColor[2], self._tColor.finalColor[3])
		end)
	}
	
	self._tAlpha = {
		active = false,
		finalAlpha = 0,
		startingAlpha = 0,
		timerStartingMS = 0,
		timerLifetime = 0,
		timer = cas.timer.new(function(self)
			self._tAlpha.active = false
			self._alpha = self._tAlpha.finalAlpha
		end)
	}
	
	-- Creating the image.
	self._id = cas._cs2dCommands.image(path, 0, 0, mode, visibleToPlayer ~= 0 and visibleToPlayer._id or 0)
	self._freed = false
	
	-- Adds the image into the "_images" table.
	table.insert(cas._image._images, self)
	
	cas._image._debug:log("Image \"".. tostring(self) .."\" with path \"".. self._path .."\" was initialized.")
end

-- Destructor.
function cas._image:destructor()
	if not self._freed then
		self:free() -- Freeing the image upon garbage collection.
	end
	
	cas._image._debug:log("Image \"".. tostring(self) .."\" with path \"".. self._path .."\" was garbage collected.")
end

-- Frees the image and removes it from the "_images" table. "_images" table is necessary to free
-- every image on startround.
function cas._image:free()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	-- Frees all the associated tween timers.
	if self._tMove.active then self:stopTweenMove() end
	if self._tRotate.active then self:stopTweenRotate() end
	if self._tScale.active then self:stopTweenScale() end
	if self._tColor.active then self:stopTweenColor() end
	if self._tAlpha.active then self:stopTweenAlpha() end
		
	-- Frees the image.
	cas._cs2dCommands.freeimage(self._id)
	self._freed = true
	
	-- Finds it in the "_images" table and removes it.
	for key, value in pairs(cas._image._images) do
		if value == self then
			cas._image._images[key] = nil
			cas._image._debug:log("Image \"".. tostring(self) .."\" with path \"".. self._path .."\" was freed.")
			return
		end
	end
	
	-- This error should usually never happen. It does happen when someone has modified the code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with 
	-- underscore ("_") directly and instead use setters/getters for image manipulation as it can
	-- lead to bugs.
	error("Field \"_freed\" of this instance was set to false yet it wasn't found in the \"_images\" table.", 2)
end

--== Tween functions, starters ==--

-- Tween move
function cas._image:tweenMove(time, x, y)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This image is already being moved.", 2)
	end
	
	self._tMove.active = true
	self._tMove.finalPosition = {x, y}
	cas._cs2dCommands.tween_move(self._id, time, x, y)
	self._tMove.timer:start(time, 1, self)
	
	return self
end

-- Tween rotate.
function cas._image:tweenRotate(time, angle)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tRotate.active then
		error("This image is already being rotated.", 2)
	elseif self._tRotateConstantly.active then
		error("This image is already being rotated, but constantly.", 2)
	end
	
	self._tRotate.active = true
	self._tRotate.finalAngle = angle
	cas._cs2dCommands.tween_rotate(self._id, time, angle)
	self._tRotate.timer:start(time, 1, self)
	
	return self
end

-- Tween rotate constantly.
function cas._image:tweenRotateConstantly(speed)
	if type(speed) ~= "number" then
		error("Passed \"speed\" parameter is not valid. Number expected, ".. type(speed) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tRotateConstantly.active then
		error("This image is already being rotated constantly.", 2)
	elseif self._tRotate.active then
		error("This image is already being rotated, but not constantly.", 2)
	end
	
	self._tRotateConstantly.active = true
	cas._cs2dCommands.tween_rotateconstantly(self._id, speed)
	
	return self
end

-- Tween scale.
function cas._image:tweenScale(time, scaleX, scaleY)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(scaleX) ~= "number" then
		error("Passed \"scaleX\" parameter is not valid. Number expected, ".. type(scaleX) .." passed.", 2)
	elseif type(scaleY) ~= "number" then
		error("Passed \"scaleY\" parameter is not valid. Number expected, ".. type(scaleY) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tScale.active then
		error("Scale of this image is already being changed.", 2)
	end
	
	self._tScale.active = true
	self._tScale.finalScale = {scaleX, scaleY}
	self._tScale.startingScale = {self._scaleX, self._scaleY}
	self._tScale.timerStartingMS = os.clock() * 1000
	self._tScale.timerLifetime = time
	cas._cs2dCommands.tween_scale(self._id, time, scaleX, scaleY)
	self._tScale.timer:start(time, 1, self)
	
	return self
end

-- Tween color.
function cas._image:tweenColor(time, color)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tColor.active then
		error("Color of this image is already being changed.", 2)
	end
	
	self._tColor.active = true
	self._tColor.finalColor = {color:getRGB()}
	self._tColor.startingColor = {self._color:getRGB()}
	self._tColor.timerStartingMS = os.clock() * 1000
	self._tColor.timerLifetime = time
	cas._cs2dCommands.tween_color(self._id, time, color:getRGB())
	self._tColor.timer:start(time, 1, self)
	
	return self
end

-- Tween alpha.
function cas._image:tweenAlpha(time, alpha)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tAlpha.active then
		error("Alpha of this image is already being changed.", 2)
	end
	
	self._tAlpha.active = true
	self._tAlpha.finalAlpha = alpha
	self._tAlpha.startingAlpha = self._alpha
	self._tAlpha.timerStartingMS = os.clock() * 1000
	self._tAlpha.timerLifetime = time
	cas._cs2dCommands.tween_alpha(self._id, time, alpha)
	self._tAlpha.timer:start(time, 1, self)
	
	return self
end

--== Tween functions, stoppers ==--

-- Stop tween move.
function cas._image:stopTweenMove()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tMove.active then
		error("This image is not being moved.", 2)
	end
	
	local nx, ny = self:getPosition()
	cas._cs2dCommands.tween_move(self._id, 0, nx, ny)
	self._x = nx
	self._y = ny
	self._tMove.timer:stop()
	self._tMove.active = false
	
	return self
end

-- Stop tween rotate.
function cas._image:stopTweenRotate()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tRotate.active then
		if self._tRotateConstantly.active then
			error("This image is not being rotated constantly.", 2)
		else
			error("This image is not being rotated.", 2)
		end
	end
	
	cas._cs2dCommands.tween_rotate(self._id, 0, self:getAngle())
	self._angle = self:getAngle()
	self._tRotate.timer:stop()
	self._tRotate.active = false
	
	return self
end

-- Stop tween rotate constantly.
function cas._image:stopTweenRotateConstantly()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tRotateConstantly.active then
		error("This image is not being rotated constantly.", 2)
	end
	
	cas._cs2dCommands.tween_rotateconstantly(self._id, 0)
	self._angle = self:getAngle()
	self._tRotateConstantly.active = false
	
	return self
end

-- Stop tween scale.
function cas._image:stopTweenScale()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tScale.active then
		error("Scale of this image is not being changed.", 2)
	end
	
	local scaleX, scaleY = self:getScale()
	cas._cs2dCommands.tween_scale(self._id, 0, scaleX, scaleY)
	self._scaleX = scaleX
	self._scaleY = scaleY
	self._tScale.timer:stop()
	self._tScale.active = false
	
	return self
end

-- Stop tween color.
function cas._image:stopTweenColor()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tColor.active then
		error("Color of this image is not being changed.", 2)
	end
	
	local color = self:getColor()
	cas._cs2dCommands.tween_color(self._id, 0, color:getRGB())
	self._color = color
	self._tColor.timer:stop()
	self._tColor.active = false
	
	return self
end

-- Stop tween alpha.
function cas._image:stopTweenAlpha()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tAlpha.active then
		error("Alpha of this image is not being changed.", 2)
	end
	
	cas._cs2dCommands.tween_alpha(self._id, 0, self:getAlpha())
	self._alpha = self:getAlpha()
	self._tAlpha.timer:stop()
	self._tAlpha.active = false
	
	return self
end

--== Setters ==--

-- Sets hitzone.
function cas._image:setHitzone(stopShot, effect, xOffset, yOffset, width, height)
	if type(stopShot) ~= "boolean" then
		error("Passed \"stopShot\" parameter is not valid. Boolean expected, ".. type(stopShot) .." passed.", 2)
	elseif type(effect) ~= "string" then
		error("Passed \"effect\" parameter is not valid. String expected, ".. type(effect) .." passed.", 2)
	elseif type(xOffset) ~= "number" then
		error("Passed \"xOffset\" parameter is not valid. Number expected, ".. type(xOffset) .." passed.", 2)
	elseif type(yOffset) ~= "number" then
		error("Passed \"yOffset\" parameter is not valid. Number expected, ".. type(yOffset) .." passed.", 2)
	elseif type(width) ~= "number" then
		error("Passed \"width\" parameter is not valid. Number expected, ".. type(width) .." passed.", 2)
	elseif type(height) ~= "number" then
		error("Passed \"height\" parameter is not valid. Number expected, ".. type(height) .." passed.", 2)
	end
	
	if not cas._image._hitzoneEffects[effect] then
		error("Passed \"effect\" value does not represent a valid effect.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._hasHitzone then
		error("This image already has a hitzone, remove the hitzone before setting it again.")
	end
	
	self._hasHitzone = true
	
	cas._cs2dCommands.imagehitzone(
		self._id, 
		cas._image._hitzoneEffects[effect] + (stopShot and 100 or 0),
		xOffset,
		yOffset,
		width,
		height)
		
	return self
end

-- Removes hitzone.
function cas._image:removeHitzone()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._hasHitzone then
		error("This image does not have a hitzone.")
	end
	
	self._hasHitzone = false
	
	cas._cs2dCommands.imagehitzone(self._id, 0)
	
	return self
end

-- Sets the position of the image.
function cas._image:setPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This image is being moved, stop the tween function before settings its position.", 2)
	end
	
	self._x = x
	self._y = y
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
	
	return self
end

-- Sets the angle of the image.
function cas._image:setAngle(angle)
	if type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tRotate.active then
		error("This image is being rotated, stop the tween function before setting its angle.", 2)
	elseif self._tRotateConstantly.active then
		error("This image is being rotated constantly, stop the tween function before setting its angle.", 2)
	end
	
	self._angle = angle
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
	
	return self
end

-- Sets the scale of the image.
function cas._image:setScale(scaleX, scaleY)
	if type(scaleX) ~= "number" then
		error("Passed \"scaleX\" parameter is not valid. Number expected, ".. type(scaleX) .." passed.", 2)
	elseif type(scaleY) ~= "number" then
		error("Passed \"scaleY\" parameter is not valid. Number expected, ".. type(scaleY) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tScale.active then
		error("Scale of this image is being changed, stop the tween function before setting its scale.", 2)
	end
	
	self._scaleX = scaleX
	self._scaleY = scaleY
	
	cas._cs2dCommands.imagescale(self._id, self._scaleX, self._scaleY)
	
	return self
end

-- Sets the color of the image.
function cas._image:setColor(color)
	if getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tColor.active then
		error("Color of this image is being changed, stop the tween function before setting its color.", 2)
	end
	
	self._color = color
	
	cas._cs2dCommands.imagecolor(self._id, self._color:getRGB())
	
	return self
end

-- Sets the alpha of the image.
function cas._image:setAlpha(alpha)
	if type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.", 2)
	elseif not (alpha >= 0 and alpha <= 1) then
		error("Passed \"alpha\" value has to be in the range of 0 - 1.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tAlpha.active then
		error("Alpha of this image is being changed, stop the tween function before setting its alpha.", 2)
	end
	
	self._alpha = alpha
	
	cas._cs2dCommands.imagealpha(self._id, self._alpha)
	
	return self
end

-- Sets the blend of the image.
function cas._image:setBlend(blend)
	if type(blend) ~= "string" then
		error("Passed \"blend\" parameter is not valid. String expected, ".. type(blend) .." passed.", 2)
	end
	
	if not cas._image._blendModes[blend] then
		error("Passed \"blend\" value does not represent a valid blend mode.", 2)
	end
	
	self._blend = cas._image._blendModes[blend]
	
	cas._cs2dCommands.imageblend(self._id, self._blend)
	
	return self
end

--== Getters ==--

-- Gets if tween move function is active.
function cas._image:isTweenMove()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tMove.active
end

-- Gets if tween rotate function is active.
function cas._image:isTweenRotate()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tRotate.active
end

-- Gets if tween rotate constantly function is active.
function cas._image:isTweenRotateConstantly()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tRotateConstantly.active
end

-- Gets if tween scale function is active.
function cas._image:isTweenScale()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tScale.active
end

-- Gets if tween color function is active.
function cas._image:isTweenColor()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tColor.active
end

-- Gets if tween alpha function is active.
function cas._image:isTweenAlpha()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._tAlpha.active
end

-- Gets if the image has a hitzone.
function cas._image:hasHitzone()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._hasHitzone
end

-- Gets the position of the image.
function cas._image:getPosition()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		return cas._cs2dCommands.object(self._id, 'x'), cas._cs2dCommands.object(self._id, 'y')
	else
		return self._x, self._y
	end
end

-- Gets the angle of the image.
function cas._image:getAngle()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tRotate.active or self._tRotateConstantly.active then
		local angle = cas._cs2dCommands.object(self._id, 'rot') % 360
		return angle <= 180 and angle or -180 + (angle - 180)
	else
		return self._angle
	end
end

-- Gets the scale of the image.
function cas._image:getScale()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tScale.active then
		local starting, finishing = self._tScale.startingScale, self._tScale.finalScale
		local timerStarted, timerNeeded = self._tScale.timerStartingMS, self._tScale.timerLifetime
		local multiplier = (((os.clock() * 1000) - timerStarted) / timerNeeded)
		return
			starting[1] + (finishing[1] - starting[1]) * multiplier,
			starting[2] + (finishing[2] - starting[2]) * multiplier
	else
		return self._scaleX, self._scaleY
	end
end

-- Gets the color of the image.
function cas._image:getColor()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tColor.active then
		local starting, finishing = self._tColor.startingColor, self._tColor.finalColor
		local timerStarted, timerNeeded = self._tColor.timerStartingMS, self._tColor.timerLifetime
		local multiplier = (((os.clock() * 1000) - timerStarted) / timerNeeded)
		return cas.color.new(
			math.floor(starting[1] + (finishing[1] - starting[1]) * multiplier),
			math.floor(starting[2] + (finishing[2] - starting[2]) * multiplier),
			math.floor(starting[3] + (finishing[3] - starting[3]) * multiplier))
	else
		return self._color
	end
end

-- Gets the alpha of the image.
function cas._image:getAlpha()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tAlpha.active then
		local starting, finishing = self._tAlpha.startingAlpha, self._tAlpha.finalAlpha
		local timerStarted, timerNeeded = self._tAlpha.timerStartingMS, self._tAlpha.timerLifetime
		local multiplier = (((os.clock() * 1000) - timerStarted) / timerNeeded)
		return starting + (finishing - starting) * multiplier
	else
		return self._alpha
	end
end

-- Gets the blend of the image.
function cas._image:getBlend()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	for key, value in pairs(cas._image._blendModes) do
		if self._blend == value then
			return key
		end
	end
end

-- Gets whether or not this image is visible to everyone or only a single player.
function cas._image:isVisibleToEveryone()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._visibleToPlayer == 0
end

-- Gets the player this image is visible to.
function cas._image:getPlayer()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end

	if self._visibleToPlayer == 0 then
		error("This image is visible to everyone.", 2)
	end
	
	return self._visibleToPlayer
end

-------------------
-- Static fields --
-------------------

cas._image._images = setmetatable({}, {__mode = "kv"}) -- Holds the loaded images, also serves as
													   -- a weak table.
cas._image._blendModes = { -- Holds the image blend modes.
	["normal"] = 0,
	["light"] = 1,
	["shade"] = 2,
	["solid"] = 3
}
cas._image._hitzoneEffects = {
	["none"] = 1,
	["wall"] = 2,
	["blood"] = 3,
	["greenblood"] = 4
}

cas._image._debug = cas.debug.new(cas.color.yellow, "CAS Image") -- Debug for image objects.
--cas._image._debug:setActive(true)