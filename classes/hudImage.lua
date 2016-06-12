-- Initalizing hudImage class.
cas.hudImage = cas.class(cas._image) -- Inherits from cas._image.

----------------------
-- Instance methods --
----------------------

function cas.hudImage:constructor(path, visibleToPlayer)
	-- Checks if all the passed parameters were correct.
	print(visibleToPlayer)
	local visibleToPlayer = visibleToPlayer or 0
	print(visibleToPlayer)
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	end
	if visibleToPlayer ~= 0 then
		if getmetatable(visibleToPlayer) ~= cas.player then
			error("Passed \"visibleToPlayer\" parameter is not an instance of the \"cas.player\" class.", 2)
		end
		
		if visibleToPlayer._left then
			error("The player of this instance has already left the server. It's better if you dispose of this instance.", 2)
		end
 	end
	
	self:super(path, 2, visibleToPlayer)
end