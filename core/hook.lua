cas.hook = {}
cas.hook.__index = cas.hook

function cas.hook:new(event, priority)
	local self = setmetatable({}, cas.hook)
	return self
end