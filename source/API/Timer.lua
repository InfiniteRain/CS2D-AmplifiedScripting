-- Initializing the timer class
local Timer = class()

----------------------
-- Instance methods --
----------------------

-- Constructor. Creates a timer with a function it supposed to run.
function Timer:constructor(func)
	-- Checks if all the passed parameters were correct.
	if type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.", 2)
	end
	
	-- Assigning necessary fields.
	self._funcLabel = "func"
	self._repetitions = 0
	
	local count = 1
	while Timer._timerLabels[self._funcLabel] do
		count = count + 1
		self._funcLabel = "func" .. count 
	end
	Timer._timerLabels[self._funcLabel] = true
	
	self._func = func
	
	Timer._debug:log("Timer \"".. tostring(self) .."\" initialized.")
end

-- Destructor.
function Timer:destructor()
	if _META.timerFuncs[self._funcLabel] and
		not _META.timerFuncs[self._funcLabel].repetition then -- Checks if the timer is being constantly run.
		self:stop() -- If it is, stops the timer.
	end
	
	Timer._timerLabels[self._funcLabel] = nil
	
	Timer._debug:log("Timer \"".. tostring(self) .."\" was garbage collected.")
end

-- Starts the timer with provided interval and repetitions.
function Timer:start(milliseconds, repetitions, ...)
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
	if _META.timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.", 2)
	end
	
	-- Makes the timer entry.
	_META.timerFuncs[self._funcLabel] = {
		repetition = repetitions, -- Amount of repetitions left.
		originalFunc = self._func, -- The original function, passed as the constructor parameter.
		parameters = setmetatable({...}, {__mode = "kv"}),
		func = function(label) -- Function which will be run by the timer itself, makes sure to 
							   -- remove its entry from _META.timerFuncs table once finished.
			_META.timerFuncs[label].originalFunc(unpack(_META.timerFuncs[label].parameters))
			_META.timerFuncs[label].repetition = _META.timerFuncs[label].repetition - 1
			if _META.timerFuncs[label].repetition <= 0 then
				_META.timerFuncs[label] = nil
				
				Timer._debug:log("Timer \"".. tostring(self) .."\" has been stopped. (planned)")
			end
		end
	}
	
	-- Initiating the timer.
	_META.command.timer(milliseconds, "_META.timerFuncs.".. self._funcLabel ..".func", self._funcLabel, repetitions)
	
	Timer._debug:log("Timer \"".. tostring(self) .."\" started with interval of ".. milliseconds .." and ".. repetitions .." repetitions.")
	
	return self
end

-- Starts the timer with provided interval, will be run constantly until stopped.
function Timer:startConstantly(milliseconds, ...)
	-- Checks if all the passed parameters were correct.
	if type(milliseconds) ~= "number" then
		error("Passed \"milliseconds\" parameter is not valid. Number expected, ".. type(milliseconds) .." passed.", 2)
	end
	
	-- Makes sure the timer isn't already running.
	if _META.timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.", 2)
	end
	
	-- Makes the timer entry.
	_META.timerFuncs[self._funcLabel] = {
		originalFunc = self._func,
		parameters = setmetatable({...}, {__mode = "kv"}),
		func = function(label)
			_META.timerFuncs[label].originalFunc(unpack(_META.timerFuncs[label].parameters))
		end
	}
	
	-- Initiating the timer.
	_META.command.timer(milliseconds, "_META.timerFuncs.".. self._funcLabel ..".func", self._funcLabel, 0)
	
	Timer._debug:log("Timer \"".. tostring(self) .."\" started constantly with interval of ".. milliseconds ..".")
	
	return self
end

-- Stops the timer.
function Timer:stop()
	_META.command.freetimer("_META.timerFuncs.".. self._funcLabel ..".func", self._funcLabel) -- Frees the timer.
	_META.timerFuncs[self._funcLabel] = nil -- Removes the timer entry.
	
	Timer._debug:log("Timer \"".. tostring(self) .."\" has been stopped. (unplanned)")
	
	return self
end

--== Getters ==--

-- Gets whether or not the timer is running.
function Timer:isRunning()
	return _META.timerFuncs[self._funcLabel] ~= nil
end

-- Gets whether or not the timer is being run constantly.
function Timer:isRunningConstantly()
	if _META.timerFuncs[self._funcLabel] then
		return _META.timerFuncs[self._funcLabel].repetition == nil
	end
	
	return false
end

-- Gets the current repetition.
function Timer:getRepetition()
	if not _META.timerFuncs[self._funcLabel] then
		error("The timer is not running.", 2)
	elseif _META.timerFuncs[self._funcLabel].repetition == nil then
		error("The timer is being run constantly.", 2)
	end

	return _META.timerFuncs[self._funcLabel].repetition
end

-------------------
-- Static fields --
-------------------

Timer._timerLabels = {} -- Table used for timer labels.
Timer._debug = Debug.new(Color.yellow, "CAS Timer") -- Debug for timers.
Timer._debug:setActive(_META.config.debugMode)

-------------------------
-- Returning the class --
-------------------------
return Timer
