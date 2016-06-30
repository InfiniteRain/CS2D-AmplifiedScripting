-- Initializing game class.
cas.game = cas.class()

--------------------
-- Static methods --
--------------------

--== Getters ==--

-- Gets current game version.
function cas.game.getVersion()
	return cas._cs2dCommands.game("version")
end

-- Checks if the server is dedicated.
function cas.game.isDedicated()
	return cas._cs2dCommands.game("dedicated")
end

-- Gets current game phase.
function cas.game.getPhase()
	return cas._cs2dCommands.game("phase")
end

-- Gets current round.
function cas.game.getRound()
	return cas._cs2dCommands.game("round")
end

-- Gets the score of the terrorists.
function cas.game.getTScore()
	return cas._cs2dCommands.game("score_t")
end

-- Gets the score of the counter-terrorists.
function cas.game.getCTScore()
	return cas._cs2dCommands.game("score_ct")
end

-- Gets the rounds won in a row by the terrorists.
function cas.game.getTWinRow()
	return cas._cs2dCommands.game("winrow_t")
end

-- Gets the rounds won in a row by the counter-terrorists.
function cas.game.getCTWinRow()
	return cas._cs2dCommands.game("winrow_ct")
end

-- Gets the next map in the map cycle.
function cas.game.getNextMap()
	return cas._cs2dCommands.game("nextmap")
end

-- Gets the UDP port used by the server.
function cas.game.getPort()
	return cas._cs2dCommands.game("port")
end

-- Gets whether or not the bomb was planted.
function cas.game.isBombPlanted()
	return cas._cs2dCommands.game("bombplanted")
end

-- Gets CS2D server setting.
function cas.game.getSetting(setting)
	if type(setting) ~= "string" then
		error("Passed \"setting\" parameter is not valid. String expected, ".. type(setting) .." passed.", 2)
	end
	
	return cas._cs2dCommands.game(setting)
end

--== Setters/control ==--

-- Sends a message to every client's console.
function cas.game.messageToConsole(message, color)
	if type(message) ~= "string" then
		error("Passed \"message\" parameter is not valid. String expected, ".. type(message) .." passed.", 2)
	end
	if color then
		if getmetatable(color) ~= cas.color then
			error("Passed \"color\" parameter is not valid. String expected, ".. type(color) .." passed.", 2)
		end
	end
	
	cas.console.parse("cmsg", (color and tostring(color) or "") .. message)
end

-- Sends a message to every client.
function cas.game.messageToChat(...)	
	local arguments = {...}
	local messageString = ""
	
	for key, value in pairs(arguments) do
		if getmetatable(value) == cas.color then
			messageString = messageString .. tostring(value)
		elseif type(value) == "string" then
			messageString = messageString .. value
		else
			error("Argument #".. key .." should either be an instance of the cas.color class or a string.", 2)
		end
	end
	
	cas._cs2dCommands.msg(messageString)
end

-- Fire effect.
function cas.game.fireEffect(x, y, amount, radius)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(amount) ~= "number" then
		error("Passed \"amount\" parameter is not valid. Number expected, ".. type(amount) .." passed.", 2)
	elseif type(radius) ~= "number" then
		error("Passed \"radius\" parameter is not valid. Number expected, ".. type(radius) .." passed.", 2)
	end
	
	cas.console.parse("effect", "fire", x, y, amount, radius)
end

-- Smoke effect.
function cas.game.smokeEffect(x, y, amount, radius)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(amount) ~= "number" then
		error("Passed \"amount\" parameter is not valid. Number expected, ".. type(amount) .." passed.", 2)
	elseif type(radius) ~= "number" then
		error("Passed \"radius\" parameter is not valid. Number expected, ".. type(radius) .." passed.", 2)
	end
	
	cas.console.parse("effect", "smoke", x, y, amount, radius, 0, 0, 0)
end

-- Flare effect.
function cas.game.flareEffect(x, y, amount, radius, color)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(amount) ~= "number" then
		error("Passed \"amount\" parameter is not valid. Number expected, ".. type(amount) .." passed.", 2)
	elseif type(radius) ~= "number" then
		error("Passed \"radius\" parameter is not valid. Number expected, ".. type(radius) .." passed.", 2)
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	cas.console.parse("effect", "flare", x, y, amount, radius, color:getRGB())
end

