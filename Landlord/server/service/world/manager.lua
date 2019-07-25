local skynet = require "skynet"
local service = require "service"

local manager = require "world.manager"

service.init{
	quit=true,
	command=manager.command,
	master=manager.master;
	dispatch=manager.dispatch,
	init=manager.init,
	release=manager.release,
}
