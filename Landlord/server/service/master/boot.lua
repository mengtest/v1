local skynet = require "skynet"
local setting = require "setting"
local baseservice=require "baseservice"

local function boot()
	skynet.error("Server start")
	baseservice.start()
	local auth_setting=setting.get("auth")
	local wgate=skynet.newservice("wgate","master.interface")
	skynet.call(wgate,"lua","start",auth_setting.listen_ip,auth_setting.listen_port,auth_setting.auth_cnt)
end

skynet.start(function()
	local ok,err=xpcall(boot,debug.traceback)
	if not ok then
		skynet.error(err)
	end
	skynet.exit()
end)
