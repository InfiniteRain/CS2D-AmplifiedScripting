-- Initializing the AS. 
cas = { -- The global table which holds everything this mod uses.
	_pathToSource = "sys/lua/CS2D-AmplifiedScripting", -- Path to CAS source folder.
};

-- Loading the configuration file.
cas._config = assert(loadfile(cas._pathToSource .. "/config.lua"))()

-- Taking existing CS2D commands (from the config) and copying them into the global table 
-- just in case if initial CS2D commands are removed.
local funcStr = "cas._cs2dCommands = {"
for key, value in pairs(cas._config.cs2dCommands) do
	funcStr = funcStr .. value .. " = " .. value ..", "
end
funcStr = funcStr .. "}"
assert(loadstring(funcStr))()

-- Loading classes functionality.
dofile(cas._pathToSource .. "/class.lua")

-- Loading CAS classes.
dofile(cas._pathToSource .. "/classes/color.lua")
dofile(cas._pathToSource .. "/classes/console.lua")
dofile(cas._pathToSource .. "/classes/debug.lua")
dofile(cas._pathToSource .. "/classes/itemType.lua")
dofile(cas._pathToSource .. "/classes/groundItem.lua")
dofile(cas._pathToSource .. "/classes/player.lua")
dofile(cas._pathToSource .. "/classes/hook.lua")
dofile(cas._pathToSource .. "/classes/timer.lua")
dofile(cas._pathToSource .. "/classes/dynObject.lua")
dofile(cas._pathToSource .. "/classes/_image.lua")
dofile(cas._pathToSource .. "/classes/mapImage.lua")
dofile(cas._pathToSource .. "/classes/hudImage.lua")
dofile(cas._pathToSource .. "/classes/playerImage.lua")

local initDebugger = cas.debug.new(cas.color.white, "CAS Init") -- Creating the debugger for this initialization process.
initDebugger:setActive(true) -- Making it active.
initDebugger:infoMessage("CAS initialization was successful.")