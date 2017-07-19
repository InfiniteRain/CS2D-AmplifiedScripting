-- Initializing the Player class.
local Player = class()

--------------------
-- Static methods --
--------------------

-- Returns the player instance from the passed player ID.
function Player.getInstance(playerID)
  if type(playerID) ~= 'number' then
    error('Passed "playerID" parameter is not valid. Number expected, ' .. type(playerID) .. ' passed.', 2)
  elseif not _META.command.player(playerID, 'exists') then
    error('Passed "playerID" parameter represents a non-existent player.', 2)
  end

  for key, value in pairs(Player._instances) do
    if value._id == playerID then
      Player._debug:log('Player "' .. tostring(value) .. '" was found in the "_instances" table and returned.')
      return value
    end
  end

  Player._allowCreation = true
  local player = Player(playerID)
  Player._allowCreation = false

  return player
end

-- Gets whether or not a player under a certain ID exists.
function Player.idExists(id)
  return _META.command.player(id, 'exists')
end

-- Returns a table of all the players on the server.
function Player.getPlayers()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'table')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Returns a table of all the currently living players.
function Player.getLivingPlayers()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'tableliving')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Returns a table of all the terrorists.
function Player.getTerrorists()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'team1')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Returns a table of all the counter terrorists.
function Player.getCounterTerrorists()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'team2')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Returns the table of all the living terrorists. 
function Player.getLivingTerrorists()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'team1living')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Returns the table of all the living counter terrorists. 
function Player.getLivingCounterTerrorists()
  local players = {}
  for key, value in pairs(_META.command.player(0, 'team2living')) do
    table.insert(players, Player.getInstance(value))
  end

  return players
end

-- Gets stats for provided USGN ID.
function Player.getStats(USGNID, stat)
  return _META.command.stats(USGNID, stat)
end

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a player instance with corresponding ID.
function Player:constructor(playerID)
  if type(playerID) ~= 'number' then
    error('Passed "playerID" parameter is not valid. Number expected, ' .. type(playerID) .. ' passed.', 2)
  elseif not _META.command.player(playerID, 'exists') then
    error('Passed "playerID" parameter represents a non-existent player.', 2)
  end

  if not Player._allowCreation then
    error('Instantiation of this class is not allowed.', 2)
  end

  for key, value in pairs(Player._instances) do
    if value._id == playerID then
      error('Instance with the same player ID already exists.', 2)
    end
  end

  self._id = playerID
  self._left = false

  table.insert(Player._instances, self)

  Player._debug:log('Player "' .. tostring(self) .. '" was instantiated.')
end

-- Destructor.
function Player:destructor()
  if not self._left then
    self._left = true
  end

  for key, value in pairs(Player._instances) do
    if value == self then
      -- Removes the player from the Player._instances table.
      Player._instances[key] = nil
    end
  end

  Player._debug:log('Player "' .. tostring(self) .. '" was garbage collected.')
end

