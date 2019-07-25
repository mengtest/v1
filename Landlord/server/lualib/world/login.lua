local skynet = require "skynet"
local service = require "service"
local mysqlaux = require "skynet.mysqlaux.c"
local cluster= require "cluster"
local uniq = require "uniq.c"
local util= require "util"
local log=require "log"
local dblog=require "gamelog"

local sharedata = require "skynet.sharedata"

local format=string.format
local function query(proxy,...)
	local d
	if select("#",...)==1 then
		d= skynet.call(proxy,'lua','query',...)
	else
		d= skynet.call(proxy,'lua','query',format(...))
	end
	if d.errno then
		error(format("%s[%s]",d.err,table.concat({...})))
	end
	return d
end

local function select_rolelist(proxy,self)
	local d=query(proxy,"select rid,rname,icon,gold,safe,last,`create`,`logout` from t_player where uid='%s' and sid='%s'",self.uid,self.sid)
	local ret={}
	for _,r in ipairs(d) do
		local rid,rname,icon,gold,safe,last,createtime,logout=r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8]
		table.insert(ret,{rid=rid,rname=rname,icon=icon,gold=gold,safe=safe,last=last,
			createtime=createtime,logout=logout})
	end
	return ret
end

local function create_role(proxy,args)
	local global_config = sharedata.query("global_config")
	local gold = global_config['gold'].data
	local uid = tonumber(args.uid)
	local head = uid<<24|(args.sid&0xFFFFF)<<4
	log("head %d,uid=%d,sid=%d,gold=%d", head, uid, args.sid, gold)
	local sql = format("call sp_create_player('%d','%s',%d,'%s',%d,%d,%d);",head,args.uid,args.sid,args.rname,args.icon,gold,skynet.time())
	local ret = query(proxy, sql)
	local err,rid = table.unpack(ret[1])
	if err == 0 then
		args.rid = rid
		dblog.createrole( args )
	end
	return err,gold
end

local function aotu_create(proxy, self)
	local ret = select_rolelist(proxy, self)
	if #ret == 0 then
		local num = 0
		while true and num < 10 do
			num = num + 1
			local name = "玩家"..math.random(100000001,999999999)
			local args = {
				uid = self.uid,
				sid = self.sid,
				icon = 1,
				rname = name,
			}
			local err,gold = create_role(proxy, args)
			if err == 0 then
				table.insert(ret,{
					rid=args.rid,
					rname=name,
					icon=1,
					gold=gold,
					safe=0,
					last=0,
					createtime=0,
					logout=0
				})
				break
			end
		end
	end
	return ret
end

local _M={}

function _M.get_name(proxy,rid)
	local d=query(proxy,"select rname from t_player where rid=%d",rid)
	if d[1] ~= nil then
		return d[1][1]
	end
	return nil
end

function _M.select_role(proxy, rid)
	local d=query(proxy,"select rid,rname,gold,safe from t_player where rid=%d",rid)
	if d[1] ~= nil then
		local r = d[1]
		return {rid=r[1],rname=r[2],gold=r[3],safe=r[4]}
	end
	return nil
end

function _M.select_rolelist(proxy,role)
	-- return select_rolelist(proxy,self)
	return aotu_create(proxy,role)
end

function _M.create_role(proxy,args)
	args.icon = 1
	return create_role(proxy,args)
end

local function update_login_tplayer(role, up_type)
	local info = {rname=role.rname, rid=role.rid, uid=role.uid, sid=role.sid}
	cluster.send("login_"..role.auth, "authmgr", "update_tplayer", up_type, info)
end

local function update_game_tplayer(role, up_type)
	local sql
	if up_type == 1 then
		-- login
		role.last_uuid = uniq.id(1)
		sql = format("update t_player set last=%d where rid=%s", skynet.time(), role.rid)
		dblog.login(role)
	else
		-- logout
		sql = format("update t_player set rname='%s',icon=%d,gold=%d,safe=%d,logout=%d where rid=%s",
			role.rname,role.icon,role.gold,role.safe,skynet.time(),role.rid)
		dblog.logout(role)
	end
	query(role.proxy,sql)
end

function _M.update_tplayer(role, up_type)
	update_login_tplayer(role, up_type)
	update_game_tplayer(role, up_type)
end

function _M.update_gold(role, gold)
	local sql = format("update t_player set gold=%d where rid='%s'", gold, role.rid)
	query(role.proxy,sql)
end

function _M.update_safe(role, safe, gold)
	local sql
	if gold then
		sql = format("update t_player set safe=%d,gold=%d where rid='%s'", safe, gold, role.rid)
	else
		sql = format("update t_player set safe=%d where rid='%s'", safe, role.rid)
	end
	query(role.proxy,sql)
end

function _M.reset_tplayer(role)
	-- 下线日志
	dblog.logout(role)
	-- 上线日志
	role.last_uuid = uniq.id(1)
	dblog.login(role)
end

function _M.kick(role)
	cluster.call("login_"..role.auth, "authmgr", "kick", role.uid)
end

return _M
