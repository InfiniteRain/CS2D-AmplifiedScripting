-- Initializing tile class.
local Tile = class()

--------------------
-- Static methods --
--------------------

-- Used to check the passed position parameters of some methods.
function Tile._checkPositionParameters(x, y)
  if type(x) ~= 'number' then
    error('Passed "x" parameter is not valid. Number expected, ' .. type(x) .. ' passed.', 3)
  elseif type(y) ~= 'number' then
    error('Passed "y" parameter is not valid. Number expected, ' .. type(y) .. ' passed.', 3)
  end

  if math.floor(x) ~= x then
    error('Passed "x" parameter should be a number with no floating point.', 3)
  elseif math.floor(y) ~= y then
    error('Passed "y" parameter should be a number with no floating point.', 3)
  end

  if not (x >= 0 and y >= 0 and x <= Map.getXSize() and y <= Map.getYSize()) then
    error('Passed position is out of map bounds.', 3)
  end
end

--== Getters ==--

-- Gets the tile frame.
function Tile.getFrame(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'frame')
end

-- Gets the tile property.
function Tile.getProperty(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'property')
end

-- Gets whether or not the tile is walkable.
function Tile.isWalkable(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'walkable')
end

-- Gets whether or not the tile is deadly.
function Tile.isDeadly(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'deadly')
end

-- Gets whether or not the tile is a wall.
function Tile.isWall(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'wall')
end

-- Gets whether or not the tile is an obstacle.
function Tile.isObstacle(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'obstacle')
end

-- Gets the entity type on the position (or false if there's none).
function Tile.getEntity(x, y)
  Tile._checkPositionParameters(x, y)

  local entity = _META.command.tile(x, y, 'entity')
  return entity == 0 and false or entity
end

-- Gets whether or not the tile was changed via 'settile' command.
function Tile.isChanged(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'hascustomframe')
end

-- Gets the original frame of this tile (in case it was changed via 'settile' command).
function Tile.getOriginalFrame(x, y)
  Tile._checkPositionParameters(x, y)

  return _META.command.tile(x, y, 'originalframe')
end

--== Setters/control ==--

-- Sets the tile frame on the position.
function Tile.setTile(x, y, tile)
  Tile._checkPositionParameters(x, y)
  if type(tile) ~= 'number' then
    error('Passed "tile" parameter is not valid. Number expected, ' .. type(tile) .. ' passed.', 2)
  end

  if not (x >= 0 and y >= 0 and x <= Map.getXSize() and y <= Map.getYSize()) then
    error('Passed position is outside of map bounds!', 2)
  end

  if not (tile <= Map.getTileCount()) then
    error('Passed tile represents a non-valid tile tile.', 2)
  end

  Console.parse('settile', x, y, tile)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function Tile:constructor()
  error('Instantiation of this class is not allowed.', 2)
end

-------------------------
-- Returning the class --
-------------------------
return Tile
