-- Initializing the cas.player class.
cas.player = cas.class()

--------------------
-- Static methods --
--------------------

-- Returns the player instance from the passed player ID.
function cas.player.getInstance(playerID)
	if type(playerID) ~= "number" then
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
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

-- Returns a table of all the currently living players.
function cas.player.getLivingPlayers()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'tableliving')) do
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

-- Returns a table of all the terrorists.
function cas.player.getTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team1')) do
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

-- Returns a table of all the counter terrorists.
function cas.player.getCounterTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team2')) do
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

-- Returns the table of all the living terrorists. 
function cas.player.getLivingTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team1living')) do
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

-- Returns the table of all the living counter terrorists. 
function cas.player.getLivingCounterTerrorists()
	local players = {}
	for key, value in pairs(cas._cs2dCommands.player(0, 'team2living')) do
		table.insert(players, cas.player.getInstance(value))
	end
	
	return players
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a player instance with corresponding ID.
function cas.player:constructor(playerID)
	if type(playerID) ~= "number" then
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
	return player ~= 0 and cas.player.getInstance(player) or false
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
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
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
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
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
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
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
	if type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(message) .." passed.")
	end
	if color then
		if getmetatable(color) ~= cas.color then
			error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.")
		end
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("cmsg", (color and tostring(color) or "") .. message, self._id)
end

