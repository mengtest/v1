local public=require "exporter.public"
local mysql=require "exporter.mysql"
local skynet=require "skynet"

local authmgr
return function(D)
	if not authmgr then
		authmgr=skynet.uniqueservice("login/authmgr")
	end
	local pcltime,pclcnt,authokcnt=skynet.call(authmgr,"lua","authinfo")

	public(D)
	mysql(D)

	D.z_l_pcltime_total={"counter",pcltime}
	D.z_l_pclcnt_total={"counter",pclcnt}
	D.z_l_authok_total={"counter",authokcnt}
end
