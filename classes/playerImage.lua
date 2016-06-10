-- Initalizing playerImage class.
cas.playerImage = cas.class(cas._image) -- Inherits from cas._image.

----------------------
-- Instance methods --
----------------------

function cas.playerImage:constructor(path, mode, followedPlayer, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	elseif type(mode) ~= "string" then
		error("Passed \"mode\" parameter is not valid. String expected, ".. type(mode) .." passed.", 2)
	elseif getmetatable(followedPlayer) ~= cas.player then
		error("Passed \"followedPlayer\" parameter is not an instance of the \"cas.player\" class.", 2)
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= cas.player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"cas.player\" class.", 2)
		end
		
		if visibleToPlayer._left then
			error("The player of this instance has already left the server. It's better if you dispose of this instance.", 2)
		end
 	end
	
	-- Checks if the passed mode exists.
	if not cas.playerImage._modes[mode] then
		error("Passed \"mode\" value does not represent a valid mode.", 2)
	end
	
	-- Checks if the followed player exists.
	if followedPlayer._left then
		error("The player of this instance has already left the server. It's better if you dispose of this instance.", 2)
	end
	
	-- Calling parent's constructor.
	self:super(path, cas.playerImage._modes[mode] + followedPlayer._id, visibleToPlayer)
	
	self._followedPlayer = followedPlayer
end

---------------------
-- Instance fields --
---------------------

-- Disabling methods that is relevant to the position of the image.
function cas.playerImage:setPosition()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	error("Cannot set position. This image is following a player.", 2)
end

function cas.playerImage:getPosition()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._followedPlayer:getPosition()
end

function cas.playerImage:tweenMove()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	error("Cannot perform \"tweenMove\" function. This image is following a player.", 2)
end

-- Overriding tween rotate method so that it won't be possible to do if the image is being 
-- rotated with the player.
function cas.playerImage:tweenRotate(time, angle)
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self:isRotatingWithPlayer() then
		error("This image is being rotated with player, thus it's impossible to use \"tweenRotate\" function.", 2)
	end
	
	self.super.tweenRotate(self, time, angle)
end

--== Getters ==--

-- Gets whether or not the image is covered by FOW.
function cas.playerImage:isCoveredByFOW()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.object(self._id, 'y') <= 0
end

-- Gets whether or not the image is rotating with player.
function cas.playerImage:isRotatingWithPlayer()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return cas._cs2dCommands.object(self._id, 'x') > 0
end

-- Gets whether or not the image is wiggling with player.
function cas.playerImage:isWiggling()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self:isRotatingWithPlayer() then
		error("This image is not rotating with player, thus not wiggling.", 2)
	end
	
	return cas._cs2dCommands.object(self._id, 'x') >= 2
end

-- Gets the angle of the player image.
function cas.playerImage:getAngle()
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self:isRotatingWithPlayer() then
		return self._followedPlayer:getAngle()
	else
		return self.super.getAngle(self)
	end
end

--== Setters ==--

-- Sets whether or not the image is covered by FOW.
function cas.playerImage:setCoveredByFOW(covered)
	if type(covered) ~= "boolean" then
		error("Passed \"covered\" parameter is not valid. Boolean expected, ".. type(covered) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	cas._cs2dCommands.imagepos(
		self._id, 
		cas._cs2dCommands.object(self._id, 'x'), 
		covered and 0 or 1, 
		cas._cs2dCommands.object(self._id, 'rot'))
end

-- Sets whether or not the image is rotating with player.
function cas.playerImage:setRotatingWithPlayer(rotating)
	if type(rotating) ~= "boolean" then
		error("Passed \"rotating\" parameter is not valid. Boolean expected, ".. type(rotating) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tRotate.active then
		error("This image is being rotated.", 2)
	elseif self._tRotateConstantly.active then
		error("This image is being rotated constantly.", 2)
	end
	
	cas._cs2dCommands.imagepos(
		self._id,
		rotating and 1 or 0,
		cas._cs2dCommands.object(self._id, 'y'),
		cas._cs2dCommands.object(self._id, 'rot'))
end

-- Sets whether or not the image is wiggling with player.
function cas.playerImage:setWiggling(wiggling)
	if type(wiggling) ~= "boolean" then
		error("Passed \"wiggling\" parameter is not valid. Boolean expected, ".. type(wiggling) .." passed.", 2)
	end
	
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self:isRotatingWithPlayer() then
		error("This image is not rotating with player, thus cannot wiggle.", 2)
	end
	
	cas._cs2dCommands.imagepos(
		self._id, 
		wiggling and 2 or 1, 
		cas._cs2dCommands.object(self._id, 'y'), 
		cas._cs2dCommands.object(self._id, 'rot'))
end

-- Overriding the set angle method so that it would be impossible to use if the image is rotating
-- with player.
function cas.playerImage:setAngle(angle)
	if self._freed then
		error("This image was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self:isRotatingWithPlayer() then
		error("This image is being rotated with player, thus it's impossible to set its angle.", 2)
	end
	
	self.super.setAngle(self, angle)
end

-------------------
-- Static fields --
-------------------

-- Player image modes.
cas.playerImage._modes = {
	["floor"] = 100,
	["top"] = 200,
	["supertop"] = 132
}