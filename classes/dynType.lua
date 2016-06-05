-- Initializing dynamic object type class.
cas.dynType = cas.class()

--------------------
-- Static methods --
--------------------

-- Turns cs2d item type id into a cas.dynType object.
function cas.dynType.getInstance(objectTypeID)
	if type(objectTypeID) ~= "number" then
		error("Passed \"objectTypeID\" parameter is not valid. Number expected, ".. type(objectTypeID) .." passed.")
	end
	
	for key, value in pairs(cas.dynType) do
		if getmetatable(value) == cas.dynType then
			if value._typeId == objectTypeID then
				return value
			end
		end
	end
	
	error("Passed \"objectTypeID\" value is not valid.")
end

----------------------
-- Instance methods --
----------------------

-- Constructor.
function cas.dynType:constructor(objectTypeID)
	if type(objectTypeID) ~= "number" then
		error("Passed \"objectTypeID\" parameter is not valid. Number expected, ".. type(objectTypeID) .." passed.")
	end
	
	if not cas.dynType._allowInstantiation then
		error("Instantiation of this class is not allowed.")
	end
	
	self._objectTypeID = objectTypeID
end

--== Setters/control ==--

function cas.dynType:spawn(...)
	if self._objectTypeID >= 1 and self._objectTypeID <= 23 then
		--local 
	elseif self._objectTypeID == 30 then
	
	elseif
	
	end
end

-------------------
-- Static fields --
-------------------

cas.dynType._allowInstantiation = true
for key, value in pairs(cas._config.cs2dDynamicObjectTypes) do
	cas.dynType[key] = cas.dynType.new(value)
end
cas.dynType._allowInstantiation = false