local skynet = require "skynet"
local sharedata = require "skynet.sharedata"
local util = require "util"

local _M = require "master.handler"

local email_manager = nil


skynet.init(function()
	email_manager = skynet.uniqueservice("world/emailmgr")
end)

function _M.look(args)
	local rid = tonumber(args.rid or 0)
	local agent = _M.get_agent(rid)
	local role
	if agent then
		role = skynet.call(agent, "lua", "get_player_info", rid);
		if not role then
			return false,"not player, rid="..rid
		end
	else
		local offline_service = skynet.uniqueservice("world/offline");
		local cmd = {"baseinfo"}
		role = skynet.call(offline_service, "lua", cmd, rid, "get_player_info");
		if not role then
			return false,"not player, rid="..rid
		end
	end

	local emails = skynet.call(email_manager, "lua", "query", rid)

	if emails and next(emails) then
		return emails
	else
		return false,"not emails for rid="..rid
	end
end

function _M.send(args)
	for _, id in pairs(args.rid) do
		local rid = tonumber(id)
		if not args.theme or not args.content then
			return false, "send email not find theme or content"
		end
		local agent = _M.get_agent(rid)
		local role
		if agent then
			role = skynet.call(agent, "lua", "get_player_info", rid);
			if not role then
				return false,"not player, rid="..rid
			end
		else
			local offline_service = skynet.uniqueservice("world/offline");
			local cmd = {"baseinfo"}
			role = skynet.call(offline_service, "lua", cmd, rid, "get_player_info");
			if not role then
				return false,"not player, rid="..rid
			end
		end
	end

	local data = {
		theme = args.theme,
		content = args.content,
		gold = args.gold,
		idx = 0,
	}
	local email_sys_mgr = skynet.uniqueservice("world/emailsys")
	for _, id in pairs(args.rid) do
		local rid = tonumber(id)
		data.receiveid = rid
		skynet.send(email_sys_mgr, "lua", "send", rid, data)
	end

	return true
end

function _M.sysmail(args)
	local email_sys_mgr = skynet.uniqueservice("world/emailsys")
	if args.createtime then
		args.createtime = tonumber(args.createtime)
	end
	if args.expiretime then
		args.expiretime = tonumber(args.expiretime)
		if args.expiretime < 5 then
			args.expiretime = 5
		end
	end	
	local data = {
		theme = args.theme,
		content = args.content,
		gold = args.gold or 0,
		createtime = args.createtime,
		expiretime = args.expiretime,
		type = args.type or 1,
		condition = args.condition or "",
	}
	skynet.send(email_sys_mgr, "lua", "mail_insert", data)
	return true
end

return _M