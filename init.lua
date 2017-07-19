--====================================================================================================================--
-- CAS entry point. For in-depth information, please refer to the documentation over at InfiniteRain's GitHub:        --
-- https://github.com/InfiniteRain/CS2D-AmplifiedScripting                                                            --
--====================================================================================================================--

-- Location of the init.lua
local location = ...

-- Loading the config file.
local config = require(location .. '.config')

-- Holds the used namespaces of each class.
local usedNamespaces = {}

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
-- @return
--   Class
--
local function loadClass(class, namespaces)
    -- Table for the found classes within the used namespaces.
    local foundClasses = {}

    -- Looping through the passed namespaces and looking for a class in them.
    for _, ns in pairs(namespaces) do
        -- Potential file path for the class within the current namespace.
        local filePath =
            location:gsub('%.+', '/') .. '/' .. config.sourceDirectory .. '/' .. ns .. '/' .. class .. '.lua'

        -- Checking if the file exists.
        local file = io.open(filePath, 'r')
        if file ~= nil then
            -- File exists.
            file:close()

            -- Requiring the file and checking if the
            local requirePath = location .. '.' .. config.sourceDirectory .. '.' .. ns .. '.' .. class
            local potentialClass = require(requirePath)
            if potentialClass ~= nil and type(potentialClass) == 'table' and potentialClass.__IS_CLASS then
                -- If all the checks are passed, adding inserting the class into the
                -- found classes table.
                table.insert(foundClasses, potentialClass)
            end
        end
    end

    -- Error handling.
    if #foundClasses == 0 then
        -- No classes found.
        return false, 0, 'Class "' .. class .. '" was not found within the used namespaces.'
    elseif #foundClasses > 1 then
        -- More than one class found.
        return false, 1, 'More than one class with the name "' .. class ..'" was found within the used namespaces. '
            .. '"Use a namespace table to load a specific class.'
    end

    -- If everything is OK, returning the only class found.
    return foundClasses[1]
end

