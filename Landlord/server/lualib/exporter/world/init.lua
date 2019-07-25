local public=require "exporter.public"
local mysql=require "exporter.mysql"
local skynet=require "skynet"
local skynetservice=require "skynet.service"

local manager
local logmgr
return function(D)
	if not manager then
		manager=skynet.uniqueservice("world/manager")
	end
	if not logmgr then
		logmgr=skynet.uniqueservice("dblog")
	end
	local online,role_agent,crole_total,auth_cnt_total=skynet.call(manager,"lua","info_stat")
	local log_cnt = skynet.call(logmgr, "lua", "info_stat")

	public(D)
	mysql(D)

	D.z_w_online_num={"gauge",online}
	D.z_w_agent_num={"gauge",role_agent}
	D.z_w_logcnt_total={"counter",log_cnt}
	D.z_w_newrole_total={"counter",crole_total}
	D.z_w_authok_total={"counter",auth_cnt_total}
end
