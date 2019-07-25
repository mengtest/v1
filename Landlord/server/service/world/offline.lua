local skynet = require "skynet"
local service = require "service"

local offline = require "world.offline"

service.init{
	command=offline.command,
	dispatch=offline.dispatch,
	init=offline.init,
	release=offline.release,
}
