local skynet = require "skynet"
local bq=require "quit"

skynet.start(function()
	skynet.error("shutdown start")
	skynet.call(skynet.uniqueservice "quitmgr", "lua", "stop")
	bq.base_quit()	-- never return
end)