---
-- Returns the namespace and a class name of a class file.
--
-- @param level
--   File level to check at.
-- @return
--   Two values:
--     the namespace of the class (E.G. Mod.Enemies),
--     the class name (E.G. EvilChicken)
--
local function getCurrentClassPath(level)
    local filePath = debug.getinfo(level + 1).source:sub(4, -5):gsub('[\\/]', '.')
    local sourceLocation = location .. '.' .. config.sourceDirectory

    if not (filePath:sub(0, sourceLocation:len()) == sourceLocation) then
        return false
    end

    local classPath = filePath:sub(#(sourceLocation .. '.') + 1, -1)
    local regex = '(.*)%.(.*)$'

    return classPath:gsub(regex, '%1'), classPath:gsub(regex, '%2')
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Some global scope declarations which are necessary for CAS --
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

---
-- Initializes a class and returns it.
--
-- @param inheritsFrom
--   Name of the class to inherit properties from. Optional.
-- @return
--   Proposed class.
--
function class(inheritsFrom)
    -- Checking if all the arguments are correct.
    if inheritsFrom then
        if type(inheritsFrom) ~= 'table' then
            error(
                'Passed "inheritsFrom" parameter is not valid. Table expected, ' .. type(inheritsFrom) .. ' passed.',
                2
            )
        end
    end

    local ns, cn = getCurrentClassPath(2)
    if not ns then
        error('The "class" function may only be used within the files located in CAS source folder.', 2)
    end

    -- Initializing the class.
    local class = {}
    class.__index = class

    local newInstance = function(_, ...)
        -- Initializing the instance.
        local instance = setmetatable({}, class)

        -- If the instance has a constructor declared, then calling it.
        if instance.constructor then
            local success, errorString = pcall(instance.constructor, instance, ...)
            if not success then
                error(errorString, 2)
            end
        end

        -- Since __gc metamethod doesn't work with tables in lua 5.1, we create a
        -- blank userdata and make its __gc method call the destructor of the
        -- object. Then, we store it as a field in the instance, so when the field
        -- is garbage collected, that means the object was garbage collected as
        -- well.
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

    -- If there was a class passed, then inheriting properties from it.
    if inheritsFrom then
        -- Creating a which points to the parent class.
        class.super = setmetatable(
            {},
            {
                __index = inheritsFrom,
                -- If the field was called as a function, then calling the constructor.
                __call = function(_, ...)
                    inheritsFrom.constructor(...)
                end
            }
        )

        -- Inheriting properties.
        setmetatable(class, {__index = inheritsFrom, __call = newInstance})
    else
        setmetatable(class, {__call = newInstance})
    end

    -- Class identifier
    class.__IS_CLASS = true

    -- Path of this class (<namespace>.<class>)
    class.__CLASS_PATH = ns .. '.' .. cn

    -- Returning the class.
    return class
end

---
-- The following function loads a namespace for a class file. Classes from within that namespace will now be loaded when
-- called. This function also returns a namespace table, which will return an indexed class if the class exists within
-- the used namespace.
--
-- @param namespace
--   The namespace to use
-- @return
--   A namespace table (on success)
--
function use(namespace)
    -- Path of this class (<namespace>.<class>)
    local ns, cn = getCurrentClassPath(2)
    if not ns then
        error('The "use" function may only be used within the files located in CAS source folder.', 2)
    end

    local thisPath = ns .. '.' .. cn

    -- Namespace of this class.
    usedNamespaces[thisPath] = usedNamespaces[thisPath] or {}

    -- Checking if the namespace is already in use.
    local exists = false
    for _, cns in pairs(usedNamespaces[thisPath]) do
        if cns == namespace then
            exists = true
        end
    end

    -- If the name space is not in use, then adding it to the used namespaces table.
    if not exists then
        table.insert(usedNamespaces[thisPath], namespace)
    end

    -- Returning the namespace table.
    return setmetatable(
        {},
        {
            __index = function(_, index)
                -- Tries to load a class within the namespace, and if it loads, returns
                -- the class.
                local potentialClass = loadClass(index, {namespace})
                if potentialClass then
                    return potentialClass
                end
            end
        }
    )
end

---
-- Namespace table which represents the current (main) namespace of the class file (the folder the class file is in).
--
here = setmetatable(
    {},
    {
        __index = function(_, index)
            -- Getting the namespace based on the location of the folder the file is in.
            local namespace, _ = getCurrentClassPath(2)

            -- Tries to load a class within the namespace, and if it loads, returns the class.
            local potentialClass = loadClass(index, {namespace})
            if potentialClass then
                return potentialClass
            end
        end
    }
)

---
-- The following metatable declaration makes it so that any indexing of an undefined global variable will be interpreted
-- as an attempt to load a class from any of the used namespaces.
--
setmetatable(
    _G,
    {
        __index = function(_, index)
            local namespace, cn = getCurrentClassPath(2)
            local classPath = namespace .. '.' .. cn

            -- Tries to load a class within the used namespaces, and if it loads, returns the class.
            local potentialClass,
                errorNumber,
                errorMessage = loadClass(index, {namespace, unpack(usedNamespaces[classPath] or {})})

            if potentialClass then
                return potentialClass
            elseif errorNumber == 1 then
                error(errorMessage, 2)
            end
        end
    }
)

---
-- Global table for CAS meta data
--
-- @field config
--   Loaded config from config.lua
-- @field command
--   Table storing all the global Lua functions which are CS2D related.
-- @field timeFuncs
--   Table which stores functions for timers.
-- @field hookFuncs
--   Table which stores functions for hooks.
--
_META = {
    config = config,
    command = {},
    timerFuncs = {},
    hookFuncs = {},
}

-- Saving the existing commands, for a chance that they get overriden.
for _, command in pairs(config.cs2dCommands) do
    _META.command[command] = _G[command]
end

--~~~~~~~~~~~~~~~~~~--
-- Initializing CAS --
--~~~~~~~~~~~~~~~~~~--

local init, _, iErrorMessage = loadClass('Init', {'CAS'})
if not init then
    error(iErrorMessage)
end

local mainClassNS = config.mainClass:gsub('(.*)%.(.*)$', '%1')
local mainClass = config.mainClass:gsub('(.*)%.(.*)$', '%2')
local class, _, errorMessage = loadClass(mainClass, {mainClassNS})
if not class then
    error(errorMessage, 2)
else
    if class.main and type(class.main) == 'function' then
        class.main()
    else
        error('Method "main" does not exist in the "' .. config.mainClass .. '" class.')
    end
end
