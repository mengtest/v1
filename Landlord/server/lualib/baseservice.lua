local skynet = require "skynet"

local setting=require "setting"
local settingloader = require "setting.loader"

local _M={}

function _M.start()
	settingloader.init_setting()
	if not skynet.getenv("daemon") then skynet.uniqueservice("console") end
	local port=setting.get("debugport")
	local file=assert(io.open(skynet.getenv("debugportfile"),"w"))
	file:write(port)
	file:close()
	skynet.newservice("debug_console",port)
	skynet.newservice("exporter")
end

return _M
