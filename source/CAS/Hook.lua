-- Initializing the debug class.
local Hook = class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Event represents the cs2d hook name, func is the actual function (not a string!)
-- and priority is the optional priority value for the cs2d hook. Label is the name the hook
-- function will have in the _META.hookFuncs table.
function Hook:constructor(event, func, priority, label, silent)
  -- Validating the arguments.
  Hook._validator:validate({
    { value = event, type = 'string' },
    { value = func, type = 'function' },
    { value = priority, type = 'number', optional = true },
    {
      value = label, type = 'string', optional = true,
      regex = '^[%a_]+[%a%d_]*$',
      regexInfo = 'the string has to start with a letter and contain no '
          .. 'special/punctuational characters'
    },
    { value = silent, type = 'boolean', optional = true }
  }, 'Hook:constructor', 2)

  -- Checks if the passed event is a correct cs2d hook.
  local match = false
  for key, value in pairs(_META.config.cs2dHooks) do
    if event == key then
      match = true
      break
    end
  end
  if not match then
    error('Passed "event" value was not found in the "cs2dHooks" table in the config.', 2)
  end

  if label then
    -- Checks if passed label is not in use by any other hook.
    if _META.hookFuncs[label] then
      error('Passed "label" value is already in use by other hook(s).', 2)
    end
  end

  -- Assigning necessary fields.
  self._func = func
  self._event = event
  self._priority = priority or 0
  self._freed = false
  self._label = label or event -- If label wasn't provided, the script generates one.

  local count = 1
  while _META.hookFuncs[self._label] do -- This loop shouldn't happen if the label was provided.
    count = count + 1
    self._label = event .. count
  end

  _META.hookFuncs[self._label] = {
    originalFunc = func,
    func = function(...)
      local params = { ... }
      -- Changing all the image ID's into instances of Image.
      if _META.config.cs2dHooks[self._event].image then
        for key, value in pairs(_META.config.cs2dHooks[self._event].image) do
          local imageID = params[value]
          params[value] = Image.getInstance(imageID)
        end
      end

      -- Changing all the player ID's into instances of Player.
      if _META.config.cs2dHooks[self._event].player then
        for key, value in pairs(_META.config.cs2dHooks[self._event].player) do
          local playerID = params[value]
          if playerID >= 1 and playerID <= 32 then
            params[value] = Player.getInstance(playerID)
          else
            params[value] = false
          end
        end
      end

      -- Changing all the item type ID's into instances of ItemType.
      if _META.config.cs2dHooks[self._event].itemType then
        for key, value in pairs(_META.config.cs2dHooks[self._event].itemType) do
          local itemType = params[value]
          if ItemType.typeExists(itemType) then
            params[value] = ItemType.getInstance(itemType)
          end
        end
      end

      -- Changing all the item ID's into instances of Item.
      if _META.config.cs2dHooks[self._event].item then
        for key, value in pairs(_META.config.cs2dHooks[self._event].item) do
          local item = params[value]
          params[value] = Item.getInstance(item)
        end
      end

      -- Changing all the dynamic object ID's into instances of DynObject.
      if _META.config.cs2dHooks[self._event].dynObject then
        for key, value in pairs(_META.config.cs2dHooks[self._event].dynObject) do
          local object = params[value]
          params[value] = object ~= 0 and DynObject.getInstance(object) or false
        end
      end

      -- Changing all the entity positions into instances of Entity.
      if _META.config.cs2dHooks[self._event].entity then
        for key, value in pairs(_META.config.cs2dHooks[self._event].entity) do
          local position = { params[value[1]], params[value[2]] }
          params[value[1]] = Entity.getInstance(position[1], position[2])
          params[value[2]] = nil
        end
      end

      -- Changing all the reqcldModes into its string counterpart.
      if _META.config.cs2dHooks[self._event].reqcldMode then
        for key, value in pairs(_META.config.cs2dHooks[self._event].reqcldMode) do
          local mode = params[value]
          for k, v in pairs(Player._clientDataModes) do
            if v == value then
              params[value] = k
              break
            end
          end
        end
      end

      local returnValue = _META.hookFuncs[self._label].originalFunc(unpack(params))
      local returnString = ''
      if self._event == 'spawn' then
        if getmetatable(returnValue) == ItemType then
          returnString = tostring(returnValue:getType())
        elseif type(returnValue) == 'table' then
          for key, value in pairs(returnValue) do
            if getmetatable(value) == ItemType then
              returnString = returnString .. ',' .. value:getType()
            end
          end
        elseif type(returnValue) == 'string' and returnValue == 'x' then
          returnString = 'x'
        end

        return returnString
      else
        return returnValue
      end
    end
  }

  _META.command.addhook(event, '_META.hookFuncs.' .. self._label .. '.func', self._priority) -- Adds the hook.
  if not silent then
    Hook._debug:infoMessage('Hook with ' .. self._event .. ' event, labeled as ' .. self._label .. ' was initialized.')
  end
end

-- Destructor.
function Hook:destructor()
  if not self._freed then
    self:free()
  end
end

-- Frees the hook, meaning that cs2d will stop executing the hooked function.
function Hook:free()
  if self._freed then
    error('This hook was already freed. It\'s better if you dispose of this instance.', 2)
  end

  _META.command.freehook(self._event, '_META.hookFuncs.' .. self._label)
  _META.hookFuncs[self._label] = nil

  Hook._debug:infoMessage('Hook with ' .. self._event .. ' event, labeled as ' .. self._label .. ' was freed.')
end

--== Getters ==--

-- Gets hooked function.
function Hook:getFunction()
  if self._freed then
    error('This hook was already freed. It\'s better if you dispose of this instance.', 2)
  end

  return self._func
end

--== Setters ==--

-- Sets the hooked function.
function Hook:setFunction(func)
  if type(func) ~= 'function' then
    error('Passed "func" parameter is not valid. Function expected, ' .. type(func) .. ' passed.', 2)
  end

  if self._freed then
    error('This hook was already freed. It\'s better if you dispose of this instance.', 2)
  end

  self._func = func
  _META.hookFuncs[self._label] = func
end

-------------------
-- Static fields --
-------------------

Hook._validator = Validator()

Hook._debug = Debug(Color(115, 110, 255), 'CAS Hook')
Hook._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return Hook
