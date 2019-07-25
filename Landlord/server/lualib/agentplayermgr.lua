--agent上的玩家管理器
local skynet = require "skynet"
local client = require "client"
local log=require"log"
local util = require "util"
local trace = require "trace.c"

local mods=require "role.mods"
local queue= require "skynet.queue"
local login = require "world.login"
require "role.init"
require "role.msg"

local event = require "role.event"
local gm = require "role.gm"


local _RH = require "role.handler"
local _M = {}

local locks = {}
local rolelist={}
local rolelistbyfd={}

local manager
local dbmgr
local emailsys
local emailmgr

function _M.getrole(rid)
	return rolelist[rid]
end

function _M.getrolebyfd(fd)
	return rolelistbyfd[fd]
end

function _M.addrole(role)
	rolelist[role.rid] = role
	if role.fd then
		rolelistbyfd[role.fd]=role
	end
end

function _M.delrolebyid(rid)
	local role = rolelist[rid]
	if role then
		rolelistbyfd[role.fd]=nil
	end
	rolelist[rid]=nil
end

function _M.delrolebyfd(fd)
	rolelistbyfd[fd]=nil
end

function _M.modifyrolebyfd(old, role)
	rolelistbyfd[role.fd]=role
	rolelistbyfd[old]=nil
end

function _M.isonline(rid)
	local role=rolelist[rid]
	if role then
		return true
	end
	return false
end

function _M.processeveryrole(callback)
	for rid, role in pairs(rolelist) do
		callback(role);
	end
	return true;
end

function _M.afk(role, stop)
	if role.exit then return end
	log("%d(%s) afk",role.fd,role.rname)
	-- 数据释放
	xpcall(function()
	role.exit = true
	_M.delrolebyid(role.rid)
	-- 数据回收
	mods.leave(role)
	mods.unload(role)
	--更新角色列表数据
	login.update_tplayer(role, 2)
	-- 更新其他模块数据
	end, debug.traceback)
end

function _M.addrolebyfd(role)
	rolelistbyfd[role.fd]=role
end

local function loop( ... )
	local old_day = util.get_date_from_time();
	-- local num = 0
	while true do
		for id,role in pairs(rolelist) do
			if role.map then
				mods.timeout(role)
			end
		end
		-- 零点刷新
		local day = util.get_date_from_time()
		if old_day ~= day then
			old_day = day
			for id, role in pairs(rolelist) do
				if role.map then
					mods.ondayrefresh(role)
				end
				login.reset_tplayer(role)
			end
		end
		-- end
		-- 频率1秒
		skynet.sleep(100)
	end
end

function _M.init()
	manager = skynet.uniqueservice("world/manager")
	dbmgr = skynet.uniqueservice("dbmgr")
	emailsys = skynet.uniqueservice("world/emailsys")
	emailmgr = skynet.uniqueservice("world/emailmgr")
	skynet.fork(loop)
end

function _M.on_client_msg(fd,msg,sz)
	local role = _M.getrolebyfd(fd)
	if role then
		local lock = locks[role.rid]
		local ok, ret = xpcall(lock,trace.traceback,client.dispatch,role,msg,sz)
		if ok then

		else
			log:error(ret)
		end
	end
end

function _M.on_lua_msg(session,cmd,rid,...)
	local f = _RH[cmd]
	if f then
		if rid then
			local role = _M.getrole(rid)
			if role then
				if session > 0 then
					skynet.retpack(f(role,...))
				else
					f(role,...)
				end
			else
				if cmd == "enter" then
					if session > 0 then
						skynet.retpack(f(rid,...))
					else
						f(rid,...)
					end
				else
					log("not find role [%d] command : [%s]", rid, cmd)
					if session > 0 then
						-- skynet.response()(false)
						skynet.retpack(false)
					end
				end
			end
		else
			if session > 0 then
				skynet.retpack(f(...))
			else
				f(...)
			end
		end
	else
		log("Agentmgr Unknown command : [%s]", cmd)
		if session > 0 then
			-- skynet.response()(false)
			skynet.retpack(false)
		end
	end
end

--[[   ****************  role hander *****************************  ]]

local function on_load(role)
	if not role.__load then
		role.proxy=skynet.call(dbmgr,"lua","query","DB_GAME")
		role.__load=true
		mods.load(role)
	end
