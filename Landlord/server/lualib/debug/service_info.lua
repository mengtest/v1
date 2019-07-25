local skynet=require "skynet"
local skynetdebug=require "skynet.debug"
local mem_detail=require "debug.mem_detail"

skynetdebug.reg_debugcmd("SERVICE_INFO",function(...)
	local service=package.loaded["service"]
	if service then
		skynet.retpack(mem_detail(service.info(),...))
	else
		skynet.retpack(mem_detail({error="service module not open"}))
	end
end)