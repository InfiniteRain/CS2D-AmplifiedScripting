-- Initalizing hudImage class.
cas.hudImage = cas.class(cas._image) -- Inherits from cas._image.

----------------------
-- Instance methods --
----------------------

function cas.hudImage:constructor(path, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	local visibleToPlayer = visibleToPlayer or 0
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.")
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= cas.player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"cas.player\" class.")
		end
 	end
	
	self:super(path, 2, visibleToPlayer)
end