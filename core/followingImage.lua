-- Initalizing followingImage class.
cas.followingImage = cas.class(cas._image)

----------------------
-- Instance methods --
----------------------

function cas.followingImage:constructor(path, mode, followedPlayer, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.")
	elseif type(mode) ~= "string" then
		error("Passed \"mode\" parameter is not valid. String expected, ".. type(mode) .." passed.")
	elseif getmetatable(followedPlayer) ~= cas.player then
		error("Passed \"followedPlayer\" parameter is not an instance of the \"cas.player\" class.")
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
	if not cas.followingImage._modes[mode] then
		error("Passed \"mode\" value does not represent a valid mode.")
	end
	
	-- Checks if the followed player exists.
	if not followedPlayer:exists() then
		error("The player of \"followedPlayer\" instance doesn't exist.")
	end
	
	-- Assigning necessary fields.
	self._path = path
	self._mode = 2
	
	self._scaleX = 1
	self._scaleY = 1
	self._angle = 0
	
	self._alpha = 1
	self._blend = 0
	self._color = cas.color.white
	
	self._following = true
	self._followedPlayer = followedPlayer
	
	-- Fields, which are necessary for tween functionality.
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
	self._id = cas._cs2dCommands.image(path, 0, 0, cas.followingImage._modes[mode] + followedPlayer._id, visibleToPlayer ~= 0 and visibleToPlayer._id or 0)
	self._freed = false
	
	-- Adds the image into the "_images" table.
	table.insert(cas.followingImage._images, self)
end

---------------------
-- Instance fields --
---------------------

-- Disabling methods that is relevant to the position of the image.
cas.followingImage.setPosition = nil
cas.followingImage.getPosition = nil
cas.followingImage.tweenMove = nil
cas.followingImage.stopTweenMove = nil

-------------------
-- Static fields --
-------------------

cas.followingImage._modes = {
	["floor"] = 100,
	["top"] = 200,
	["supertop"] = 132
}