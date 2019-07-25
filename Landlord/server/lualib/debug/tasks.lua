local skynet=require "skynet"
local skynetdebug=require "skynet.debug"

local function getupvalue(func,name)
	for i=1,math.maxinteger do
		local nm,value=debug.getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end

local session_id_coroutine=getupvalue(skynet.task,"session_id_coroutine")
local function task(ret)
	local traceback=debug.sys_traceback or debug.traceback
	local t = 0
	for session,co in pairs(session_id_coroutine) do
		if ret then
			ret[session] = traceback(co)
		end
		t = t + 1
	end
	return t
end

skynetdebug.reg_debugcmd("TASKS",function()
	local tsk = {}
	task(tsk)
	skynet.retpack(tsk)
end)
