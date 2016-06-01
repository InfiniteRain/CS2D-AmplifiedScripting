-- Initializing the _image class
cas._image = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the image instance from the passed image ID.
function cas._image.getInstance(imageID) 
	if type(imageID) ~= "number" then
		error("Passed \"imageID\" parameter is not valid. Number expected, ".. type(imageID) .." passed.")
	end

	for key, value in pairs(cas._image._images) do
		if imageID == value._id then
			return value
		end
	end
	
	error("Passed \"imageID\" parameter represents a non-existent image.")
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
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.")
	elseif type(mode) ~= "number" then
		error("Passed \"mode\" parameter is not valid. Number expected, ".. type(mode) .." passed.")
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= cas.player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"cas.player\" class.")
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
	if not ((mode >= 0 and mode <= 3) or (mode >= 101 and mode <= 164) or (mode >= 201 and mode <= 232)) then
		error("Passed \"mode\" value does not represent a valid mode.")
	end
	
	-- Assigning necessary fields.
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
end

-- Destructor.
function cas._image:destructor()
	if not self._freed then
		self:free() -- Freeing the image upon garbage collection.
	end
end

-- Frees the image and removes it from the "_images" table. "_images" table is necessary to free
-- every image on startround.
function cas._image:free()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
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
	local found = false
	for key, value in pairs(cas._image._images) do
		if value == self then
			cas._image._images[key] = nil
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

-- Tween move
function cas._image:tweenMove(time, x, y)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tMove.active then
		error("This image is already being moved.")
	end
	
	self._tMove.active = true
	self._tMove.finalPosition = {x, y}
	cas._cs2dCommands.tween_move(self._id, time, x, y)
	self._tMove.timer:start(time, 1, self)
end

-- Tween rotate.
function cas._image:tweenRotate(time, angle)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotate.active then
		error("This image is already being rotated.")
	elseif self._tRotateConstantly.active then
		error("This image is already being rotated, but constantly.")
	end
	
	self._tRotate.active = true
	self._tRotate.finalAngle = angle
	cas._cs2dCommands.tween_rotate(self._id, time, angle)
	self._tRotate.timer:start(time, 1, self)
end

