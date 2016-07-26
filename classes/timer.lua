-- Initializing the timer class
cas.timer = cas.class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a timer with a function it supposed to run.
function cas.timer:constructor(func)
	-- Checks if all the passed parameters were correct.
	if type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.", 2)
	end
	
	-- Assigning necessary fields.
	self._funcLabel = "func"
	self._repetitions = 0
	
	local count = 1
	while cas.timer._timerLabels[self._funcLabel] do
		count = count + 1
		self._funcLabel = "func" .. count 
	end
	cas.timer._timerLabels[self._funcLabel] = true
	
	self._func = func
	
	cas.timer._debug:log("Timer \"".. tostring(self) .."\" initialized.")
end

-- Destructor.
function cas.timer:destructor()
	if cas.timer._timerFuncs[self._funcLabel] and
		not cas.timer._timerFuncs[self._funcLabel].repetition then -- Checks if the timer is being constantly run.
		self:stop() -- If it is, stops the timer.
	end
	
	cas.timer._timerLabels[self._funcLabel] = nil
	
	cas.timer._debug:log("Timer \"".. tostring(self) .."\" was garbage collected.")
end

-- Starts the timer with provided interval and repetitions.
function cas.timer:start(milliseconds, repetitions, ...)
	-- Checks if all the passed parameters were correct.
	if type(milliseconds) ~= "number" then
		error("Passed \"milliseconds\" parameter is not valid. Number expected, ".. type(milliseconds) .." passed.", 2)
	end
	if repetitions then
		if type(repetitions) ~= "number" then
			error("Passed \"repetitions\" parameter is not valid. Number expected, ".. type(repetitions) .." passed.", 2)
		end
	end
	
	if repetitions <= 0 then return end
	
	-- Makes sure the timer isn't already running.
	if cas.timer._timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.", 2)
	end
	
	-- Makes the timer entry.
	cas.timer._timerFuncs[self._funcLabel] = {
		repetition = repetitions, -- Amount of repetitions left.
		originalFunc = self._func, -- The original function, passed as the constructor parameter.
		parameters = setmetatable({...}, {__mode = "kv"}),
		func = function(label) -- Function which will be run by the timer itself, makes sure to 
							   -- remove its entry from cas.timer._timerFuncs table once finished.
			cas.timer._timerFuncs[label].originalFunc(unpack(cas.timer._timerFuncs[label].parameters))
			cas.timer._timerFuncs[label].repetition = cas.timer._timerFuncs[label].repetition - 1
			if cas.timer._timerFuncs[label].repetition <= 0 then
				cas.timer._timerFuncs[label] = nil
				
				cas.timer._debug:log("Timer \"".. tostring(self) .."\" has been stopped. (planned)")
			end
		end
	}
	
	-- Initiating the timer.
	cas._cs2dCommands.timer(milliseconds, "cas.timer._timerFuncs.".. self._funcLabel ..".func", self._funcLabel, repetitions)
	
	cas.timer._debug:log("Timer \"".. tostring(self) .."\" started with interval of ".. milliseconds .." and ".. repetitions .." repetitions.")
	
	return self
end

-- Starts the timer with provided interval, will be run constantly until stopped.
function cas.timer:startConstantly(milliseconds, ...)
	-- Checks if all the passed parameters were correct.
	if type(milliseconds) ~= "number" then
		error("Passed \"milliseconds\" parameter is not valid. Number expected, ".. type(milliseconds) .." passed.", 2)
	end
	
	-- Makes sure the timer isn't already running.
	if cas.timer._timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.", 2)
	end
	
	-- Makes the timer entry.
	cas.timer._timerFuncs[self._funcLabel] = {
		originalFunc = self._func,
		parameters = setmetatable({...}, {__mode = "kv"}),
		func = function(label)
			cas.timer._timerFuncs[label].originalFunc(unpack(cas.timer._timerFuncs[label].parameters))
		end
	}
	
	-- Initiating the timer.
	cas._cs2dCommands.timer(milliseconds, "cas.timer._timerFuncs.".. self._funcLabel ..".func", self._funcLabel, 0)
	
	cas.timer._debug:log("Timer \"".. tostring(self) .."\" started constantly with interval of ".. milliseconds ..".")
	
	return self
end

-- Stops the timer.
function cas.timer:stop()
	cas._cs2dCommands.freetimer("cas.timer._timerFuncs.".. self._funcLabel ..".func", self._funcLabel) -- Frees the timer.
	cas.timer._timerFuncs[self._funcLabel] = nil -- Removes the timer entry.
	
	cas.timer._debug:log("Timer \"".. tostring(self) .."\" has been stopped. (unplanned)")
	
	return self
end

--== Getters ==--

-- Gets whether or not the timer is running.
function cas.timer:isRunning()
	return cas.timer._timerFuncs[self._funcLabel] ~= nil
end

-- Gets whether or not the timer is being run constantly.
function cas.timer:isRunningConstantly()
	if cas.timer._timerFuncs[self._funcLabel] then
		return cas.timer._timerFuncs[self._funcLabel].repetition == nil
	end
	
	return false
end

-- Gets the current repetition.
function cas.timer:getRepetition()
	if not cas.timer._timerFuncs[self._funcLabel] then
		error("The timer is not running.", 2)
	elseif cas.timer._timerFuncs[self._funcLabel].repetition == nil then
		error("The timer is being run constantly.", 2)
	end

	return cas.timer._timerFuncs[self._funcLabel].repetition
end


-------------------
-- Static fields --
-------------------

cas.timer._timerLabels = {} -- Table used for timer labels.
cas.timer._timerFuncs = {} -- Table for timer entries.
cas.timer._debug = cas.debug.new(cas.color.yellow, "CAS Timer") -- Debug for timers.
--cas.timer._debug:setActive(true)