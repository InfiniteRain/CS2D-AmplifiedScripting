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
dofile(cas._pathToSource .. "/classes/item.lua")
dofile(cas._pathToSource .. "/classes/itemType.lua")
dofile(cas._pathToSource .. "/classes/player.lua")
dofile(cas._pathToSource .. "/classes/hook.lua")
dofile(cas._pathToSource .. "/classes/timer.lua")
dofile(cas._pathToSource .. "/classes/dynObject.lua")
dofile(cas._pathToSource .. "/classes/dynObjectType.lua")
dofile(cas._pathToSource .. "/classes/_image.lua")
dofile(cas._pathToSource .. "/classes/mapImage.lua")
dofile(cas._pathToSource .. "/classes/hudImage.lua")
dofile(cas._pathToSource .. "/classes/playerImage.lua")

--== Hooks which clean up data of certain classes. ==--

cas._hooks = {
	startRound = {
		func = function(mode)
			-- Free all the images.
			for key, value in pairs(cas._image._images) do
				value._freed = true
			end
			cas._image._images = setmetatable({}, {__mode = "kv"})
			cas._image._debug:log("Images were cleared.")
			
			-- Remove all the items.
			for key, value in pairs(cas.item._instances) do
				if not value._removed then
					value._removed = true
					if value._fadeoutTimer then
						value._fadeoutTimer:stop()
					end
				end
			end
			cas.item._instances = setmetatable({}, {__mode = "kv"})
			cas.item._debug:log("Items were cleared.")
			
			-- Remove all the dynamic objects.
			for key, value in pairs(cas.dynObject._instances) do
				if not value._killed then
					value._killed = true
				end
			end
			cas.dynObject._instances = setmetatable({}, {__mode = "kv"})
			cas.dynObject._debug:log("Dynamic objects were cleared.")
		end
	},
	
	leave = {
		func = function(player, reason)
			-- Remove all the images which are relevant in any way to the player. 
			-- For example, if the image is only visible to the said player or is following them.
			for key, value in pairs(cas._image._images) do
				-- If the image is following or visible only to the said player, free it.
				if (not value:isVisibleToEveryone() and value:getPlayer() == player) or (value._followedPlayer and value._followedPlayer == player)  then
					cas._image._debug:log("Image \"".. tostring(value) .."\" with path \"".. value._path .."\" was freed as the player whom it was dependant on has left the server.")
					value:free()
				end
			end
			
			for key, value in pairs(cas.player._instances) do
				-- Removes the player from cas._player._instances table.
				if value == player then
					cas.player._debug:log("Player \"".. tostring(value) .."\" has left.")
					cas.player._instances[key] = nil
				end
			end
		end
	},
	
	collect = {
		func = function(player, iid, itemType, ain, a, mode)
			-- Remove the item instance once it was collected.
			for key, value in pairs(cas.item._instances) do
				if value._id == iid then
					value._removed = true
					if value._fadeoutTimer then
						value._fadeoutTimer:stop()
					end
					
					cas.item._debug:log("Item \"".. tostring(value) .."\" was removed.")	
					cas.item._instances[key] = nil
				end
			end
		end
	},
	
	objectKill = {
		func = function(object, player)
			-- Handles the killing of the dynamic object.
			object._killed = true
			
			for key, value in pairs(cas.dynObject._instances) do
				if value._id == object._id then
					-- Removes the dynamic object from the cas.dynObject._instances table.
					cas.dynObject._debug:log("Dynamic object \"".. tostring(value) .."\" was killed.")
					cas.dynObject._instances[key] = nil
					
					return
				end
			end
			
			-- This error should usually never happen. It does happen when someone has modified the code or 
			-- the code itself has bugs. Make sure you don't try to access the fields starting with an
			-- underscore ("_") directly and instead use setters/getters for item manipulation as it 
			-- can lead to bugs.
			error("Field \"killed\" of this instance was set to false yet it wasn't found in the \"_instances\" table.", 2)
		end
	}
}

-- Instantiating the proposed hooks.
cas._hooks.startRound.hook = cas.hook.new("startround",	cas._hooks.startRound.func, -9999, "casStartRound")
cas._hooks.leave.hook = cas.hook.new("leave", cas._hooks.leave.func, -9999, "casLeave")
cas._hooks.collect.hook = cas.hook.new("collect", cas._hooks.collect.func, -9999, "casCollect")
cas._hooks.objectKill.hook = cas.hook.new("objectkill", cas._hooks.objectKill.func, -9999, "casObjectKill")

-- CAS initialization complete. Notify in the console.
local initDebugger = cas.debug.new(cas.color.white, "CAS Init") -- Making a temporary debug object.
initDebugger:setActive(true) -- Making it active.
initDebugger:infoMessage("CAS initialization was successful.") -- Showing the information.