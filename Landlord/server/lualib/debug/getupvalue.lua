local assert=assert
local getupvalue=debug.getupvalue
return function(func,name)
	for i=1,math.maxinteger do
		local nm,value=getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end
