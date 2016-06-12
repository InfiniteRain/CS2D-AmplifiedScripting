-- Initializing map class.
cas.map = cas.class()

--------------------
-- Static methods --
--------------------

--== Getters ==--

-- Gets the name of the map.
function cas.map.getName()
	return cas._cs2dCommands.map("name")
end

-- Gets the X size of the map.
function cas.map.getXSize()
	return cas._cs2dCommands.map("xsize")
end

-- Gets the Y size of the map.
function cas.map.getYSize()
	return cas._cs2dCommands.map("ysize")
end

-- Gets the size of the map.
function cas.map.getSize()
	return 
		cas._cs2dCommands.map("xsize"),
		cas._cs2dCommands.map("ysize")
end

-- Gets the tileset used for the map.
function cas.map.getTileset()
	return cas._cs2dCommands.map("tileset")
end

-- Gets the number of tiles in the tileset.
function cas.map.getTileCount()
	return cas._cs2dCommands.map("tilecount")
end

-- Gets background image.
function cas.map.getBackgroundImage()
	return cas._cs2dCommands.map("back_img")
end

-- Gets background scroll X speed.
function cas.map.getBackgroundScrollXSpeed()
	return cas._cs2dCommands.map("back_scrollx")
end

-- Gets background scroll Y speed.
function cas.map.getBackgroundScrollYSpeed()
	return cas._cs2dCommands.map("back_scrolly")
end

-- Gets background scroll speed.
function cas.map.getBackgroundScrollSpeed()
	return 
		cas._cs2dCommands.map("back_scrollx"),
		cas._cs2dCommands.map("back_scrolly")
end

-- Gets whether or not the background scrolls like tiles.
function cas.map.isBackgroundScrollLikeTiles()
	return cas._cs2dCommands.map("back_scrolltile")
end

-- Gets background color.
function cas.map.getBackgroundColor()
	return cas.color.new(
		cas._cs2dCommands.map("back_r"),
		cas._cs2dCommands.map("back_g"),
		cas._cs2dCommands.map("back_b"))
end

-- Gets storm X speed.
function cas.map.getStormXSpeed()
	return cas._cs2dCommands.map("storm_x")
end

-- Gets storm Y speed.
function cas.map.getStormYSpeed()
	return cas._cs2dCommands.map("storm_y")
end

-- Gets storm speed.
function cas.map.getStormSpeed()
	return
		cas._cs2dCommands.map("storm_x"),
		cas._cs2dCommands.map("storm_y")
end

-- Gets the number of VIP spawns.
function cas.map.getVIPSpawns()
	return cas._cs2dCommands.map("mission_vips")
end

-- Gets the number of hostages.
function cas.map.getHostages()
	return cas._cs2dCommands.map("mission_hostages")
end

-- Gets the number of bomb spots.
function cas.map.getBombSpots()
	return cas._cs2dCommands.map("mission_bombspots")
end

-- Gets the number of CTF flags.
function cas.map.getCTFFlags()
	return cas._cs2dCommands.map("mission_ctfflags")
end

-- Gets the number of domination points.
function cas.map.getDomPoints()
	return cas._cs2dCommands.map("mission_dompoints")
end

-- Checks if buying is allowed.
function cas.map.isBuyingAllowed()
	return cas._cs2dCommands.map("nobuying") == 0 and true or false
end

-- Checks if weapons are allowed.
function cas.map.isWeaponsAllowed()
	return cas._cs2dCommands.map("noweapons") == 0 and true or false
end

-- Checks if there are any teleporters on the map.
function cas.map.isTelporters()
	return cas._cs2dCommands.map("teleporters") == 0 and false or true
end

-- Gets the number of the bot nodes.
function cas.map.getBotNodes()
	return cas._cs2dCommands.map("botnodes")
end

--== Setters/control ==--

-- Changes server map.
function cas.map.changeMap(name)
	if type(name) ~= "string" then
		error("Passed \"name\" parameter is not valid. String expected, ".. type(name) .." passed.", 2)
	end
	
	cas.console.parse("changemap", name)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.map:constructor()
	error("Instantiation of this class is not allowed.", 2)
end