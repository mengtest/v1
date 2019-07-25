local skynet = require "skynet"
local client = require "client"
local util = require "util"
local log = require "log"

local args = {...}

local _M = {}
 
function _M.system_email(args)
	log:debug('system_email')
	local theme = args[2]
	local content = args[3]
	local gold = args[4]
	local type = args[5]
	local sys = skynet.uniqueservice("world/emailsys")
	local msg = {
		theme = theme,
		content = content,
		gold = gold,
		type = type,
		condition = ''
	}
	skynet.call(sys, 'lua', 'mail_insert', msg)
end

skynet.start(function()
	local cmd = args[1]
	local f = _M[cmd]
	if f then
		f(args)
	end
	skynet.exit()
end)