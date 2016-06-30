-- Initializing hudText class
cas.hudText = cas.class()

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.hudText:constructor(player, x, y, alignment, ...)
	-- Error checking the arguments
	if getmetatable(player) ~= cas.player then
		error("Passed \"player\" parameter is not an instance of the \"cas.player\" class.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(alignment) ~= "string" then
		error("Passed \"alignment\" parameter is not valid. String expected, ".. type(alignment) .." passed.", 2)
	end
	
	-- Checks if the the passed alignment is valid.
	if not cas.hudText._alignments[alignment] then
		error("Passed \"alignment\" value does not represent a valid alignment.", 2)
	end
	
	-- Checks if the player has left the server.
	if player._left then
		error("Passed \"player\" value represents a player which has left the server.", 2)
	end
	
	-- Checks if all the remaining arguments follow the proper format.
	local arguments = {...}
	local textString = (getmetatable(arguments[1]) == cas.color and "" or tostring(cas.color.new(255, 220, 0)))
	
	for key, value in pairs(arguments) do
		if getmetatable(value) == cas.color then
			textString = textString .. tostring(value)
		elseif type(value) == "string" then
			textString = textString .. value
		else
			error("Argument #".. key + 4 .." should either be an instance of the cas.color class or a string.", 2)
		end
	end
	
	-- Checking if the limit for hud texts was reached.
	local hudTexts = 0
	for key, value in pairs(cas.hudText._hudTexts[player._id]) do
		hudTexts = hudTexts + 1
	end
	if hudTexts >= 50 then
		error("The limit of possible hud texts has been reached for this player.", 2)
	end
	
	-- Looking up the unused ID.
	for id = 0, 49 do
		if not cas.hudText._hudTexts[player:getSlotID()][id] then
			self._id = id
			cas.hudText._hudTexts[player:getSlotID()][id] = self
			break
		end
	end
	
	-- Setting up the fields.
	self._player = player
	self._x = x
	self._y = y
	self._alpha = 1
	self._alignment = alignment
	self._text = textString
	self._freed = false
	self._color = (getmetatable(arguments[1]) == cas.color and arguments[1] or cas.color.new(255, 220, 0))
	
	-- Fields, which are necessary for tween functionality.
	self._tMove = {
		active = false, -- Whether or not this tween function is active.
		finalPosition = {0, 0}, -- Sets the final (wanted) result of the tween function.
		startingPosition = {0, 0}, -- Starting parameters of the tween function.
		timerStartingMS = 0, -- Defines the millisecond the tween function started on.
		timerLifetime = 0, -- Defines the time (in ms) during which the tween function has to do its job.
		timer = cas.timer.new(function(self) -- The timer function, which updates the fields upon
											 -- finising the tween function.
			self._tMove.active = false 
			self._x = self._tMove.finalPosition[1]
			self._y = self._tMove.finalPosition[2]
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
	
	-- Showing the hudtext.
	cas.console.parse("hudtxt2", self._player:getSlotID(), self._id, textString, x, y, cas.hudText._alignments[alignment])
end

function cas.hudText:destructor()
	if not self._freed then
		self:free()
	end
end

-- Frees the hud text.
function cas.hudText:free()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	-- Frees the hud text.
	cas.console.parse("hudtxt2", self._player:getSlotID(), self._id)
	self._freed = true
	
	-- Finds it in the "_hudTexts" table of the player and removes it.
	for key, value in pairs(cas.hudText._hudTexts[self._player:getSlotID()]) do
		if value == self then
			cas.hudText._hudTexts[self._player:getSlotID()][key] = nil
			return
		end
	end
		
	-- This error should usually never happen. It does happen when someone has modified this code or 
	-- the code itself has bugs. Make sure you don't try to access the fields starting with 
	-- underscore ("_") directly and instead use setters/getters for hud text manipulation as it can
	-- lead to bugs.
	error("Field \"_freed\" of this instance was set to false yet it wasn't found in the \"_hudText\" table.", 2)
end

--== Tween functions, starters ==--

-- Tween move.
function cas.hudText:tweenMove(time, x, y)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This hud text is already being moved.", 2)
	end
	
	self._tMove.active = true
	self._tMove.finalPosition = {x, y}
	self._tMove.startingPosition = {self._x, self._y}
	self._tMove.timerStartingMS = os.clock() * 1000
	self._tMove.timerLifetime = time
	cas.console.parse("hudtxtmove", self._player:getSlotID(), self._id, time, x, y)
	self._tMove.timer:start(time, 1, self)
	
	return self
end

-- Tween color.
function cas.hudText:tweenColor(time, color)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tColor.active then
		error("Color of this hud text is already being changed.", 2)
	end
	
	self._tColor.active = true
	self._tColor.finalColor = {color:getRGB()}
	self._tColor.startingColor = {self._color:getRGB()}
	self._tColor.timerStartingMS = os.clock() * 1000
	self._tColor.timerLifetime = time
	cas.console.parse("hudtxtcolorfade", self._player:getSlotID(), self._id, time, color:getRGB())
	self._tColor.timer:start(time, 1, self)
	
	return self
end

-- Tween alpha.
function cas.hudText:tweenAlpha(time, alpha)
	if type(time) ~= "number" then
		error("Passed \"time\" parameter is not valid. Number expected, ".. type(time) .." passed.", 2)
	elseif type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tAlpha.active then
		error("Alpha of this hud text is already being changed.", 2)
	end
	
	self._tAlpha.active = true
	self._tAlpha.finalAlpha = alpha
	self._tAlpha.startingAlpha = self._alpha
	self._tAlpha.timerStartingMS = os.clock() * 1000
	self._tAlpha.timerLifetime = time
	cas.console.parse("hudtxtalphafade", self._player:getSlotID(), self._id, time, alpha)
	self._tAlpha.timer:start(time, 1, self)
	
	return self
end

--== Tween functions, stoppers ==--

-- Stop tween move.
function cas.hudText:stopTweenMove()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tMove.active then
		error("This hud text is not being moved.", 2)
	end
	
	local nx, ny = self:getPosition()
	cas.console.parse("hudtxtmove", self._player:getSlotID(), self._id, 0, nx, ny)
	self._x = nx
	self._y = ny
	self._tMove.timer:stop()
	self._tMove.active = false
	
	return self
end

-- Stop tween color.
function cas.hudText:stopTweenColor()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tColor.active then
		error("Color of this hud text is not being changed.", 2)
	end
	
	local color = self:getColor()
	cas.console.parse("hudtxtcolorfade", self._player:getSlotID(), self._id, 0, color:getRGB())
	self._color = color
	self._tColor.timer:stop()
	self._tColor.active = false
	
	return self
end

-- Stop tween alpha.
function cas.hudText:stopTweenAlpha()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if not self._tAlpha.active then
		error("Alpha of this hud text is not being changed.", 2)
	end
	
	cas.console.parse("hudtxtalphafade", self._player:getSlotID(), self._id, 0, self:getAlpha())
	self._alpha = self:getAlpha()
	self._tAlpha.timer:stop()
	self._tAlpha.active = false
	
	return self
end

--== Setters ==--

-- Sets the text of the hudText.
function cas.hudText:setText(...)
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	local arguments = {...}
	local textString = ""
	
	for key, value in pairs(arguments) do
		if getmetatable(value) == cas.color then
			textString = textString .. tostring(value)
		elseif type(value) == "string" then
			textString = textString .. value
		else
			error("Argument #".. key + 4 .." should either be an instance of the cas.color class or a string.", 2)
		end
	end
	
	self._text = textString
	cas.console.parse("hudtxt2", self._player:getSlotID(), self._id, textString, self._x, self._y, 0)
	
	return self
end

-- Sets the position of the hudText.
function cas.hudText:setPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This hud text is being moved, stop the tween function before settings its position.", 2)
	end
	
	self._x = x
	self._y = y
	cas.console.parse("hudtxtmove", self._player:getSlotID(), self._id, 0, x, y)
	
	return self
end

-- Sets the position of the hudText on the X axis.
function cas.hudText:setX(x)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This hud text is being moved, stop the tween function before settings its position.", 2)
	end
	
	self:setPosition(x, self._y)
	
	return self
end

-- Sets the position of the hudText on the Y axis.
function cas.hudText:setY(y)
	if type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		error("This hud text is being moved, stop the tween function before settings its position.", 2)
	end
	
	self:setPosition(self._x, y)
	
	return self
end

-- Sets the color of the hudText (only the first colored segement in multi-colored hud text).
function cas.hudText:setColor(color)
	if getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tColor.active then
		error("Color of this hud text is being changed, stop the tween function before setting its color.", 2)
	end
	
	self._color = color
	cas.console.parse("hudtxtcolorfade", self._player, self._id, 0, color:getRGB())
	
	return self
end

-- Sets the alpha of the hudText.
function cas.hudText:setAlpha(alpha)
	if type(alpha) ~= "number" then
		error("Passed \"alpha\" parameter is not valid. Number expected, ".. type(alpha) .." passed.", 2)
	elseif not (alpha >= 0 and alpha <= 1) then
		error("Passed \"alpha\" value has to be in the range of 0 - 1.", 2)
	end
	
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tAlpha.active then
		error("Alpha of this hud text is being changed, stop the tween function before setting its alpha.", 2)
	end
	
	self._alpha = alpha
	cas.console.parse("hudtxtalphafade", self._player:getSlotID(), self._id, 0, alpha)
	
	return self
end


--== Getters ==--

-- Gets the text of the hudText.
function cas.hudText:getText()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	return self._text
end

-- Gets the position of the hudText.
function cas.hudText:getPosition()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	if self._tMove.active then
		local starting, finishing = self._tMove.startingPosition, self._tMove.finalPosition
		local timerStarted, timerNeeded = self._tMove.timerStartingMS, self._tMove.timerLifetime
		local multiplier = (((os.clock() * 1000) - timerStarted) / timerNeeded)
		return
			starting[1] + (finishing[1] - starting[1]) * multiplier,
			starting[2] + (finishing[2] - starting[2]) * multiplier
	else
		return self._x, self._y
	end
end

-- Gets the position of the hudText on the X axis.
function cas.hudText:getX()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	local x, _ = self:getPosition()
	return x
end

-- Gets the position of the hudText on the Y axis.
function cas.hudText:getY()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
	end
	
	local _, y = self:getPosition()
	return y
end

-- Gets the color of the hudText (only the first colored segement in multi-colored hud text).
function cas.hudText:getColor()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
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

-- Gets the alpha of the hudText.
function cas.hudText:getAlpha()
	if self._freed then
		error("This hud text was already freed. It's better if you dispose of this instance.", 2)
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

-------------------
-- Static fields --
-------------------

cas.hudText._alignments = { -- Possible alignments.
	["left"] = 0,
	["center"] = 1,
	["right"] = 2
}
cas.hudText._hudTexts = {} -- Table which holds all the hud texts of the players.
for id = 1, 32 do
	cas.hudText._hudTexts[id] = setmetatable({}, {__mode = "kv"}) -- Giving each player its own hudText table and making 
																  -- the table weak.
end