-- Tween rotate constantly.
function cas._image:tweenRotateConstantly(speed)
	if type(speed) ~= "number" then
		error("Passed \"speed\" parameter is not valid. Number expected, ".. type(speed) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotateConstantly.active then
		error("This image is already being rotated constantly.")
	elseif self._tRotate.active then
		error("This image is already being rotated, but not constantly.")
	end
	
	self._tRotateConstantly.active = true
	cas._cs2dCommands.tween_rotateconstantly(self._id, speed)
end

-- Tween scale.
function cas._image:tweenScale(time, scaleX, scaleY)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(scaleX) ~= "number" then
		error("Passed \"scaleX\" parameter is not valid. Number expected, ".. type(scaleX) .." passed.")
	elseif type(scaleY) ~= "number" then
		error("Passed \"scaleY\" parameter is not valid. Number expected, ".. type(scaleY) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tScale.active then
		error("Scale of this image is already being changed.")
	end
	
	self._tScale.active = true
	self._tScale.finalScale = {scaleX, scaleY}
	self._tScale.startingScale = {self._scaleX, self._scaleY}
	self._tScale.timerStartingMS = os.clock() * 1000
	self._tScale.timerLifetime = time
	cas._cs2dCommands.tween_scale(self._id, time, scaleX, scaleY)
	self._tScale.timer:start(time, 1, self)
end

-- Tween color.
function cas._image:tweenColor(time, color)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tColor.active then
		error("Color of this image is already being changed.")
	end
	
	self._tColor.active = true
	self._tColor.finalColor = {color:getRGB()}
	self._tColor.startingColor = {self._color:getRGB()}
	self._tColor.timerStartingMS = os.clock() * 1000
	self._tColor.timerLifetime = time
	cas._cs2dCommands.tween_color(self._id, time, color:getRGB())
	self._tColor.timer:start(time, 1, self)
end

-- Tween alpha.
function cas._image:tweenAlpha(time, alpha)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.")
	elseif type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tAlpha.active then
		error("Alpha of this image is already being changed.")
	end
	
	self._tAlpha.active = true
	self._tAlpha.finalAlpha = alpha
	self._tAlpha.startingAlpha = self._alpha
	self._tAlpha.timerStartingMS = os.clock() * 1000
	self._tAlpha.timerLifetime = time
	cas._cs2dCommands.tween_alpha(self._id, time, alpha)
	self._tAlpha.timer:start(time, 1, self)
end

--== Tween functions, stoppers ==--

-- Stop tween move.
function cas._image:stopTweenMove()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tMove.active then
		error("This image is not being moved.")
	end
	
	local nx, ny = self:getPosition()
	cas._cs2dCommands.tween_move(self._id, 0, nx, ny)
	self._x = nx
	self._y = ny
	self._tMove.timer:stop()
	self._tMove.active = false
end

-- Stop tween rotate.
function cas._image:stopTweenRotate()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tRotate.active then
		if self._tRotateConstantly.active then
			error("This image is not being rotated constantly.")
		else
			error("This image is not being rotated.")
		end
	end
	
	cas._cs2dCommands.tween_rotate(self._id, 0, self:getAngle())
	self._angle = self:getAngle()
	self._tRotate.timer:stop()
	self._tRotate.active = false
end

-- Stop tween rotate constantly.
function cas._image:stopTweenRotateConstantly()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tRotateConstantly.active then
		error("This image is not being rotated constantly.")
	end
	
	cas._cs2dCommands.tween_rotateconstantly(self._id, 0)
	self._angle = self:getAngle()
	self._tRotateConstantly.active = false
end

-- Stop tween scale.
function cas._image:stopTweenScale()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tScale.active then
		error("Scale of this image is not being changed.")
	end
	
	local scaleX, scaleY = self:getScale()
	cas._cs2dCommands.tween_scale(self._id, 0, scaleX, scaleY)
	self._scaleX = scaleX
	self._scaleY = scaleY
	self._tScale.timer:stop()
	self._tScale.active = false
end

-- Stop tween color.
function cas._image:stopTweenColor()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tColor.active then
		error("Color of this image is not being changed.")
	end
	
	local color = self:getColor()
	cas._cs2dCommands.tween_color(self._id, 0, color:getRGB())
	self._color = color
	self._tColor.timer:stop()
	self._tColor.active = false
end

-- Stop tween alpha.
function cas._image:stopTweenAlpha()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if not self._tAlpha.active then
		error("Alpha of this image is not being changed.")
	end
	
	cas._cs2dCommands.tween_alpha(self._id, 0, self:getAlpha())
	self._alpha = self:getAlpha()
	self._tAlpha.timer:stop()
	self._tAlpha.active = false
end

--== Setters ==--

-- Sets the position of the image.
function cas._image:setPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tMove.active then
		error("This image is being moved, stop the tween function before settings its position.")
	end
	
	self._x = x
	self._y = y
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
	
	return self
end

-- Sets the angle of the image.
function cas._image:setAngle(angle)
	if type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tRotate.active then
		error("This image is being rotated, stop the tween function before setting its angle.")
	elseif self._tRotateConstantly.active then
		error("This image is being rotated constantly, stop the tween function before setting its angle.")
	end
	
	self._angle = angle
	
	cas._cs2dCommands.imagepos(self._id, self._x, self._y, self._angle)
	
	return self
end

-- Sets the scale of the image.
function cas._image:setScale(scaleX, scaleY)
	if type(scaleX) ~= "number" then
		error("Passed \"scaleX\" parameter is not valid. Number expected, ".. type(scaleX) .." passed.")
	elseif type(scaleY) ~= "number" then
		error("Passed \"scaleY\" parameter is not valid. Number expected, ".. type(scaleY) .." passed.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tScale.active then
		error("Scale of this image is being changed, stop the tween function before setting its scale.")
	end
	
	self._scaleX = scaleX
	self._scaleY = scaleY
	
	cas._cs2dCommands.imagescale(self._id, self._scaleX, self._scaleY)
	
	return self
end

-- Sets the color of the image.
function cas._image:setColor(color)
	if getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tColor.active then
		error("Color of this image is being changed, stop the tween function before setting its color.")
	end
	
	self._color = color
	
	cas._cs2dCommands.imagecolor(self._id, self._color:getRGB())
	
	return self
end

-- Sets the alpha of the image.
function cas._image:setAlpha(alpha)
	if type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.")
	elseif not (alpha >= 0 and alpha <= 1) then
		error("Passed \"alpha\" value has to be in the range of 0 - 1.")
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	if self._tAlpha.active then
		error("Alpha of this image is being changed, stop the tween function before setting its alpha.")
	end
	
	self._alpha = alpha
	
	cas._cs2dCommands.imagealpha(self._id, self._alpha)
	
	return self
end

-- Sets the blend of the image.
function cas._image:setBlend(blend)
	if type(blend) ~= "string" then
		error("Passed \"blend\" parameter is not valid. String expected, ".. type(blend) .." passed.")
	end
	
	if not cas._image._blendModes[blend] then
		error("Passed \"blend\" value does not represent a valid blend mode.")
	end
	
	self._blend = cas._image._blendModes[blend]
	
	cas._cs2dCommands.imageblend(self._id, self._blend)
	
	return self
end

--== Getters ==--

-- Gets the position of the image.
function cas._image:getPosition()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
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
		error("This image was already freed. It's better if you dispose of this instance.")
	end
	
	return self._visibleToPlayer == 0
end

-- Gets the player this image is visible to.
function cas._image:getPlayer()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.")
	end

	if self._visibleToPlayer == 0 then
		error("This image is visible to everyone.")
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

-- Hook which frees all the image upon start round.
cas._image._imageStartroundHook = {}
cas._image._imageStartroundHook.func = function(mode)
	for key, value in pairs(cas._image._images) do
		value._freed = true
	end
	cas._image._images = setmetatable({}, {__mode = "kv"})
end
cas._image._imageStartroundHook.hook = cas.hook.new("startround", cas._image._imageStartroundHook.func, -9999, "_imageStartround")

-- Hook which frees all the image associated with a single player (either following them or visible
-- only to them.)
cas._image._imageLeaveHook = {}
cas._image._imageLeaveHook.func = function(player, reason)
	for key, value in pairs(cas._image._images) do
		if not value:isVisibleToEveryone() then
			if value:getPlayer() == player then
				value:free()
			end
		end
		
		
	end
end

-- Hook which frees all the images which are player dependant. For example, if the image is visible
-- only to a player or is following one.
cas._image._imageLeaveHook = {}