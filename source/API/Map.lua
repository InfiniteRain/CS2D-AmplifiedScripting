-- Initializing map class.
local Map = class()

--------------------
-- Static methods --
--------------------

--== Getters ==--

-- Gets the name of the map.
function Map.getName()
	return _META.command.map("name")
end

-- Gets the X size of the map.
function Map.getXSize()
	return _META.command.map("xsize")
end

-- Gets the Y size of the map.
function Map.getYSize()
	return _META.command.map("ysize")
end

-- Gets the size of the map.
function Map.getSize()
	return 
		_META.command.map("xsize"),
		_META.command.map("ysize")
end

-- Gets the tileset used for the map.
function Map.getTileset()
	return _META.command.map("tileset")
end

-- Gets the number of tiles in the tileset.
function Map.getTileCount()
	return _META.command.map("tilecount")
end

-- Gets background image.
function Map.getBackgroundImage()
	return _META.command.map("back_img")
end

-- Gets background scroll X speed.
function Map.getBackgroundScrollXSpeed()
	return _META.command.map("back_scrollx")
end

-- Gets background scroll Y speed.
function Map.getBackgroundScrollYSpeed()
	return _META.command.map("back_scrolly")
end

-- Gets background scroll speed.
function Map.getBackgroundScrollSpeed()
	return 
		_META.command.map("back_scrollx"),
		_META.command.map("back_scrolly")
end

-- Gets whether or not the background scrolls like tiles.
function Map.isBackgroundScrollLikeTiles()
	return _META.command.map("back_scrolltile")
end

-- Gets background color.
function Map.getBackgroundColor()
	return Color.new(
		_META.command.map("back_r"),
		_META.command.map("back_g"),
		_META.command.map("back_b"))
end

-- Gets storm X speed.
function Map.getStormXSpeed()
	return _META.command.map("storm_x")
end

-- Gets storm Y speed.
function Map.getStormYSpeed()
	return _META.command.map("storm_y")
end

-- Gets storm speed.
function Map.getStormSpeed()
	return
		_META.command.map("storm_x"),
		_META.command.map("storm_y")
end

-- Gets the number of VIP spawns.
function Map.getVIPSpawns()
	return _META.command.map("mission_vips")
end

-- Gets the number of hostages.
function Map.getHostages()
	return _META.command.map("mission_hostages")
end

-- Gets the number of bomb spots.
function Map.getBombSpots()
	return _META.command.map("mission_bombspots")
end

-- Gets the number of CTF flags.
function Map.getCTFFlags()
	return _META.command.map("mission_ctfflags")
end

-- Gets the number of domination points.
function Map.getDomPoints()
	return _META.command.map("mission_dompoints")
end

-- Checks if buying is allowed.
function Map.isBuyingAllowed()
	return _META.command.map("nobuying") == 0 and true or false
end

-- Checks if weapons are allowed.
function Map.isWeaponsAllowed()
	return _META.command.map("noweapons") == 0 and true or false
end

-- Checks if there are any teleporters on the map.
function Map.isTelporters()
	return _META.command.map("teleporters") == 0 and false or true
end

-- Gets the number of the bot nodes.
function Map.getBotNodes()
	return _META.command.map("botnodes")
end

--== Setters/control ==--

-- Changes server map.
function Map.changeMap(name)
	if type(name) ~= "string" then
		error("Passed \"name\" parameter is not valid. String expected, ".. type(name) .." passed.", 2)
	end
	
	Console.parse("changemap", name)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function Map:constructor()
	error("Instantiation of this class is not allowed.", 2)
end

-------------------------
-- Returning the class --
-------------------------
return Map
