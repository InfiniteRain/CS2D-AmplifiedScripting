-- Initializing projectile class.
local Projectile = class()

--------------------
-- Static methods --
--------------------

-- Spawns projectile.
function Projectile.spawn(player, itemType, x, y, flyDistance, angle)
	if getmetatable(player) ~= Player then
		error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
	elseif getmetatable(itemType) ~= ItemType then
		error("Passed \"itemType\" parameter is not an instance of the \"ItemType\" class.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(flyDistance) ~= "number" then
		error("Passed \"flyDistance\" parameter is not valid. Number expected, ".. type(flyDistance) .." passed.", 2)
	elseif type(angle) ~= "number" then
		error("Passed \"angle\" parameter is not valid. Number expected, ".. type(angle) .." passed.", 2)
	end
	
	Console.parse("spawnprojectile", player._id, itemType._typeId, x, y, flyDistance, angle)
end

-- Frees projectile.
function Projectile.free(player, projectileID)
	if getmetatable(player) ~= Player then
		error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
	elseif type(projectileID) ~= "number" then
		error("Passed \"projectileID\" parameter is not valid. Number expected, ".. type(projectileID) .." passed.", 2)
	end
	
	Console.parse("freeprojectile", projectileID, player._id)
end

-- Gets projectile info.
function Projectile.getInfo(player, projectileID, valueString)
	if getmetatable(player) ~= Player then
		error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
	elseif type(projectileID) ~= "number" then
		error("Passed \"projectileID\" parameter is not valid. Number expected, ".. type(projectileID) .." passed.", 2)
	elseif type(valueString) ~= "string" then
		error("Passed \"valueString\" parameter is not valid. String expected, ".. type(valueString) .." passed.", 2)
	end
	
	return _META.command.projectile(projectileID, player._id, valueString)
end

-- Gets projectile list.
function Projectile.getProjectiles(listType, player)
	if listType then
		if type(listType) ~= "string" then
			error("Passed \"listType\" parameter is not valid. String expected, ".. type(listType) .." passed.", 2)
		end
		
		if not (listType == "ground" or listType == "flying") then
			error("List type can only be either \"ground\" or \"flying\".")
		end
	end
	if player then
		if getmetatable(player) ~= Player then
			error("Passed \"player\" parameter is not an instance of the \"Player\" class.", 2)
		end
	end
	
	local list = _META.command.projectilelist(listType == "flying" and 0 or 1, player and player or 0)
	local newList = {}
	for key, value in pairs(list) do
		newList[key] = {id = value.id, player = Player.getInstance(value.player)}
	end
	
	return newList
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function Projectile:constructor()
	error("Instantiation of this class is not allowed.", 2)
end

-------------------------
-- Returning the class --
-------------------------
return Projectile