-- Requests client data from a player.
function Player:requestClientData(mode, parameter)
  if type(mode) ~= 'string' then
    error('Passed "mode" parameter is not valid. String expected, ' .. type(mode) .. ' passed.', 2)
  end
  if parameter then
    if type(parameter) ~= 'string' then
      error('Passed "parameter" parameter is not valid. String expected, ' .. type(parameter) .. ' passed.', 2)
    end
  end

  if not Player._clientDataModes[mode] then
    error('Passed "mode" value does not represent a valid mode.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  _META.command.reqcld(self._id, Player._clientDataModes[mode], parameter)
end

--== Getters ==--

-- Gets the slot ID of the player.
function Player:getSlotID()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return self._id
end

-- Gets the table of all the weapons this player holds.
function Player:getWeapons()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  local weapons = {}
  for key, value in pairs(_META.command.playerweapons(self._id)) do
    table.insert(weapons, ItemType.getInstance(value))
  end

  return weapons
end

-- Opens up a menu for this player. Takes a table as an argument which should represent a menu,
-- in which fields will affect the way menu looks. This is how it should look like:
--[[
{
	title = <string>, -- The title of the menu.
	look = <string>, -- How it will look like. Accepts three strings:
							- 'standard' -- Standard menu look.
							- 'invisible' -- Invisible menu look.
							- 'big' -- Big menu look.
						It is optional. Defaults to 'standard'.
	buttons = { -- Table which holds information about the buttons of the menu. Each button is 
				-- represented as a table. Can hold up to 9 buttons.
		[1] = {
			caption = <string>, -- Caption of the button.
			subcaption = <string>, -- Subcaption of the button. Optional.
			disabled = <boolean> -- Whether or not this button is disabled (grayed-out). Optional.
								 -- Defaults to false.
		},
		
		[2] = {
			...
		},
		
		...
		
		[9] = {
			...
		}
	}
}
]]
function Player:openMenu(menuTable)
  if type(menuTable) ~= 'table' then
    error('Passed "menuTable" parameter is not valid. Table expected, ' .. type(menuTable) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  -- Parsing the title of the menu.
  local menuString -- Will hold the menu string.

  if type(menuTable.title) ~= 'string' then -- Checking if title field is valid.
    error('"title" field of menu table is not valid. String expected, got ' .. type(menuTable.title) .. '.', 2)
  end

  menuString = menuTable.title

  -- Parsing the look of the menu.
  if menuTable.look then -- If look field was provided.
    if type(menuTable.look) ~= 'string' then -- Checks if its valid.
      error('"look" field of menu table is not valid. String expected, got ' .. type(menuTable.look) .. '.', 2)
    end

    -- Enforces look on the menu.
    if menuTable.look == 'invisible' then
      menuString = menuString .. '@i'
    elseif menuTable.look == 'big' then
      menuString = menuString .. '@b'
    elseif menuTable.look ~= 'standard' then
      error('"look" field of menu table represents an invalid look.')
    end
  end

  -- Parsing the buttons of the menu.
  if type(menuTable.buttons) ~= 'table' then
    error('"buttons" field of menu table is not valid. Table expected, got ' .. type(menuTable.buttons) .. '.', 2)
  end

  for key = 1, 9 do
    if menuTable.buttons[key] then
      if type(menuTable.buttons[key].caption) ~= 'string' then
        error('"caption" field of button #' .. key .. ' table is not valid. String expected, got '
            .. type(menuTable.buttons[key].caption) .. '.', 2)
      end

      if menuTable.buttons[key].subcaption then
        if type(menuTable.buttons[key].subcaption) ~= 'string' then
          error('"subcaption" field of button #' .. key .. ' table is not valid. String expected, got '
              .. type(menuTable.buttons[key].subcaption) .. '.', 2)
        end
      end

      if menuTable.buttons[key].disabled ~= nil then
        if type(menuTable.buttons[key].disabled) ~= 'boolean' then
          error('"disabled" field of button #' .. key .. ' table is not valid. Boolean expected, got '
              .. type(menuTable.buttons[key].disabled) .. '.', 2)
        end
      end

      if menuTable.buttons[key].disabled then
        menuString = menuString .. ',(' .. menuTable.buttons[key].caption
        if menuTable.buttons[key].subcaption then
          menuString = menuString .. '|' .. menuTable.buttons[key].subcaption .. ')'
        else
          menuString = menuString .. ')'
        end
      else
        menuString = menuString .. ',' .. menuTable.buttons[key].caption
        if menuTable.buttons[key].subcaption then
          menuString = menuString .. '|' .. menuTable.buttons[key].subcaption
        end
      end
    end
  end

  _META.command.menu(self._id, menuString)
end

-- Plays sound to this player.
function Player:playSound(path)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('sv_sound2', self._id, path)
end

-- Plays a sound at a certain position (for 3D sound effect) for this player.
function Player:playPositionalSound(path, x, y)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  elseif type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('sv_soundpos', path, x, y, self._id)
end

-- Stops sound defined by path for this player.
function Player:stopSound(path)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('sv_stopsound', self._id, path)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- The following is self explanatory, I based it on 'player' function of cs2d --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function Player:getName()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'name')
end

function Player:getIP()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'ip')
end

function Player:getPort()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'port')
end

function Player:getUSGN()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  local usgn = _META.command.player(self._id, 'usgn')
  return usgn ~= 0 and usgn or false
end

function Player:getPing()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'ping')
end

function Player:getIdleTime()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'idle')
end

function Player:isBot()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'bot')
end

function Player:getTeam()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'team')
end

function Player:getSkin()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'look')
end

function Player:getPosition()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return
  _META.command.player(self._id, 'x'),
  _META.command.player(self._id, 'y')
end

function Player:getX()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'x')
end

function Player:getY()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'y')
end

function Player:getAngle()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'rot')
end

function Player:getTilePosition()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return
  _META.command.player(self._id, 'tilex'),
  _META.command.player(self._id, 'tiley')
end

function Player:getTileX()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'tilex')
end

