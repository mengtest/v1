local skynet=require "skynet"
local log = require "log"
local debug = require "debug"

local global_value_check_mt = {};

--在服务启动后，原则上不允许新建全局变量，如果这里有日志输出，请把全局变量修改为局部变量，不然热更效率极低
local function on_global_value_check(t, k, v)
	log:info("notice_print : on_global_value_check : new global value, t[%s],k[%s],v[%s],path[%s]", t, k, v, debug.traceback());
end
setmetatable(_G, {
	__newindex = function(t, k, v)
		on_global_value_check(t, k, v)
		rawset(t,k,v);
	end,
})
