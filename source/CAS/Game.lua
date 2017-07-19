-- Initializing game class.
local Game = class()

--------------------
-- Static methods --
--------------------

--== Getters ==--

-- Gets current game version.
function Game.getVersion()
  return _META.command.game('version')
end

-- Checks if the server is dedicated.
function Game.isDedicated()
  return _META.command.game('dedicated')
end

-- Gets current game phase.
function Game.getPhase()
  return _META.command.game('phase')
end

-- Gets current round.
function Game.getRound()
  return _META.command.game('round')
end

-- Gets the score of the terrorists.
function Game.getTScore()
  return _META.command.game('score_t')
end

-- Gets the score of the counter-terrorists.
function Game.getCTScore()
  return _META.command.game('score_ct')
end

-- Gets the rounds won in a row by the terrorists.
function Game.getTWinRow()
  return _META.command.game('winrow_t')
end

-- Gets the rounds won in a row by the counter-terrorists.
function Game.getCTWinRow()
  return _META.command.game('winrow_ct')
end

-- Gets the next map in the map cycle.
function Game.getNextMap()
  return _META.command.game('nextmap')
end

-- Gets the UDP port used by the server.
function Game.getPort()
  return _META.command.game('port')
end

-- Gets whether or not the bomb was planted.
function Game.isBombPlanted()
  return _META.command.game('bombplanted')
end

-- Gets CS2D server setting.
function Game.getSetting(setting)
  if type(setting) ~= 'string' then
    error('Passed "setting" parameter is not valid. String expected, ' .. type(setting) .. ' passed.', 2)
  end

  return _META.command.game(setting)
end

--== Setters/control ==--

-- Sends a message to every client's console.
function Game.messageToConsole(message, color)
  if type(message) ~= 'string' then
    error('Passed "message" parameter is not valid. String expected, ' .. type(message) .. ' passed.', 2)
  end
  if color then
    if getmetatable(color) ~= Color then
      error('Passed "color" parameter is not valid. String expected, ' .. type(color) .. ' passed.', 2)
    end
  end

  Console.parse('cmsg', (color and tostring(color) or '') .. message)
end

-- Sends a message to every client.
function Game.messageToChat(...)
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

  _META.command.msg(messageString)
end

-- Fire effect.
function Game.fireEffect(x, y, amount, radius)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  elseif type(amount) ~= 'number' then
    error('Passed "amount" parameter is not valid. Number expected, ' .. type(amount) .. ' passed.', 2)
  elseif type(radius) ~= 'number' then
    error('Passed "radius" parameter is not valid. Number expected, ' .. type(radius) .. ' passed.', 2)
  end

  Console.parse('effect', 'fire', x, y, amount, radius)
end

-- Smoke effect.
function Game.smokeEffect(x, y, amount, radius)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  elseif type(amount) ~= 'number' then
    error('Passed "amount" parameter is not valid. Number expected, ' .. type(amount) .. ' passed.', 2)
  elseif type(radius) ~= 'number' then
    error('Passed "radius" parameter is not valid. Number expected, ' .. type(radius) .. ' passed.', 2)
  end

  Console.parse('effect', 'smoke', x, y, amount, radius, 0, 0, 0)
end

-- Flare effect.
function Game.flareEffect(x, y, amount, radius, color)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  elseif type(amount) ~= 'number' then
    error('Passed "amount" parameter is not valid. Number expected, ' .. type(amount) .. ' passed.', 2)
  elseif type(radius) ~= 'number' then
    error('Passed "radius" parameter is not valid. Number expected, ' .. type(radius) .. ' passed.', 2)
  elseif getmetatable(color) ~= Color then
    error('Passed "color" parameter is not an instance of the "Color" class.', 2)
  end

  Console.parse('effect', 'flare', x, y, amount, radius, color:getRGB())
end

