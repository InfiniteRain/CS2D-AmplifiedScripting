local test1 = class()

test1.constructor = function()
	print('test1')
	local foo = Test2.new()
end

return test1