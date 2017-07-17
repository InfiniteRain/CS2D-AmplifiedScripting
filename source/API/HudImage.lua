-- Initalizing hudImage class.
local HudImage = class(Image) -- Inherits from Image.

----------------------
-- Instance methods --
----------------------
function HudImage:constructor(path, visibleToPlayer)
  -- Checks if all the passed parameters were correct.
  local visibleToPlayer = visibleToPlayer or 0
  if type(path) ~= 'string' then
    error('Passed "path" parameter is not valid. String expected, ' .. type(path) .. ' passed.', 2)
  end
  if visibleToPlayer ~= 0 then
    if getmetatable(visibleToPlayer) ~= Player then
      error('Passed "visibleToPlayer" parameter is not an instance of the "Player" class.', 2)
    end

    if visibleToPlayer._left then
      error('The player of this instance has already left the server. It\'s better if you dispose of this instance.', 2)
    end
  end

  self:super(path, 2, visibleToPlayer)
end

-------------------------
-- Returning the class --
-------------------------
return HudImage
