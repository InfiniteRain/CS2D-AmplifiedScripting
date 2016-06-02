-- Initializing the AS. 
cas = { -- The global table which holds everything this mod uses.
	_pathToSource = "sys/lua/CS2D-AmplifiedScripting", -- Path to AS source folder.
};

-- Loading classes functionality.
dofile(cas._pathToSource .. "/class.lua")

-- Loading the first few classes which are essential for debugging.
dofile(cas._pathToSource .. "/classes/color.lua")
dofile(cas._pathToSource .. "/classes/console.lua")
dofile(cas._pathToSource .. "/classes/debug.lua")

-- Loading the configuration file.
cas._config = assert(loadfile(cas._pathToSource .. "/config.lua"))()

-- Copying existing CS2D commands (taken from the config) and copying them into the global table 
-- just in case if initial CS2D commands are removed.
local funcStr = "cas._cs2dCommands = {"
for key, value in pairs(cas._config.cs2dCommands) do
	funcStr = funcStr .. value .. " = " .. value ..", "
end
funcStr = funcStr .. "}"
assert(loadstring(funcStr))()

-- Loading the rest of the needed classes
dofile(cas._pathToSource .. "/classes/itemType.lua") -- Item type class 
dofile(cas._pathToSource .. "/classes/groundItem.lua")
dofile(cas._pathToSource .. "/classes/player.lua") -- Player class
dofile(cas._pathToSource .. "/classes/hook.lua") -- Hook class
dofile(cas._pathToSource .. "/classes/timer.lua") -- Timer class
dofile(cas._pathToSource .. "/classes/_image.lua") -- Base image class
dofile(cas._pathToSource .. "/classes/mapImage.lua") -- Map image class
dofile(cas._pathToSource .. "/classes/hudImage.lua") -- Hud image class
dofile(cas._pathToSource .. "/classes/playerImage.lua") -- Following image class

local initDebugger = cas.debug.new(cas.color.white, "AS Init") -- Creating the debugger for this initialization process.
initDebugger:setActive(true) -- Making it active.
initDebugger:infoMessage("AS initialization was successful.")