-- Initializing the AS. 
cas = { -- The global table which holds everything this mod uses.
	_pathToSource = "sys/lua/CS2D-AmplifiedScripting", -- Path to AS source folder.
};

-- Loading the first few classes which are essential for debugging.
dofile(cas._pathToSource .. "/core/class.lua")
dofile(cas._pathToSource .. "/core/color.lua")
dofile(cas._pathToSource .. "/core/debug.lua")

local initDebugger = cas.debug.new(cas.color.white, "AS Init") -- Creating the debugger for this initialization process.
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

-- Loading classes
initDebugger:log("Loading AS functionality classes...")
initDebugger:log("... Loading hook class ...")
dofile(cas._pathToSource .. "/core/hook.lua") -- Hook class
initDebugger:log("... Loading timer class ...")
dofile(cas._pathToSource .. "/core/timer.lua") -- Timer class
initDebugger:log("... Loading base image class ...")
dofile(cas._pathToSource .. "/core/_image.lua") -- Image class
initDebugger:log("... Loading mapImage class ...")
dofile(cas._pathToSource .. "/core/mapImage.lua") -- Image class
initDebugger:log("... Loading hudImage class ...")
dofile(cas._pathToSource .. "/core/hudImage.lua") -- Image class

-- Hooked function for all the image classes, frees all the images on round restart.
local function imageStartround(mode)
	for key, value in pairs(cas.mapImage._images) do
		value._freed = true
	end
	cas.mapImage._images = setmetatable({}, {__mode = "kv"})
end

cas._imageStartround = cas.hook.new("startround", imageStartround, -255, "imageStartround")

initDebugger:log("AS functionality classes were successfully loaded.")
initDebugger:infoMessage("AS initialization was successful.")
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------
--[[img = {}
for i = 1, 100 do
	img[i] = cas.mapImage.new('gfx/block.bmp', 'top')
	img[i]:setPosition(math.random(0, map('xsize') * 32), math.random(0, map('ysize') * 32))
	img[i]:setAngle(math.random(-180, 180))
	img[i]:setScale(math.random(0, 65535)/65535 + 1, math.random(0, 65535)/65535 + 1)
	img[i]:setColor(cas.color.new(math.random(1, 255), math.random(1, 255), math.random(1, 255)))
end

function k()
	for k, v in pairs(cas.mapImage._images) do
		print(k)
	end
end]]

--cas.timer.new(function() parse("msg \"Hello World!\"") end):startConstantly(1000, 5)
--collectgarbage()