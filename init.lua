--============================================================================--
-- CAS entry point. For in-depth information, please refer to the             --
-- documentation over at InfiniteRain's GitHub:                               --
-- https://github.com/InfiniteRain/CS2D-AmplifiedScripting                    --
--============================================================================--

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- LOCAL SCOPE VARIABLES                                                      --
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

---
-- Local table for the private properties of this module.
--
-- @field config
--   Configuration table for CAS.
-- @field location
--   Current location of the module.
-- @field usedNamespaces
--   Tracks used namespaces for each class file.
--
local cas = {
  -- Loading the config file.
  config = require(... .. '.config'),

  -- Location of the init.lua
  location = ...,

  -- Holds the used namespaces of each class.
  usedNamespaces = {}
}

---
-- Attempts to load a class. Namespace represents the file path to the class
-- while class name represents the file name. I.E. 'API.Color' will search
-- a file './source/API/Color.lua', execute it, and get the returned class,
-- if there is any.
--
-- @param class
--   Class name
-- @param namespaces
--   Class namespace
--
cas.loadClass = function(class, namespaces)
  -- Table for the found classes within the used namespaces.
  local foundClasses = {}

  -- Looping through the passed namespaces and looking for a class in them.
  for _, ns in pairs(namespaces) do
    -- Potential file path for the class within the current namespace.
    local filePath = cas.location:gsub('%.+', '/') .. '/' ..
        cas.config.sourceDirectory .. '/' .. ns .. '/' .. class .. '.lua'

    -- Checking if the file exists.
    local file = io.open(filePath, 'r')
    if file ~= nil then
      -- File exists.
      file:close()

      -- Requiring the file and checking if the
      local requirePath = cas.location .. '.' .. cas.config.sourceDirectory ..
          '.' .. ns .. '.' .. class
      local class = require(requirePath)
      if class ~= nil and type(class) == 'table' and class.__IS_CLASS then
        -- If all the checks are passed, adding inserting the class into the
        -- found classes table.
        table.insert(foundClasses, class)
      end
    end
  end

  -- Error handling.
  if #foundClasses == 0 then
    -- No classes found.
    return
        false,
        0,
        'Class "' .. class .. '" was not found within the used namespaces.'
  elseif #foundClasses > 1 then
    -- More than one class found.
    return
        false,
        1,
        'More than one class with the name "' .. class .. '" was found '
            .. 'within the used namespaces.\n Use a namespace table to load a '
            .. 'specific class.'
  end

  -- If everything is OK, returning the only class found.
  return foundClasses[1]
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- GLOBAL SCOPE VARIABLES                                                     --
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

