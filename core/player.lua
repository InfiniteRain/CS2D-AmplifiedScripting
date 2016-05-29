-- Initializing the cas.player class.
cas.player = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the player instance from the passed player ID.
function cas.player.getInstance(playerID)
	if not playerID then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(playerID) ~= "number" then
		error("Passed \"playerID\" parameter is not valid. Number expected, ".. type(playerID) .." passed.")
	elseif not cas._cs2dCommands.player(playerID, 'exists') then
		error("Passed \"playerID\" parameter represents a non-existent player.")
	end
	
	for key, value in pairs(cas.player._instances) do
		if value._id == playerID then
			return value
		end
	end
	
	cas.player._allowCreation = true
	local player = cas.player.new(playerID)
	cas.player._allowCreation = false
	
	return player
end

-- Returns a table of all the players on the server.
function cas.player.getPlayers()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'table')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

-- Returns a table of all the currently living players.
function cas.player.getLivingPlayers()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'tableliving')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

-- Returns a table of all the terrorists.
function cas.player.getTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team1')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

-- Returns a table of all the counter terrorists.
function cas.player.getCounterTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team2')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

-- Returns the table of all the living terrorists. 
function cas.player.getLivingTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team1living')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

-- Returns the table of all the living counter terrorists. 
function cas.player.getLivingCounterTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team2living')) do
		table.insert(cas.player.getObject(value))
	end
	
	return players
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a player object with corresponding ID.
function cas.player:constructor(playerID)
	if not playerID then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(playerID) ~= "number" then
		error("Passed \"playerID\" parameter is not valid. Number expected, ".. type(playerID) .." passed.")
	elseif not cas._cs2dCommands.player(playerID, 'exists') then
		error("Passed \"playerID\" parameter represents a non-existent player.")
	end
	
	if not cas.player._allowCreation then
		error("Instantiation of this class is not allowed.")
	end
	
	for key, value in pairs(cas.player._instances) do
		if value._id == playerID then
			error("Instance with the same player ID already exists.")
		end
	end
	
	self._id = playerID
	table.insert(cas.player._instances, self)
end

-- Destructor.
function cas.player:destructor()
	for key, value in pairs(cas.player._instances) do
		if value._id == self._id then
			-- Removes the player from the cas.player._instances table.
			cas.player._instances[key] = nil
		end
	end
end

--== Getters ==--

-- Gets the slot ID of the player.
function cas.player:getSlotID()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return self._id
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on "player" function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cas.player:exists()
	return cas._cs2dCommands.player(self._id, 'exists')
end

function cas.player:getName()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'name')
end

function cas.player:getIP()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'ip')
end

function cas.player:getPort()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'port')
end

function cas.player:getUSGN()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	local usgn = cas._cs2dCommands.player(self._id, 'usgn')
	return usgn ~= 0 and usgn or false
end

function cas.player:getPing()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'ping')
end

function cas.player:getIdleTime()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'idle')
end

function cas.player:isBot()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'bot')
end

function cas.player:getTeam()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'team')
end

function cas.player:getSkin()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'look')
end

function cas.player:getPosition()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return 
		cas._cs2dCommands.player(self._id, 'x'),
		cas._cs2dCommands.player(self._id, 'y')
end

function cas.player:getX()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'x')
end

function cas.player:getY()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'y')
end

function cas.player:getAngle()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'rot')
end

function cas.player:getTilePosition()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return 
		cas._cs2dCommands.player(self._id, 'tilex'),
		cas._cs2dCommands.player(self._id, 'tiley')
end

function cas.player:getTileX()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'tilex')
end

function cas.player:getTileY()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'tiley')
end

function cas.player:getHealth()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'health')
end

function cas.player:getArmor()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'armor')
end

function cas.player:getMoney()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'money')
end

function cas.player:getScore()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'score')
end

function cas.player:getDeaths()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'deaths')
end

function cas.player:getTeamKills()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'teamkills')
end

function cas.player:getHostageKills()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'hostagekills')
end

function cas.player:getTeamBuildingKills()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'teambuildingkills')
end

function cas.player:getWeaponType()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'weapontype')
end

function cas.player:hasNightvision()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'nightvision')
end

function cas.player:hasDefuseKit()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'defusekit')
end

function cas.player:hasGasmask()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'gasmask')
end

function cas.player:hasBomb()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'bomb')
end

function cas.player:hasFlag()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'flag')
end

function cas.player:isReloading()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'reloading')
end

function cas.player:getCurrentProcess()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'process')
end

function cas.player:getSprayName()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'sprayname')
end

function cas.player:getSprayColor()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'spraycolor')
end

function cas.player:getKickVote()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	local player = cas._cs2dCommands.player(self._id, 'votekick')
	return player ~= 0 and cas.player.getObject(player) or false
end

function cas.player:getMapVote()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	local map = cas._cs2dCommands.player(self._id, 'votemap')
	return map ~= "" and map or false
end

function cas.player:getFavoriteTeam()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'favteam')
end

function cas.player:getSpeed()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'speedmod')
end

function cas.player:getMaxHealth()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'maxhealth')
end

function cas.player:isRcon()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'rcon')
end

function cas.player:getFlashedTime()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	return cas._cs2dCommands.player(self._id, 'ai_flash')
end

--== Setters/control ==--

