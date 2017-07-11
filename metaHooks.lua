use "API"

return function(meta)
	meta.hooks = {
		startRound = Hook.new("startround", function(mode)
			-- Free all the images.
			for key, value in pairs(Image._images) do
				value._freed = true
			end
			Image._images = setmetatable({}, {__mode = "kv"})
			Image._debug:log("Images were cleared.")
			
			-- Remove all the items.
			for key, value in pairs(Item._instances) do
				if not value._removed then
					value._removed = true
					if value._fadeoutTimer then
						value._fadeoutTimer:stop()
					end
				end
			end
			Item._instances = setmetatable({}, {__mode = "kv"})
			Item._debug:log("Items were cleared.")
			
			-- Remove all the dynamic objects.
			for key, value in pairs(DynObject._instances) do
				if not value._killed then
					value._killed = true
				end
			end
			DynObject._instances = setmetatable({}, {__mode = "kv"})
			DynObject._debug:log("Dynamic objects were cleared.")
		end, -9999, "casStartround", true),
		
		leave = Hook.new("leave", function(player, reason)
			-- Remove all the images which are relevant in any way to the player. 
			-- For example, if the image is only visible to the said player or is following them.
			for key, value in pairs(Image._images) do
				-- If the image is following or visible only to the said player, free it.
				if (not value:isVisibleToEveryone() and value:getPlayer() == player) or (value._followedPlayer and value._followedPlayer == player)  then
					Image._debug:log("Image \"".. tostring(value) .."\" with path \"".. value._path .."\" was freed as the player whom it was dependant on has left the server.")
					value:free()
				end
			end
			
			for key, value in pairs(Player._instances) do
				-- Removes the player from Player._instances table.
				if value == player then
					Player._debug:log("Player \"".. tostring(value) .."\" has left.")
					Player._instances[key] = nil
				end
			end
			
			HudText._hudTexts[player._id] = setmetatable({}, {__mode = "kv"})
		end, -9999, "casLeave", true),
		
		collect = Hook.new("collect", function(player, iid, itemType, ain, a, mode)
			-- Remove the item instance once it was collected.
			for key, value in pairs(Item._instances) do
				if value._id == iid then
					value._removed = true
					if value._fadeoutTimer then
						value._fadeoutTimer:stop()
					end
					
					Item._debug:log("Item \"".. tostring(value) .."\" was removed.")	
					Item._instances[key] = nil
				end
			end
		end, -9999, "casCollect", true),
		
		objectKill = Hook.new("objectkill", function(object, player)
			-- Handles the killing of the dynamic object.
			object._killed = true
			
			for key, value in pairs(DynObject._instances) do
				if value._id == object._id then
					-- Removes the dynamic object from the DynObject._instances table.
					DynObject._debug:log("Dynamic object \"".. tostring(value) .."\" was killed.")
					DynObject._instances[key] = nil
					
					return
				end
			end
			
			-- This error should usually never happen. It does happen when someone has modified the code or 
			-- the code itself has bugs. Make sure you don't try to access the fields starting with an
			-- underscore ("_") directly and instead use setters/getters for item manipulation as it 
			-- can lead to bugs.
			error("Field \"killed\" of this instance was set to false yet it wasn't found in the \"_instances\" table.", 2)
		end, -9999, "casObjectKill", true)
	}
end
