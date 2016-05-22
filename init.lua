cas = {
	_globals = {
		pathToSource = "sys/lua/CS2D-AmplifiedScripting",
	},
};

cas._config = assert(loadfile(cas._globals.pathToSource .. "/config.lua"))()

local funcStr = "cas._cs2dCommands = {"
for key, value in pairs(cas._config.cs2dCommands) do
	funcStr = funcStr .. value .. " = " .. value ..", "
end
funcStr = funcStr .. "}"
assert(loadstring(funcStr))()

dofile(cas._globals.pathToSource .. "/core/color.lua")
dofile(cas._globals.pathToSource .. "/core/debug.lua")
dofile(cas._globals.pathToSource .. "/core/hook.lua")