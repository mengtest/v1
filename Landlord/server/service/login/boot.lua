local skynet = require "skynet"
local cluster = require "skynet.cluster"
local setting = require "setting"
local baseservice=require "baseservice"

skynet.start(function()
	skynet.error("Server start")

	baseservice.start()

	local proto = skynet.uniqueservice "protoloader"
	skynet.call(proto, "lua", "load", {
		"*.c2s",
		"*.s2c",
	})
	
	local auth_setting=setting.get("auth")
	local authmgr = skynet.uniqueservice "login/authmgr"
	skynet.call(authmgr, "lua", "start", auth_setting.auth_cnt)
	skynet.call(authmgr, "lua", "start_gate",auth_setting.listen_ip, auth_setting.listen_port)

	cluster.register("authmgr",authmgr)

	skynet.exit()
end)
