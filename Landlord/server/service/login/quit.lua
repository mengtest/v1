local skynet = require "skynet"
local bq=require "quit"

skynet.start(function()
	skynet.error("shutdown start")

	local authmgr = skynet.uniqueservice "login/authmgr"
	skynet.call(authmgr, "lua", "stop")
	
	skynet.call(skynet.uniqueservice("dbmgr"),"lua","stop")

	bq.base_quit()
end)
