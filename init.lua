cas = {
	_globals = {
		pathToSource = "sys/lua/CS2D-AmplifiedScripting",
	},
};

local JSON = assert(loadfile(cas._globals.pathToSource .. "/lib/JSON.lua"))()
local configFile = assert(io.open(cas._globals.pathToSource .. "/config.json"))
cas._config = assert(JSON:decode(configFile:read("*all")))
configFile:close()

local funcStr = "cas._cs2dCommands = {"
for key, value in pairs(cas._config.cs2dCommands) do
	funcStr = funcStr .. value .. " = " .. value ..", "
end
funcStr = funcStr .. "}"
assert(loadstring(funcStr))()

dofile(cas._globals.pathToSource .. "/core/hook.lua")