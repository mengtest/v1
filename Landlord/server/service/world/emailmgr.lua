local skynet = require "skynet"
local service = require "service"
local client = require "client"
local handle = require "email.handle"

local cmd = {}

function cmd.getall(receiveid, receivefd)
	local emails =  handle.getall(receiveid)
	client.pushfd(receivefd, "player_email_list", {list=emails})
end

function cmd.query(receiveid)
	return handle.getall(receiveid)
end

function cmd.email_read(...)
	return handle.email_read(...)
end

function cmd.email_reward(...)
	return handle.email_reward(...)
end

function cmd.delete_id(...)
	return handle.delete_id(...)
end

function cmd.all_rewards(...)
	return handle.all_rewards(...)
end

function cmd.delete_reads(...)
	return handle.delete_reads(...)
end

service.init{
	info=nil,
	command=cmd,
	dispatch={
		lua=function(_, _, command, ...)
			local f = cmd[command]
			skynet.retpack(f(...))
		end,
	},
	init=function()
		client.init('*.c2s','*.s2c')
	end,
	release=nil,
}
