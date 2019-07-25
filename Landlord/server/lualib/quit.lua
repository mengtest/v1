local skynet = require "skynet"
local exit = require"exit"

local _M={}

function _M.base_quit()
	local kill_list={
		-- "clusterd",
		-- "gate",
		-- "protoloader",
		-- "dbinit",
		-- "debug_console",
		-- "console",
		-- "cdummy",
		-- "datacenterd",
		-- "sharedatad",
		-- "service_mgr",
		-- "hotfixdata"
	}

	require "skynet.manager"
	local c = require "skynet.core"
	local list=skynet.call(".launcher","lua","LIST")
	local kill={}
	for k,v in pairs(list) do
		local n=string.match(v,"^snlua ([^ ]+)")
		kill[n]=k
	end
	for _,v in pairs(kill_list) do
		local id=kill[v]
		if id then
			skynet.call(".launcher","lua","KILL",id)
		end
	end
	-- skynet.send(".cslave","lua","STOP")
	-- c.command("KILL",".launcher")
	-- c.command("KILL",".service")	
	-- c.command("KILL",".cslave")
	-- c.command("KILL",".logger")
	-- c.command("EXIT")

	local pidfile = skynet.getenv("daemon")
	if pidfile then
		os.remove(pidfile)
	end

	exit.exit()
end

return _M