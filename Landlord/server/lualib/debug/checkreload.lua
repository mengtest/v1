local reload=require "debug.reload"
local skynet=require "skynet"
local skynetdebug=require "skynet.debug"
local function checkreload(mod)
	if package.loaded[mod] then
		reload(mod)
		return true
	else
		return false
	end
end

skynetdebug.reg_debugcmd("CHECKRELOAD",function(...)
	skynet.retpack(checkreload(...))
end)
