local skynet = require "skynet"
local client = require "client"
local sharedata = require "skynet.sharedata"
local login = require "world.login"
local util = require "util"

local _M = require "master.handler"

local format=string.format

skynet.init(function()

end)

function _M.gm(args)
	local rid = tonumber(args.rid or 0)
	local agent = _M.get_agent(rid)
	if agent and args.cmd then
		local t = load("return {"..args.args.."}")()
		local ret = skynet.call(agent, "lua", "exe_gm", rid, args.cmd, t)
		local msg = "args error"
		if ret then
			msg = nil
		end
		return ret,msg
	end
	return false,"not online player, rid="..rid
end

function _M.list(args)
	local function get_role(rid)
		local ret = nil
		local agent = _M.get_agent(rid)
		if agent then
			local role = skynet.call(agent, "lua", "get_player_info", rid);
			if role then
				ret = {
					rid = role.rid,
					rname = role.rname,
					gold = role.gold,
					safe = role.safe,
					online = 1
				}
				if role.map then
					ret.gameid = role.map.gameid
				end
			end
		else
			local db = skynet.uniqueservice("dbmgr")
			local proxy=skynet.call(db,"lua","query","DB_GAME")
			local role = login.select_role(proxy,rid)
			if role then
				ret = {
					rid = role.rid,
					rname = role.rname,
					gold = role.gold,
					safe = role.safe,
					online = 0
				}
			end
		end
		return ret
	end
	if args.rid then
		local ret = {}
		local rid = tonumber(args.rid)
		local d = get_role(rid)
		if d then
			table.insert(ret,d)
		end
		return ret
	elseif args.rname then
		local ret = {}
		local db = skynet.uniqueservice("dbmgr")
		local proxy=skynet.call(db,"lua","query","DB_GAME")
		local sql = format("select rid from t_player where rname like '%%%s%%'", args.rname)
		local d=skynet.call(proxy,'lua','query',sql);
		local rids={}
		for _,r in ipairs(d) do
			table.insert(rids, r[1])
		end
		for _,rid in ipairs(rids) do
			local d = get_role(rid)
			if d then
				table.insert(ret,d)
			end
		end
		return ret
	else
		return _M.get_role_list(10)
	end
end


function _M.modify(args)
	local rid = args.rid
	local agent = _M.get_agent(args.rid)
	local ret = {rid=rid}
	if agent then
		local role = skynet.call(agent, "lua", "exe_gm", rid, 'set_money', args);
		if not role then
			return false,"not player, rid="..rid
		end
		ret.gold = role.gold;
		ret.safe = role.safe;
	else
		local offline_service = skynet.uniqueservice("world/offline");
		local cmd = {"baseinfo"}
		local role = skynet.call(offline_service, "lua", cmd, rid, "set_money");
		if not role then
			return false,"not player, rid="..rid
		end
		ret.gold = role.gold;
		ret.safe = role.safe;
	end
	return ret
end


return _M