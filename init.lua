-- Initializing the AS. 
cas = { -- The global table which holds everything this mod uses.
	_pathToSource = "sys/lua/CS2D-AmplifiedScripting", -- Path to AS source folder.
};

-- Loading the first few classes which are essential for debugging.
dofile(cas._pathToSource .. "/core/color.lua")
dofile(cas._pathToSource .. "/core/debug.lua")

local initDebugger = cas.debug.new(cas.color.white, "AS initialization") -- Creating the debugger for this initialization process.
initDebugger:setActive(true) -- Making it active.
initDebugger:log("Initializing Amplified Scripting...")
initDebugger:log("Color and debugger classes have been successfully loaded.")

-- Loading the configuration file.
initDebugger:log("Loading config...")
cas._config = assert(loadfile(cas._pathToSource .. "/config.lua"))()

-- Copying existing CS2D commands (taken from the config) and copying them into the global table 
-- just in case if initial CS2D commands are set to be removed.
local funcStr = "cas._cs2dCommands = {"
for key, value in pairs(cas._config.cs2dCommands) do
	funcStr = funcStr .. value .. " = " .. value ..", "
end
funcStr = funcStr .. "}"
assert(loadstring(funcStr))()
initDebugger:log("Config has been successfully loaded.")


initDebugger:log("Loading AS functionality classes...")
initDebugger:log("... Loading hook class ...")
dofile(cas._pathToSource .. "/core/hook.lua")
initDebugger:log("AS functionality classes were successfully loaded.")

initDebugger:infoMessage("AS initialization was successful.")