---
-- Returns a class.
--
-- @param inheritsFrom
--
class = function(inheritsFrom)
  -- Checking if all the arguments are correct.
  if inheritsFrom then
    if type(inheritsFrom) ~= 'table' then
      error('Passed "inheritsFrom" parameter is not valid. Table expected, ' ..
          type(inheritsFrom) .. ' passed.',
        2)
    end
  end

  -- Initializing the class.
  local class = {}
  class.__index = class

  -- If there was a class passed, then inheriting properties from it.
  if inheritsFrom then
    -- Creating a which points to the parent class.
    class.super = setmetatable({}, {
      __index = inheritsFrom,
      __call = function(_, ...) -- If it was called as a function, then calling the constructor.
        inheritsFrom.constructor(...)
      end
    })
    setmetatable(class, { __index = inheritsFrom }) -- Inheriting properties.
  end

  setmetatable(class, {
    __call = function(_, ...)
      -- Initializing the instance.
      local instance = setmetatable({}, class)

      -- If the instance has a constructor declared, then calling it.
      if instance.constructor then
        local success, errorString = pcall(instance.constructor, instance, ...)
        if not success then
          error(errorString, 2)
        end
      end

      -- Since __gc metamethod doesn't work with tables in lua 5.1, we create a blank userdata
      -- and make its __gc method call the destructor of the object. Then, we store it as a field
      -- in the instance, so when the field is garbage collected, that means the object was
      -- garbage collected as well.
      local proxy = newproxy(true)
      local proxyMeta = getmetatable(proxy)
      proxyMeta.__gc = function()
        if instance.destructor then
          local success, errorString = pcall(instance.destructor, instance)
          if not success then
            error(errorString, 2)
          end
        end
      end
      rawset(instance, '__proxy', proxy)

      -- Returning the instance.
      return instance
    end
  })

  -- Class identifier
  class.__IS_CLASS = true

  -- Path of this class (<namespace>.<class>)
  class.__CLASS_PATH = debug.getinfo(2).source:sub(4, -5):gsub('[\\/]', '.'):sub(#(cas.location .. '.' .. cas.config.sourceDirectory .. '.') + 1, -1)

  -- Returning the class.
  return class
end

-- The following uses a namespace for a class file. Classes from within that namespace will now be loaded if called.
-- This function also returns a namespace table, which will return an indexed class, if the class exists within the
-- used namespace.
use = function(namespace)
  -- Path of this class (<namespace>.<class>)
  local thisPath = debug.getinfo(2).source:sub(4, -5):gsub('[\\/]', '.'):sub(#(cas.location .. '.' .. cas.config.sourceDirectory .. '.') + 1, -1)
  -- Namespace of this class.
  cas.usedNamespaces[thisPath] = cas.usedNamespaces[thisPath] or {}

  -- Checking if the namespace is already in use.
  local exists = false
  for _, ns in pairs(cas.usedNamespaces[thisPath]) do
    if ns == namespace then
      exists = true
    end
  end

  -- If the name space is not in use, then adding it to the used namespaces table.
  if not exists then
    table.insert(cas.usedNamespaces[thisPath], namespace)
  end

  -- Returning the namespace table.
  return setmetatable({}, {
    __index = function(self, index)
      -- Tries to load a class within the namespace, and if it loads, returns the class.
      local potentialClass = cas.loadClass(index, { namespace })
      if potentialClass then
        return potentialClass
      end
    end
  })
end

-- Namespace table which returns the current (main) namespace of the file (the folder the file is in).
here = setmetatable({}, {
  __index = function(self, index)
    -- Getting the namespace based on the location of the folder the file is in.
    local namespace = debug.getinfo(2).source:sub(4, -5):gsub('[\\/]', '.'):sub(#(cas.location .. '.' .. cas.config.sourceDirectory .. '.') + 1, -1):gsub('(.*)%.(.*)$', '%1')

    -- Tries to load a class within the namespace, and if it loads, returns the class.
    local potentialClass = cas.loadClass(index, { namespace })
    if potentialClass then
      return potentialClass
    end
  end
})

-- The following metatable declaration makes it so that any indexing of an undefined global variable will be interpreted
-- as an attempt to load a class from any of the used namespaces.
_G = setmetatable(_G, {
  __index = function(self, index)
    -- Path of this class (<namespace>.<class>)
    local thisPath = debug.getinfo(2).source:sub(4, -5):gsub('[\\/]', '.'):sub(#(cas.location .. '.' .. cas.config.sourceDirectory .. '.') + 1, -1)
    -- Namespace of this class.
    local namespace = thisPath:gsub('(.*)%.(.*)$', '%1')

    -- Tries to load a class within the used namespaces, and if it loads, returns the class.
    local potentialClass, errorNumber, errorMessage = cas.loadClass(index,
      { namespace, unpack(cas.usedNamespaces[thisPath] or {}) })

    if potentialClass then
      return potentialClass
    elseif errorNumber == 1 then
      error(errorMessage, 2)
    end
  end
})

-- Table which holds meta data for CAS.
_META = {
  config = cas.config,
  command = {},
  timerFuncs = {},
  hookFuncs = {},
  hooks = {}
}

-- Saving the existing commands, for a chance that they get overriden.
for _, command in pairs(cas.config.cs2dCommands) do
  _META.command[command] = _G[command]
end

-- Loading meta hooks.
require(cas.location .. '.metaHooks')(_META)

-----------------------------
-- THE INITIATION FUNCTION --
-----------------------------

-- Function which initializes CAS.
return function()
  local class, errorNumber, errorMessage = cas.loadClass(cas.config.mainClass:gsub('(.*)%.(.*)$', '%2'),
    { cas.config.mainClass:gsub('(.*)%.(.*)$', '%1') })
  if not class then
    error(errorMessage, 2)
  else
    if class.main and type(class.main) == 'function' then
      class.main()
    else
      error('Static method "main" does not exist in the "' .. cas.config.mainClass .. '" class.')
    end
  end
end
