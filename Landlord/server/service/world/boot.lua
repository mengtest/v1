local skynet = require "skynet"
local cluster = require "skynet.cluster"
local setting = require "setting"
local cfg=require 'cfg.loader'
local baseservice=require "baseservice"

skynet.start(function()
	skynet.error("Server start")

	baseservice.start()
	
	local proto = skynet.uniqueservice "protoloader"
	skynet.call(proto, "lua", "load", {
		"*.c2s",
		"*.s2c",
	})
	cfg.loadall()
	local set=dofile("run/setting/setting.lua")
	setting.sets(set)

	skynet.uniqueservice("dblog")
	skynet.uniqueservice("world/redeem")
	skynet.uniqueservice("world/worldstatus")
	local manager = skynet.uniqueservice("world/manager")
	skynet.uniqueservice("world/offline")
	skynet.uniqueservice("world/gamemgr")
	skynet.uniqueservice("world/emailsys")
	skynet.uniqueservice("world/emailsend")
	skynet.uniqueservice("world/emailmgr")
	skynet.uniqueservice("hotfixdata");
	skynet.uniqueservice("world/globalnotice");

	local auth_setting=setting.get("auth")
	skynet.call(manager, "lua", "open",{
		address=auth_setting.listen_ip,
		port=auth_setting.listen_port,
		maxclient=auth_setting.maxclient,
		nodelay=true,
		pktspeed=25,
		timeout=12000,	--120s
	})
	
	skynet.exit()
end)