function Player:getTileY()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'tiley')
end

function Player:getHealth()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'health')
end

function Player:getArmor()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'armor')
end

function Player:getMoney()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'money')
end

function Player:getScore()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'score')
end

function Player:getDeaths()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'deaths')
end

function Player:getTeamKills()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'teamkills')
end

function Player:getHostageKills()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'hostagekills')
end

function Player:getTeamBuildingKills()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'teambuildingkills')
end

function Player:getWeaponType()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'weapontype')
end

function Player:hasNightvision()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'nightvision')
end

function Player:hasDefuseKit()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'defusekit')
end

function Player:hasGasmask()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'gasmask')
end

function Player:hasBomb()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'bomb')
end

function Player:hasFlag()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'flag')
end

function Player:isReloading()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'reloading')
end

function Player:getCurrentProcess()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'process')
end

function Player:getSprayName()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'sprayname')
end

function Player:getSprayColor()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'spraycolor')
end

function Player:getKickVote()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  local player = _META.command.player(self._id, 'votekick')
  return player ~= 0 and Player.getInstance(player) or false
end

function Player:getMapVote()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  local map = _META.command.player(self._id, 'votemap')
  return map ~= '' and map or false
end

function Player:getFavoriteTeam()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'favteam')
end

function Player:getSpeed()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'speedmod')
end

function Player:getMaxHealth()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'maxhealth')
end

function Player:isRcon()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'rcon')
end

function Player:getFlashedTime()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  return _META.command.player(self._id, 'ai_flash')
end

