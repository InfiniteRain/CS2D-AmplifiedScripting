-- Initializing the timer class
cas.timer = {}
cas.timer.__index = cas.timer

--------------------
-- Static methods --
--------------------

-- Constructor. Creates a timer with a function it supposed to run.
function cas.timer.new(func)
	-- Checks if all the passed parameters were correct.
	if not func then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(func) ~= "function" then
		error("Passed \"func\" parameter is not valid. Function expected, ".. type(func) .." passed.")
	end
	
	-- Creates the instance itself.
	local self = {}
	setmetatable(self, cas.timer)
	
	-- Makes sure destructor works.
	local proxy = newproxy(true)
	local proxyMeta = getmetatable(proxy)
	proxyMeta.__gc = function() if self.destructor then self:destructor() end end
	rawset(self, '__proxy', proxy)
	
	-- Assigning necessary fields.
	self._funcLabel = "func"
	self._repetitions = 0
	
	local count = 1
	while cas.timer._timerFuncs[self._funcLabel] do
		count = count + 1
		self._funcLabel = "func" .. count 
	end
	
	self._func = func
	
	return self
end

----------------------
-- Instance methods --
----------------------

-- Destructor.
function cas.timer:destructor()
	if not cas.timer._timerFuncs[self._funcLabel].repetition then -- Checks if the timer is being constantly run.
		self:stop() -- If it is, stops the timer.
	end
end

-- Starts the timer with provided interval and repetitions.
function cas.timer:start(milliseconds, repetitions)
	-- Checks if all the passed parameters were correct.
	if not milliseconds then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(milliseconds) ~= "number" then
		error("Passed \"milliseconds\" parameter is not valid. Number expected, ".. type(milliseconds) .." passed.")
	end
	if repetitions then
		if type(repetitions) ~= "number" then
			error("Passed \"repetitions\" parameter is not valid. Number expected, ".. type(repetitions) .." passed.")
		end
	end
	
	if repetitions <= 0 then return end
	
	-- Makes sure the timer isn't already running.
	if cas.timer._timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.")
	end
	
	-- Makes the timer entry.
	cas.timer._timerFuncs[self._funcLabel] = {
		repetition = repetitions, -- Amount of repetitions left.
		originalFunc = self._func, -- The original function, passed as the constructor parameter.
		func = function(label) -- Function which will be run by the timer itself, makes sure to 
							   -- remove its entry from cas.timer._timerFuncs table once finished.
			cas.timer._timerFuncs[label].originalFunc()
			cas.timer._timerFuncs[label].repetition = cas.timer._timerFuncs[label].repetition - 1
			if cas.timer._timerFuncs[label].repetition <= 0 then
				cas.timer._timerFuncs[label] = nil
			end
		end
	}
	
	-- Initiating the timer.
	cas._cs2dCommands.timer(milliseconds, "cas.timer._timerFuncs.".. self._funcLabel ..".func", self._funcLabel, repetitions)
end

-- Starts the timer with provided interval, will be run constantly until stopped.
function cas.timer:startConstantly(milliseconds)
	-- Checks if all the passed parameters were correct.
	if not milliseconds then
		error("No parameters were passed, expected at least 1 parameter.")
	elseif type(milliseconds) ~= "number" then
		error("Passed \"milliseconds\" parameter is not valid. Number expected, ".. type(milliseconds) .." passed.")
	end
	
	-- Makes sure the timer isn't already running.
	if cas.timer._timerFuncs[self._funcLabel] then
		error("Timer has already started. Stop it before trying to start it again.")
	end
	
	-- Makes the timer entry.
	cas.timer._timerFuncs[self._funcLabel] = {func = self._func}
	
	-- Initiating the timer.
	cas._cs2dCommands.timer(milliseconds, "cas.timer._timerFuncs.".. self._funcLabel ..".func", "", 0)
end

-- Stops the timer.
function cas.timer:stop()
	cas._cs2dCommands.freetimer("cas.timer._timerFuncs.".. self._funcLabel ..".func") -- Frees the timer.
	cas.timer._timerFuncs[self._funcLabel] = nil -- Removes the timer entry.
end

--== Getters ==--

-- Gets whether or not the timer is running.
function cas.timer:isRunning()
	return cas.timer._timerFuncs[self._funcLabel] ~= nil
end

-- Gets whether or not the timer is being run constantly.
function cas.timer:isRunConstantly()
	if cas.timer._timerFuncs[self._funcLabel] then
		return cas.timer._timerFuncs[self._funcLabel].repetition == nil
	end
	
	return false
	--return cas.timer._timerFuncs[self._funcLabel] and cas.timer._timerFuncs[self._funcLabel].repetition == nil
end

-- Gets the current repetition.
function cas.timer:getRepetition()
	if not cas.timer._timerFuncs[self._funcLabel] then
		error("The timer is not running.")
	elseif cas.timer._timerFuncs[self._funcLabel].repetition == nil then
		error("The timer is being run constantly.")
	end

	return cas.timer._timerFuncs[self._funcLabel].repetition
end


-------------------
-- Static fields --
-------------------

cas.timer._timerFuncs = {} -- Table for timer entries.