-- Fire effect.
function Game.colorSmokeEffect(x, y, amount, radius, color)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  elseif type(amount) ~= 'number' then
    error('Passed "amount" parameter is not valid. Number expected, ' .. type(amount) .. ' passed.', 2)
  elseif type(radius) ~= 'number' then
    error('Passed "radius" parameter is not valid. Number expected, ' .. type(radius) .. ' passed.', 2)
  elseif getmetatable(color) ~= Color then
    error('Passed "color" parameter is not an instance of the "Color" class.', 2)
  end

  Console.parse('effect', 'colorsmoke', x, y, amount, radius, color:getRGB())
end

-- End round.
function Game.endRound(mode)
  if type(mode) ~= 'number' then
    error('Passed "mode" parameter is not valid. Number expected, ' .. type(mode) .. ' passed.', 2)
  end

  if not (mode >= 0 and mode <= 2 and math.floor(mode) == mode) then
    error('Passed "mode" value has to be in the range of 0 - 2 with no floating point.', 2)
  end

  Console.parse('endround', mode)
end

-- Flash position.
function Game.flashPosition(x, y, intensity)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  elseif type(intensity) ~= 'number' then
    error('Passed "intensity" parameter is not valid. Number expected, ' .. type(intensity) .. ' passed.', 2)
  end

  if not (intensity >= 0 and intensity <= 100) then
    error('Passed "intensity" value has to be in the range of 0 - 100.', 2)
  end

  Console.parse('flashposition', x, y, intensity)
end

-- Restart round.
function Game.restartRound(delay)
  if delay then
    if type(delay) ~= 'number' then
      error('Passed "delay" parameter is not valid. Number expected, ' .. type(delay) .. ' passed.', 2)
    end
  end

  delay = delay or 0

  if not (delay >= 0 and delay <= 10) then
    error('Passed "delay" value has to be in the range of 0 - 10.', 2)
  end

  Console.parse('restart', delay)
end

-- Set team scores.
function Game.setTeamScores(tScore, ctScore)
  if type(tScore) ~= 'number' then
    error('Passed "tScore" parameter is not valid. Number expected, ' .. type(tScore) .. ' passed.', 2)
  elseif type(ctScore) ~= 'number' then
    error('Passed "ctScore" parameter is not valid. Number expected, ' .. type(ctScore) .. ' passed.', 2)
  end

  if not (tScore >= 0 and tScore <= 65535 and math.floor(tScore) == tScore) then
    error('Passed "tScore" value has to be in the range of 0 - 65535 with no floating point.', 2)
  elseif not (ctScore >= 0 and ctScore <= 65535 and math.floor(ctScore) == ctScore) then
    error('Passed "ctScore" value has to be in the range of 0 - 65535 with no floating point..', 2)
  end

  Console.parse('setteamscores', tScore, ctScore)
end

-- Trigger entity.
function Game.trigger(...)
  for key, value in pairs({ ... }) do
    if type(value) ~= 'string' then
      error('Passed parameter (#' .. key .. ') is not valid. Number expected, ' .. type(value) .. ' passed.', 2)
    end
  end

  Console.parse('trigger', table.concat({ ... }, ','))
end

-- Trigger entity at the position.
function Game.triggerPosition(x, y)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  end

  Console.parse('triggerposition', x, y)
end

-- Plays a sound to everyone on the server.
function Game.playSound(path)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  end

  Console.parse('sv_sound', path)
end

-- Plays a sound at a certain position (for 3D sound effect)
function Game.playPositionalSound(path, x, y)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  elseif type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 2)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 2)
  end

  Console.parse('sv_soundpos', path, x, y)
end

-- Stops sound defined by path for everyone on the server.
function Game.stopSound(path)
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  end

  Console.parse('sv_stopsound', 0, path)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function Game:constructor()
  error('Instantiation of this class is not allowed.', 2)
end

-------------------
-- Static fields --
-------------------

Game._effectTypes = {
  'fire', 'smoke', 'flare', 'colorsmoke'
}

-------------------------
-- Returning the class --
-------------------------
return Game
