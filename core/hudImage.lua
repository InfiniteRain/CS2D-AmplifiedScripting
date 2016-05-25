-- Initalizing hudImage class.
cas.hudImage = {}
cas.hudImage.__index = cas.hudImage

setmetatable(cas.hudImage, {__index = cas._image}) -- Inherit from base image class.

--------------------
-- Static methods --
--------------------

function cas.hudImage.new(path, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if not path then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.")
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
	
	-- Creates the instance itself.
	local self = {}
	setmetatable(self, cas.hudImage)
	
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
	self._id = cas._cs2dCommands.image(path, 0, 0, 2, visibleToPlayer)
	self._freed = false
	
	-- Adds the image into the "_images" table.
	table.insert(cas.mapImage._images, self)
	
	return self
end

-------------------
-- Static fields --
-------------------