-- Initializing the AS. 
cas = { -- The global table which holds everything this mod uses.
	_pathToSource = "sys/lua/CS2D-AmplifiedScripting", -- Path to AS source folder.
};

-- Loading the first few classes which are essential for debugging.
dofile(cas._pathToSource .. "/core/class.lua")
dofile(cas._pathToSource .. "/core/color.lua")
dofile(cas._pathToSource .. "/core/console.lua")
dofile(cas._pathToSource .. "/core/debug.lua")

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

-- Loading classes
dofile(cas._pathToSource .. "/core/itemType.lua") -- Item type class 
dofile(cas._pathToSource .. "/core/player.lua") -- Player class
dofile(cas._pathToSource .. "/core/hook.lua") -- Hook class
dofile(cas._pathToSource .. "/core/timer.lua") -- Timer class
dofile(cas._pathToSource .. "/core/_image.lua") -- Base image class
dofile(cas._pathToSource .. "/core/mapImage.lua") -- Map image class
dofile(cas._pathToSource .. "/core/hudImage.lua") -- Hud image class

local initDebugger = cas.debug.new(cas.color.white, "AS Init") -- Creating the debugger for this initialization process.
initDebugger:setActive(true) -- Making it active.
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

--[[local img = image('gfx/block.bmp', 64, 64, 0)
imagepos(img, 50, 50, 20)
imagealpha(img, 0.5)]]

--[[local coolImage = cas.mapImage.new('gfx/block.bmp', 'top')
coolImage:setPosition(50, 50)
coolImage:setAngle(20)
coolImage:setAlpha(0.5)]]
