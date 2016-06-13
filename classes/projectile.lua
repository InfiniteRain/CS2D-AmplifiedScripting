-- Initializing projectile class.
cas.projectile = cas.class()

--------------------
-- Static methods --
--------------------

-- Frees projectile.
function cas.item.type.freeProjectile(player, projectileID)
	if getmetatable(player) ~= cas.player then
		error("Passed \"player\" parameter is not an instance of the \"cas.player\" class.", 2)
	elseif type(projectileID) ~= "number" then
		error("Passed \"projectileID\" parameter is not valid. Number expected, ".. type(projectileID) .." passed.", 2)
	end
	
	cas.console.parse("freeprojectile", projectileID, player._id)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.projectile:constructor()
	error("Instantiation of this class is not allowed.", 2)
end

-------------------
-- Static fields --
-------------------