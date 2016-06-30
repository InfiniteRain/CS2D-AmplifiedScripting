-- Initializing tile class.
cas.tile = cas.class()

--------------------
-- Static methods --
--------------------

-- Used to check the passed position parameters of some methods.
function cas.tile._checkPositionParameters(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 3)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 3)
	end
	
	if math.floor(x) ~= x then
		error("Passed \"x\" parameter should be a number with no floating point.", 3)
	elseif math.floor(y) ~= y then
		error("Passed \"y\" parameter should be a number with no floating point.", 3)
	end
	
	if not (x >= 0 and y >= 0 and x <= cas.map.getXSize() and y <= cas.map.getYSize()) then
		error("Passed position is out of map bounds.", 3)
	end
end

--== Getters ==--

-- Gets the tile frame.
function cas.tile.getFrame(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "frame")
end

-- Gets the tile property.
function cas.tile.getProperty(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "property")
end

-- Gets whether or not the tile is walkable.
function cas.tile.isWalkable(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "walkable")
end

-- Gets whether or not the tile is deadly.
function cas.tile.isDeadly(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "deadly")
end

-- Gets whether or not the tile is a wall.
function cas.tile.isWall(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "wall")
end

-- Gets whether or not the tile is an obstacle.
function cas.tile.isObstacle(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "obstacle")
end

-- Gets the entity type on the position (or false if there's none).
function cas.tile.getEntity(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	local entity = cas._cs2dCommands.tile(x, y, "entity")
	return entity == 0 and false or entity
end

-- Gets whether or not the tile was changed via "settile" command.
function cas.tile.isChanged(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "hascustomframe")
end

-- Gets the original frame of this tile (in case it was changed via "settile" command).
function cas.tile.getOriginalFrame(x, y)
	cas.tile._checkPositionParameters(x, y)
	
	return cas._cs2dCommands.tile(x, y, "originalframe")
end

--== Setters/control ==--

-- Sets the tile frame on the position.
function cas.tile.setTile(x, y, tile)
	cas.tile._checkPositionParameters(x, y)
	if type(tile) ~= "number" then
		error("Passed \"tile\" parameter is not valid. Number expected, ".. type(tile) .." passed.", 2)
	end
	
	if not (x >= 0 and y >= 0 and x <= cas.map.getXSize() and y <= cas.map.getYSize()) then
		error("Passed position is outside of map bounds!", 2)
	end
	
	if not (tile <= cas.map.getTileCount()) then
		error("Passed tile represents a non-valid tile tile.", 2)
	end
	
	cas.console.parse("settile", x, y, tile)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.tile:constructor()
	error("Instantiation of this class is not allowed.", 2)
end