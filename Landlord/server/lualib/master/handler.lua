local skynet=require "skynet"

-- GM服务接受消息句柄
local master = {

}

function master.get_agent(rid)
	local s = skynet.uniqueservice("world/manager")
	return skynet.call(s,"lua","get_agent",rid)
end

function master.get_role_list(num)
	local s = skynet.uniqueservice("world/manager")
	return skynet.call(s,"lua","get_role_list",num)
end

return master