--== Setters/control ==--

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--  The following is based on console commands  --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function Player:IPBan(duration, reason)
  if duration then
    if type(duration) == 'number' and not (duration >= 1 and duration <= 1440) then
      error('Passed "duration" value (as a number) has to be in the range of 1 and 1440.', 2)
    elseif type(duration) == 'string' and not (duration == 'permanent' or duration == 'default') then
      error('Passed "duration" value (as a string) has to be either "permanent" or "default".', 2)
    else
      error('Passed "duration" parameter is not valid. Number or string expected, ' .. type(duration) .. ' passed.', 2)
    end
  end
  if reason then
    if type(reason) ~= 'string' then
      error('Passed "reason" parameter is not valid. String expected, ' .. type(reason) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if duration == 'permanent' then
    Console.parse('banip', self:getIP(), 0, reason)
  elseif duration == 'default' then
    Console.parse('banip', self:getIP(), -1, reason)
  else
    Console.parse('banip', self:getIP(), duration, reason)
  end
end

function Player:nameBan(duration, reason)
  if duration then
    if type(duration) == 'number' and not (duration >= 1 and duration <= 1440) then
      error('Passed "duration" value (as a number) has to be in the range of 1 and 1440.', 2)
    elseif type(duration) == 'string' and not (duration == 'permanent' or duration == 'default') then
      error('Passed "duration" value (as a string) has to be either "permanent" or "default".', 2)
    else
      error('Passed "duration" parameter is not valid. Number or string expected, ' .. type(duration) .. ' passed.', 2)
    end
  end
  if reason then
    if type(reason) ~= 'string' then
      error('Passed "reason" parameter is not valid. String expected, ' .. type(reason) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if duration == 'permanent' then
    Console.parse('banname', self:getName(), 0, reason)
  elseif duration == 'default' then
    Console.parse('banname', self:getName(), -1, reason)
  else
    Console.parse('banname', self:getName(), duration, reason)
  end
end

function Player:usgnBan(duration, reason)
  if duration then
    if type(duration) == 'number' and not (duration >= 1 and duration <= 1440) then
      error('Passed "duration" value (as a number) has to be in the range of 1 and 1440.', 2)
    elseif type(duration) == 'string' and not (duration == 'permanent' or duration == 'default') then
      error('Passed "duration" value (as a string) has to be either "permanent" or "default".', 2)
    else
      error('Passed "duration" parameter is not valid. Number or string expected, ' .. type(duration) .. ' passed.', 2)
    end
  end
  if reason then
    if type(reason) ~= 'string' then
      error('Passed "reason" parameter is not valid. String expected, ' .. type(reason) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if not self:getUSGN() then
    error('This player is not logged in.', 2)
  end

  if duration == 'permanent' then
    Console.parse('banusgn', self:getUSGN(), 0, reason)
  elseif duration == 'default' then
    Console.parse('banusgn', self:getUSGN(), -1, reason)
  else
    Console.parse('banusgn', self:getUSGN(), duration, reason)
  end
end

function Player:messageToConsole(message, color)
  if type(message) ~= 'string' then
    error('Passed "message" parameter is not valid. String expected, ' .. type(message) .. ' passed.', 2)
  end
  if color then
    if getmetatable(color) ~= Color then
      error('Passed "color" parameter is not an instance of the "Color" class.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('cmsg', (color and tostring(color) or '') .. message, self._id)
end

function Player:messageToChat(...)
  local arguments = { ... }
  local messageString = ''

  for key, value in pairs(arguments) do
    if getmetatable(value) == Color then
      messageString = messageString .. tostring(value)
    elseif type(value) == 'string' then
      messageString = messageString .. value
    else
      error('Argument #' .. key .. ' should either be an instance of the Color class or a string.', 2)
    end
  end

  _META.command.msg2(self._id, messageString)
end

function Player:customKill(killer, weapon, weaponImage)
  if not (killer == false or getmetatable(killer) == Player) then
    error('Passed "killer" parameter is not valid. False or instance of "Player" expected.', 2)
  elseif type(weapon) ~= 'string' then
    error('Passed "weapon" parameter is not valid. String expected, ' .. type(weapon) .. ' passed.', 2)
  end
  if weaponImage then
    if type(weaponImage) ~= 'string' then
      error('Passed "weaponImage" parameter is not valid. String expected, ' .. type(weaponImage) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is already dead.', 2)
  end

  -- Checks if the weapon image exists.
  if weaponImage then
    local file = io.open(weaponImage, 'r')
    if file == nil then
      error('Could not load image at "' .. weaponImage .. '".', 2)
    else
      file:close()
    end
  end

  Console.parse('customkill', killer and killer._id or 0, weapon .. (weaponImage and ',' .. weaponImage or ''), self._id)
end

function Player:equip(itemType)
  if getmetatable(itemType) ~= ItemType then
    error('Passed "itemType" parameter is not an instance of the "ItemType" class.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('equip', self._id, itemType._typeId)
end

function Player:flash(intentsity)
  if type(intentsity) ~= 'number' then
    error('Passed "intentsity" parameter is not valid. Number expected, ' .. type(intentsity) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('flashplayer', self._id, intentsity)
end

function Player:kick(reason)
  if reason then
    if type(reason) ~= 'string' then
      error('Passed "reason" parameter is not valid. String expected, ' .. type(reason) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('kick', self._id, reason)
end

function Player:kill()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is already dead.', 2)
  end

  Console.parse('killplayer', self._id)
end

function Player:makeTerrorist()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getTeam() == 1 then
    error('This player is already a terrorist.', 2)
  end

  Console.parse('maket', self._id)
end

function Player:makeCounterTerrorist()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getTeam() == 2 or self:getTeam() == 3 then
    error('This player is already a counter-terrorist.', 2)
  end

  Console.parse('makect', self._id)
end

function Player:makeSpectator()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getTeam() == 0 then
    error('This player is already a spectator.', 2)
  end

  Console.parse('makespec', self._id)
end

function Player:reroute(address)
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if type(address) ~= 'string' then
    error('Passed "address" parameter is not valid. String expected, ' .. type(address) .. ' passed.', 2)
  end

  Console.parse('reroute', address)
end

function Player:setAmmo(itemType, ammoin, ammo)
  if getmetatable(itemType) ~= ItemType then
    error('Passed "itemType" parameter is not an instance of the "ItemType" class.', 2)
  elseif not ((type(ammoin) == 'boolean' and not ammoin) or (type(ammoin) == 'number')) then
    error('Passed "ammoin" parameter is not valid. False or number expected, ' .. type(ammoin) .. ' passed.', 2)
  elseif not ((type(ammo) == 'boolean' and not ammo) or (type(ammo) == 'number')) then
    error('Passed "ammo" parameter is not valid. False or number expected, ' .. type(ammo) .. ' passed.', 2)
  end
  if ammoin then
    if not (ammoin >= 0 and ammoin <= 999) then
      error('Passed "ammoin" value (as a number) has to be in the range of 0 and 999.', 2)
    end
  end
  if ammo then
    if not (ammo >= 0 and ammo <= 999) then
      error('Passed "ammo" value (as a number) has to be in the range of 0 and 999.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('setammo', self._id, itemType._typeId, ammoin and ammoin or 1000, ammo and ammo or 1000)
end

function Player:setArmor(armor)
  if type(armor) ~= 'number' then
    error('Passed "armor" parameter is not valid. Number expected, ' .. type(armor) .. ' passed.', 2)
  end
  if not (armor >= 0 and armor <= 255) then
    error('Passed "armor" value has to be a number in the range of 0 and 255.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('setarmor', self._id, armor)
end

function Player:setDeaths(deaths)
  if type(deaths) ~= 'number' then
    error('Passed "deaths" parameter is not valid. Number expected, ' .. type(deaths) .. ' passed.', 2)
  end
  if deaths < 0 then
    error('Passed "deaths" value has to be a number larger than 0.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('setdeaths', self._id, deaths)
end

function Player:setHealth(health)
  if type(health) ~= 'number' then
    error('Passed "health" parameter is not valid. Number expected, ' .. type(health) .. ' passed.', 2)
  end
  if not (health >= 0 and health <= 250) then
    error('Passed "health" value has to be a number in the range of 0 and 250.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('sethealth', self._id, health)
end

function Player:setMaxHealth(health)
  if type(health) ~= 'number' then
    error('Passed "health" parameter is not valid. Number expected, ' .. type(health) .. ' passed.', 2)
  end
  if not (health >= 0 and health <= 250) then
    error('Passed "health" value has to be a number in the range of 0 and 250.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('setmaxhealth', self._id, health)
end

function Player:setMoney(money)
  if type(money) ~= 'number' then
    error('Passed "money" parameter is not valid. Number expected, ' .. type(money) .. ' passed.', 2)
  end
  if not (money >= 0 and money <= 16000) then
    error('Passed "money" value has to be a number in the range of 0 and 16000.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('setmoney', self._id, money)
end

function Player:setName(name, hide)
  if type(name) ~= 'string' then
    error('Passed "name" parameter is not valid. String expected, ' .. type(name) .. ' passed.', 2)
  end
  if hide then
    if type(hide) ~= 'boolean' then
      error('Passed "hide" parameter is not valid. Boolean expected, ' .. type(hide) .. ' passed.', 2)
    end
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('setname', self._id, name, hide and 1 or 0)
end

function Player:setPosition(x, y)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('setpos', self._id, x, y)
end

function Player:setScore(score)
  if type(score) ~= 'number' then
    error('Passed "score" parameter is not valid. Number expected, ' .. type(score) .. ' passed.', 2)
  end
  if score < 0 then
    error('Passed "score" value has to be a number larger than 0.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('setscore', self._id, score)
end

function Player:setWeapon(weapon)
  if getmetatable(weapon) ~= ItemType then
    error('Passed "weapon" parameter is not an instance of the "ItemType" class.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('setweapon', self._id, weapon._typeId)
end

function Player:shake(power)
  if type(power) ~= 'number' then
    error('Passed "power" parameter is not valid. Number expected, ' .. type(power) .. ' passed.', 2)
  end
  if power < 0 then
    error('Passed "power" value has to be a number larger than 0.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('shake', self._id, power)
end

function Player:slap()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('slap', self._id)
end

function Player:deathSlap()
  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('deathslap', self._id)
end

function Player:spawn(x, y)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() > 0 then
    error('This player is alive.', 2)
  end

  if self:getTeam() == 0 then
    error('This player is spectator.', 2)
  end

  Console.parse('spawnplayer', self._id)
end

function Player:setSpeed(speed)
  if type(speed) ~= 'number' then
    error('Passed "speed" parameter is not valid. Number expected, ' .. type(speed) .. ' passed.', 2)
  end
  if not (speed >= -100 and speed <= 100) then
    error('Passed "speed" value has to be a number in the range of -100 and 100.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  Console.parse('speedmod', self._id, speed)
end

function Player:strip(itemType)
  if getmetatable(itemType) ~= ItemType then
    error('Passed "itemType" parameter is not an instance of the "ItemType" class.', 2)
  end

  if self._left then
    error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
  end

  if self:getHealth() <= 0 then
    error('This player is dead.', 2)
  end

  Console.parse('strip', self._id, itemType._typeId)
end

-------------------
-- Static fields --
-------------------

Player._allowCreation = false -- Defines if instantiation of this class is allowed.
Player._instances = setmetatable({}, { __mode = 'kv' }) -- A table of instances of this class.

Player._clientDataModes = {
  ['cursoronscreen'] = 0,
  ['mapscroll'] = 1,
  ['cursoronmap'] = 2,
  ['lightengine'] = 3,
  ['fileloaded'] = 4
}

Player._debug = Debug(Color.yellow, 'CAS Player')
Player._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return Player