function cas.player:IPBan(duration, reason)
	if duration then
		if type(duration) == "number" and not (duration >= 1 and duration <= 1440) then
			error("Passed \"duration\" value (as a number) has to be in the range of 1 and 1440.")
		elseif type(duration) == "string" and not (duration == "permanent" or duration == "default") then
			error("Passed \"duration\" value (as a string) has to be either \"permanent\" or \"default\".")
		else
			error("Passed \"duration\" parameter is not valid. Number or string expected, ".. type(duration) .." passed.")
		end
	end
	if reason then
		if type(reason) ~= "string" then
			error("Passed \"reason\" parameter is not valid. String expected, ".. type(reason) .." passed.")
		end
	end
	
	if duration == "permanent" then
		cas.console.parse("banip", self:getIP(), 0, reason)
	elseif duration == "default" then
		cas.console.parse("banip", self:getIP(), -1, reason)
	else
		cas.console.parse("banip", self:getIP(), duration, reason)
	end
end

function cas.player:nameBan(duration, reason)
	if duration then
		if type(duration) == "number" and not (duration >= 1 and duration <= 1440) then
			error("Passed \"duration\" value (as a number) has to be in the range of 1 and 1440.")
		elseif type(duration) == "string" and not (duration == "permanent" or duration == "default") then
			error("Passed \"duration\" value (as a string) has to be either \"permanent\" or \"default\".")
		else
			error("Passed \"duration\" parameter is not valid. Number or string expected, ".. type(duration) .." passed.")
		end
	end
	if reason then
		if type(reason) ~= "string" then
			error("Passed \"reason\" parameter is not valid. String expected, ".. type(reason) .." passed.")
		end
	end
	
	if duration == "permanent" then
		cas.console.parse("banname", self:getName(), 0, reason)
	elseif duration == "default" then
		cas.console.parse("banname", self:getName(), -1, reason)
	else
		cas.console.parse("banname", self:getName(), duration, reason)
	end
end

function cas.player:usgnBan(duration, reason)
	if duration then
		if type(duration) == "number" and not (duration >= 1 and duration <= 1440) then
			error("Passed \"duration\" value (as a number) has to be in the range of 1 and 1440.")
		elseif type(duration) == "string" and not (duration == "permanent" or duration == "default") then
			error("Passed \"duration\" value (as a string) has to be either \"permanent\" or \"default\".")
		else
			error("Passed \"duration\" parameter is not valid. Number or string expected, ".. type(duration) .." passed.")
		end
	end
	if reason then
		if type(reason) ~= "string" then
			error("Passed \"reason\" parameter is not valid. String expected, ".. type(reason) .." passed.")
		end
	end
	
	if not self:getUSGN() then
		error("This player is not logged in.")
	end
	
	if duration == "permanent" then
		cas.console.parse("banusgn", self:getUSGN(), 0, reason)
	elseif duration == "default" then
		cas.console.parse("banusgn", self:getUSGN(), -1, reason)
	else
		cas.console.parse("banusgn", self:getUSGN(), duration, reason)
	end
end

function cas.player:consoleMessage(message, color)
	if not message then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(message) .." passed.")
	end
	if color then
		if getmetatable(color) ~= cas.color then
			error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
		end
	end
	
	cas.console.parse("cmsg", (color and tostring(color) or "") .. message, self._id)
end

function cas.player:customKill(killer, weapon, weaponImage)
	if not (killer ~= nil and weapon) then
		error("Less than 2 parameters were passed, expected at least 2 parameters.")
	elseif not (killer == false or getmetatable(killer) == cas.player) then
		error("Passed \"killer\" parameter is not valid. False or instance of \"cas.player\" expected.")
	elseif type(weapon) ~= "string" then
		error("Passed \"weapon\" parameter is not valid. String expected, ".. type(weapon) .." passed.")
	end
	if weaponImage then
		if type(weaponImage) ~= "string" then
			error("Passed \"weaponImage\" parameter is not valid. String expected, ".. type(weaponImage) .." passed.")
		end
	end
	
	if self:getHealth() <= 0 then
		error("This player is already dead.")
	end
	
	-- Checks if the weapon image exists.
	if weaponImage then
		local file = io.open(weaponImage, 'r')
		if file == nil then
			error("Could not load image at \"".. weaponImage .."\".")
		else
			file:close()
		end
	end
	
	cas.console.parse("customkill", killer and killer._id or 0, weapon .. (weaponImage and ",".. weaponImage or ""), self._id)
end

function cas.player:equip(itemType)
	if not itemType then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif getmetatable(itemType) ~= cas.itemType then
		error("Passed \"itemType\" parameter is not an instance of the \"cas.itemType\" class.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("equip", self._id, itemType._typeId)
end

function cas.player:flash(intentsity)
	if not intentsity then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(intentsity) ~= "number" then
		error("Passed \"intentsity\" parameter is not valid. Number expected, ".. type(intentsity) .." passed.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("flashplayer", self._id, intentsity)
end

function cas.player:kick(reason)
	if reason then
		if type(reason) ~= "string" then
			error("Passed \"reason\" parameter is not valid. String expected, ".. type(reason) .." passed.")
		end
	end
	
	cas.console.parse("kick", self._id, reason)
end

function cas.player:kill()
	if self:getHealth() <= 0 then
		error("This player is already dead.")
	end
	
	cas.console.parse("killplayer", self._id)
end

-------------------
-- Static fields --
-------------------

cas.player._allowCreation = false
cas.player._instances = setmetatable({}, {__mode = "kv"})