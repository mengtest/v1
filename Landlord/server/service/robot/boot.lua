local skynet = require "skynet"
local httpc = require "http.httpc"

local skynet = require "skynet"
local setting = require 'setting'
local cfg=require 'cfg.loader'

skynet.start(function()
	skynet.error("Server start")
	local console = skynet.newservice("console")
	local proto = skynet.uniqueservice "protoloader"
	skynet.call(proto, "lua", "load", {
		"*.s2c",
		"*.c2s"
	})
	cfg.loadall()
	local start = skynet.getenv("svr_start")
	local num = skynet.getenv("svr_num")
	local mod = skynet.getenv("svr_mod")

	local name=skynet.getenv("svr_id")
	local cfg=dofile(string.format("run/setting/robot_%d.lua",name))
	setting.init(cfg)

	local login = setting.get("login")
	local loginip,loginport = login.ip, login.port

	skynet.error("Robot start =",start," num =",num)
	for i=start,start+num-1 do
		skynet.newservice('robot/agent',loginip,loginport,math.floor(i),mod)
	end
	skynet.exit()
end)
