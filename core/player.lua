-- Initializin the cas.player class.
cas.player = cas.class()

----------------------
-- Instance methods --
----------------------

function cas.player:constructor(playerID)
	if not playerID then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(playerID) ~= "number" then
		error("Passed \"playerID\" parameter is not valid. Number expected, ".. type(playerID) .." passed.")
	elseif cas._cs2dCommands.player(playerID, 'exists') then
		error("Passed \"playerID\" parameter represents a non-existent player.")
	end
	
	if not cas.player._allowCreation then
		error("Instantiation of this class is not allowed at this moment.")
	end
	
	self._id = playerID
	self._exists = true
end

-------------------
-- Static fields --
-------------------

cas.player._allowCreation = false
cas.player._players = setmetatable({}, {__mode = "kv"})