end

local function entered(role)
	local msg = {
		rid = role.rid,
		rname = role.rname,
		icon = role.icon,
		gold = role.gold,
		now = skynet.time(),
		game = role.map,
		safe = role.safe,
		modify = role.base.safe.modify
	}
	client.push(role,"player_obj",msg)
end

local function on_enter(role)
	role.tmp = {}  -- 临时计算表量表
	on_load(role)
	mods.timeout(role, true)
	_M.addrole(role)
	-- client.push(role,"player_obj",{rid=role.rid,rname=role.rname,now=skynet.time()})
	mods.enter(role)
	entered(role)
	skynet.send(emailmgr, 'lua', 'getall', role.rid, role.fd)
	local conditon = {
		createtime = role.createtime,
	}
	skynet.send(emailsys, "lua", "login", role.rid, conditon)
	-- 清除临时数据
	role.tmp.old_mapid = nil
	-- 在worldchat中注册玩家，下线时需要注销

	-- 更新角色列表数据
	login.update_tplayer(role, 1)
	--
	role.logintime = skynet.time()
	return true
end

local function on_afk(role)
	if role.exit then return end
	_M.afk(role)
	log("%d(%s) exit",role.fd,role.rname)
	-- 下线时从其他服务中注销
	skynet.send(emailsys, "lua", "loginout", role.rid)
	-- 回调 manager
	skynet.call(manager, "lua", "agent_exit", role.rid, role.uid, role.fd)
end

local function lock_enter(role)
	local lock = locks[role.rid]
	if not lock then
		lock = skynet.queue()
		locks[role.rid] = lock
	end
	return lock(on_enter,role)
end

local function lock_afk(role)
	local lock = locks[role.rid]
	if lock then
		lock(on_afk,role)
	end
	locks[role.rid] = nil
end

function _RH.enter(_, args)
	local role = _M.getrole(args.rid)
	if role then return false end
	role = args
	if not skynet.call(role.gate,"lua","forward",role.fd) then
		return false
	end
	return lock_enter(role)
end

function _RH.reenter(_, args, oldfd)
	local role = _M.getrole(args.rid)
	if not role then return false end
	local lock = locks[role.rid]
	if not lock then return false end
	return lock(function(role)
		role.fd = args.fd
		role.newlogin = args.newlogin
		if not skynet.call(role.gate,"lua","forward",role.fd) then
			return false
		end
		mods.reenter(role)
		_M.modifyrolebyfd(oldfd, role)
		-- 邮件
		log:debug('role.newlogin %s', role.newlogin)
		if role.newlogin then
			skynet.send(emailmgr, 'lua', 'getall', role.rid, role.fd)
		end
		local conditon = {
			createtime = role.createtime,
		}
		skynet.send(emailsys, "lua", "login", role.rid, conditon)
		-- 更新角色列表数据
		login.update_tplayer(role, 1)
		role.logintime = skynet.time()
		entered(role)
		return true
	end,role)
end

function _RH.afk(role)
	lock_afk(role)
	return true
end

function _RH.flash(role)
	local lock = locks[role.rid]
	if lock then
		lock(function(role)
			login.update_tplayer(role, 2)
			if role.map then
				skynet.send(emailsys, "lua", "loginout", role.rid)
				skynet.call(role.map.service, "lua", "flash", role.rid)
			end
		end,role)
	else
		login.update_tplayer(role, 2)
		if role.map then
			skynet.send(emailsys, "lua", "loginout", role.rid)
			skynet.call(role.map.service, "lua", "flash", role.rid)
		end
	end
end

function _RH.get_player_info(role)
	return role
end

function _RH.exe_gm(role, cmd, args)
	return gm.exe_gm_command(role, cmd, true, args, 'gm_tools')
end

function _RH.kick(role)
	if role.exit then return end
	login.kick(role)
	skynet.call(role.gate,"lua","kick",role.fd)
end

function _RH.stop()
	log("agent release %08x",skynet.self())
	for id,role in pairs(rolelist) do
		_M.afk(role, true)
	end
	skynet.response()(true)
	skynet.exit()
end

function _RH.error_info(role,id,txt)
	client.push(role,"error_info",{id=id,txt=txt})
end

return _M
