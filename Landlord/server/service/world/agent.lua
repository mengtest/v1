local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"
local agentplayermgr = require "agentplayermgr"

-- local _M = require "role.handler"
local _M = {}
skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (...) return ... end,
	pack = function() error("NOT RET") end,
}

service.init{
	command=_M,
	--info=function() return role end,
	dispatch={
		lua=function (session, source, cmd, rid, ...)
			agentplayermgr.on_lua_msg(session,cmd, rid,...)
		end,
		client=function(fd,address,msg,sz)
			agentplayermgr.on_client_msg(fd,msg,sz)
		end,
	},
	init=function()
		client.init("*.c2s","*.s2c")
		agentplayermgr.init()
	end,
	release=nil,
}

