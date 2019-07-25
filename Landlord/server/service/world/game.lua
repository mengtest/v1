local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"
local util = require "util"
local _H = require "handler"

local name = (...)
local _M = require("game."..name)

local co_run

local function loop( )
	while co_run do
		-- 每100毫秒调用一次
		local ok,err = xpcall(_M.timeout, debug.traceback)
		if not ok then
			log(err)
		end
		skynet.sleep(10)
	end
	skynet.exit()
end

local function init()
	client.init('*.c2s','*.s2c');
	math.randomseed(skynet.time())
	_M.init()
	co_run = true
	skynet.fork(loop)
end

local function release()
	if _M.stop then
		_M.stop()
	end
	co_run = false
end

service.init {
	command=_H,
	info=nil,
	init=init,
	release=release,
}
