local skynet=require "skynet"
local skynetdebug=require "skynet.debug"
local mem_detail=require "debug.mem_detail"

skynetdebug.reg_debugcmd("REGISTRY",function(...)
	skynet.retpack(mem_detail(debug.getregistry(),...))
end)