function cas.player:customKill(killer, weapon, weaponImage)
	if not (killer == false or getmetatable(killer) == cas.player) then
		error("Passed \"killer\" parameter is not valid. False or instance of \"cas.player\" expected.")
	elseif type(weapon) ~= "string" then
		error("Passed \"weapon\" parameter is not valid. String expected, ".. type(weapon) .." passed.")
	end
	if weaponImage then
		if type(weaponImage) ~= "string" then
			error("Passed \"weaponImage\" parameter is not valid. String expected, ".. type(weaponImage) .." passed.")
		end
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
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
	if getmetatable(itemType) ~= cas.itemType then
		error("Passed \"itemType\" parameter is not an instance of the \"cas.itemType\" class.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("equip", self._id, itemType._typeId)
end

function cas.player:flash(intentsity)
	if type(intentsity) ~= "number" then
		error("Passed \"intentsity\" parameter is not valid. Number expected, ".. type(intentsity) .." passed.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
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
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("kick", self._id, reason)
end

function cas.player:kill()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is already dead.")
	end
	
	cas.console.parse("killplayer", self._id)
end 

function cas.player:makeTerrorist()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getTeam() == 1 then
		error("This player is already a terrorist.")
	end
	
	cas.console.parse("maket", self._id)
end

function cas.player:makeCounterTerrorist()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getTeam() == 2 or self:getTeam() == 3 then
		error("This player is already a counter-terrorist.")
	end
	
	cas.console.parse("makect", self._id)
end

function cas.player:makeSpectator()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getTeam() == 0 then
		error("This player is already a spectator.")
	end
	
	cas.console.parse("makespec", self._id)
end

function cas.player:reroute(address)
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end

	if type(address) ~= "string" then
		error("Passed \"address\" parameter is not valid. String expected, ".. type(address) .." passed.")
	end
	
	cas.console.parse("reroute", address)
end

function cas.player:setAmmo(itemType, ammoin, ammo)
	if getmetatable(itemType) ~= cas.itemType then
		error("Passed \"itemType\" parameter is not an instance of the \"cas.itemType\" class.")
	elseif not ((type(ammoin) == "boolean" and not ammoin) or (type(ammoin) == "number")) then
		error("Passed \"ammoin\" parameter is not valid. False or number expected, ".. type(ammoin) .." passed.")
	elseif not ((type(ammo) == "boolean" and not ammo) or (type(ammo) == "number")) then
		error("Passed \"ammo\" parameter is not valid. False or number expected, ".. type(ammo) .." passed.")
	end
	if ammoin then
		if not (ammoin >= 0 and ammoin <= 999) then
			error("Passed \"ammoin\" value (as a number) has to be in the range of 0 and 999.")
		end
	end
	if ammo then
		if not (ammo >= 0 and ammo <= 999) then
			error("Passed \"ammo\" value (as a number) has to be in the range of 0 and 999.")
		end
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("setammo", self._id, itemType._typeId, ammoin and ammoin or 1000, ammo and ammo or 1000)
end

function cas.player:setArmor(armor)
	if type(armor) ~= "number" then
		error("Passed \"armor\" parameter is not valid. Number expected, ".. type(armor) .." passed.")
	end
	if not (armor >= 0 and armor <= 255) then
		error("Passed \"armor\" value has to be a number in the range of 0 and 255.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("setarmor", self._id, armor)
end

function cas.player:setDeaths(deaths)
	if type(deaths) ~= "number" then
		error("Passed \"deaths\" parameter is not valid. Number expected, ".. type(deaths) .." passed.")
	end
	if deaths < 0 then
		error("Passed \"deaths\" value has to be a number larger than 0.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("setdeaths", self._id, deaths)
end

function cas.player:setHealth(health)
	if type(health) ~= "number" then
		error("Passed \"health\" parameter is not valid. Number expected, ".. type(health) .." passed.")
	end
	if not (health >= 0 and health <= 250 ) then
		error("Passed \"health\" value has to be a number in the range of 0 and 250.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("sethealth", self._id, health)
end

function cas.player:setMaxHealth(health)
	if type(health) ~= "number" then
		error("Passed \"health\" parameter is not valid. Number expected, ".. type(health) .." passed.")
	end
	if not (health >= 0 and health <= 250 ) then
		error("Passed \"health\" value has to be a number in the range of 0 and 250.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("setmaxhealth", self._id, health)
end

function cas.player:setMoney(money)
	if type(money) ~= "number" then
		error("Passed \"money\" parameter is not valid. Number expected, ".. type(money) .." passed.")
	end
	if not (money >= 0 and money <= 16000) then
		error("Passed \"money\" value has to be a number in the range of 0 and 16000.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end

	cas.console.parse("setmoney", self._id, money)
end

function cas.player:setName(name, hide)
	if type(name) ~= "string" then
		error("Passed \"name\" parameter is not valid. String expected, ".. type(name) .." passed.")
	end
	if hide then
		if type(hide) ~= "boolean" then
			error("Passed \"hide\" parameter is not valid. Boolean expected, ".. type(hide) .." passed.")
		end
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("setname", self._id, name, hide and 1 or 0)
end

function cas.player:setPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("setpos", self._id, x, y)
end

function cas.player:setScore(score)
	if type(score) ~= "number" then
		error("Passed \"score\" parameter is not valid. Number expected, ".. type(score) .." passed.")
	end
	if score < 0 then
		error("Passed \"score\" value has to be a number larger than 0.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("setscore", self._id, score)
end

function cas.player:setWeapon(weapon)
	if getmetatable(weapon) ~= cas.itemType then
		error("Passed \"weapon\" parameter is not an instance of the \"cas.itemType\" class.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("setweapon", self._id, weapon._typeId)
end

function cas.player:shake(power)
	if type(power) ~= "number" then
		error("Passed \"power\" parameter is not valid. Number expected, ".. type(power) .." passed.")
	end
	if power < 0 then
		error("Passed \"power\" value has to be a number larger than 0.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("shake", self._id, power)
end

function cas.player:slap()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("slap", self._id)
end

function cas.player:deathSlap()
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("deathslap", self._id)
end

function cas.player:spawn(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.")
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.")
	end

	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() > 0 then
		error("This player is alive.")
	end
	
	if self:getTeam() == 0 then
		error("This player is spectator.")
	end
	
	cas.console.parse("spawnplayer", self._id)
end

function cas.player:setSpeed(speed)
	if type(speed) ~= "number" then
		error("Passed \"speed\" parameter is not valid. Number expected, ".. type(speed) .." passed.")
	end
	if not (speed >= -100 and speed <= 100) then
		error("Passed \"speed\" value has to be a number in the range of -100 and 100.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	cas.console.parse("speedmod", self._id, speed)
end

function cas.player:strip(itemType)
	if getmetatable(itemType) ~= cas.itemType then
		error("Passed \"itemType\" parameter is not an instance of the \"cas.itemType\" class.")
	end
	
	if not self:exists() then
		error("Player of this instance doesn't exist.")
	end
	
	if self:getHealth() <= 0 then
		error("This player is dead.")
	end
	
	cas.console.parse("strip", self._id, itemType._typeId)
end

-------------------
-- Static fields --
-------------------

cas.player._allowCreation = false -- Defines if instantiation of this class is allowed.
cas.player._instances = setmetatable({}, {__mode = "kv"}) -- A table of instances of this class.