-- Fire effect.
function cas.game.colorSmokeEffect(x, y, amount, radius, color)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(amount) ~= "number" then
		error("Passed \"amount\" parameter is not valid. Number expected, ".. type(amount) .." passed.", 2)
	elseif type(radius) ~= "number" then
		error("Passed \"radius\" parameter is not valid. Number expected, ".. type(radius) .." passed.", 2)
	elseif getmetatable(color) ~= cas.color then
		error("Passed \"color\" parameter is not an instance of the \"cas.color\" class.", 2)
	end
	
	cas.console.parse("effect", "colorsmoke", x, y, amount, radius, color:getRGB())
end

-- End round.
function cas.game.endRound(mode)
	if type(mode) ~= "number" then
		error("Passed \"mode\" parameter is not valid. Number expected, ".. type(mode) .." passed.", 2)
	end
	
	if not (mode >= 0 and mode <= 2 and math.floor(mode) == mode) then
		error("Passed \"mode\" value has to be in the range of 0 - 2 with no floating point.", 2)
	end
	
	cas.console.parse("endround", mode)
end

-- Flash position.
function cas.game.flashPosition(x, y, intensity)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	elseif type(intensity) ~= "number" then
		error("Passed \"intensity\" parameter is not valid. Number expected, ".. type(intensity) .." passed.", 2)
	end
	
	if not (intensity >= 0 and intensity <= 100) then
		error("Passed \"intensity\" value has to be in the range of 0 - 100.", 2)
	end
	
	cas.console.parse("flashposition", x, y, intensity)
end

-- Restart round.
function cas.game.restartRound(delay)
	if delay then
		if type(delay) ~= "number" then
			error("Passed \"delay\" parameter is not valid. Number expected, ".. type(delay) .." passed.", 2)
		end
	end
	
	delay = delay or 0
	
	if not (delay>= 0 and delay <= 10) then
		error("Passed \"delay\" value has to be in the range of 0 - 10.", 2)
	end
	
	cas.console.parse("restart", delay)
end

-- Set team scores.
function cas.game.setTeamScores(tScore, ctScore)
	if type(tScore) ~= "number" then
		error("Passed \"tScore\" parameter is not valid. Number expected, ".. type(tScore) .." passed.", 2)
	elseif type(ctScore) ~= "number" then
		error("Passed \"ctScore\" parameter is not valid. Number expected, ".. type(ctScore) .." passed.", 2)
	end
	
	if not (tScore >= 0 and tScore <= 65535 and math.floor(tScore) == tScore) then
		error("Passed \"tScore\" value has to be in the range of 0 - 65535 with no floating point.", 2)
	elseif not (ctScore >= 0 and ctScore <= 65535 and math.floor(ctScore) == ctScore) then
		error("Passed \"ctScore\" value has to be in the range of 0 - 65535 with no floating point..", 2)
	end
	
	cas.console.parse("setteamscores", tScore, ctScore)
end

-- Trigger entity.
function cas.game.trigger(...)
	for key, value in pairs({...}) do
		if type(value) ~= "string" then
			error("Passed parameter (#".. key ..") is not valid. Number expected, ".. type(value) .." passed.", 2)
		end
	end
	
	cas.console.parse("trigger", table.concat({...}, ","))
end

-- Trigger entity at the position.
function cas.game.triggerPosition(x, y)
	if type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	cas.console.parse("triggerposition", x, y)
end

-- Plays a sound to everyone on the server.
function cas.game.playSound(path)
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	end
	
	cas.console.parse("sv_sound", path)
end

-- Plays a sound at a certain position (for 3D sound effect)
function cas.game.playPositionalSound(path, x, y)
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	elseif type(x) ~= "number" then
		error("Passed \"x\" parameter is not valid. Number expected, ".. type(x) .." passed.", 2)
	elseif type(y) ~= "number" then
		error("Passed \"y\" parameter is not valid. Number expected, ".. type(y) .." passed.", 2)
	end
	
	cas.console.parse("sv_soundpos", path, x, y)
end

-- Stops sound defined by path for everyone on the server.
function cas.game.stopSound(path)
	if type(path) ~= "string" then
		error("Passed \"path\" parameter is not valid. String expected, ".. type(path) .." passed.", 2)
	end
	
	cas.console.parse("sv_stopsound", 0, path)
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.game:constructor()
	error("Instantiation of this class is not allowed.", 2)
end

-------------------
-- Static fields --
-------------------

cas.game._effectTypes = {
	"fire", "smoke", "flare", "colorsmoke"
}