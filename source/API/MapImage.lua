-- Initializing mapImage class.
local MapImage = class(Image) -- Inherits from Image.

----------------------
-- Instance methods --
----------------------

-- Constructor. Loads a map image from path with corresponding mode. You can also show it only to access
-- single player by using "visibleToPlayer" parameter.
function MapImage:constructor(path, mode, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	elseif type(mode) ~= "string" then
		error("Passed \"mode\" parameter is not valid. String expected, ".. type(mode) .." passed.", 2)
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= Player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"Player\" class.", 2)
		end
		
		if visibleToPlayer._left then
			error("The player of this instance has already left the server. It's better if you dispose of this instance.", 2)
		end
 	end
	
	-- Checks if the passed mode exists.
	if not MapImage._modes[mode] then
		error("Passed \"mode\" value does not represent a valid mode.", 2)
	end
	
	-- Calling parent's constructor.
	self:super(path, MapImage._modes[mode], visibleToPlayer)
end

-------------------
-- Static fields --
-------------------

-- Strings, representing cs2d image modes.
MapImage._modes = {
	["floor"] = 0,
	["top"] = 1,
	["supertop"] = 3
}

-------------------------
-- Returning the class --
-------------------------
return MapImage
