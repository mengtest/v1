local skynet = require "skynet"
local client = require "client"
local cluster= require "skynet.cluster"
local service = require "service"
local log = require "log"
local login = require "world.login"
local util = require "util"
local authmethod = require "login.authmethod"
local agentpool = require"agent_pool"
local wordsfilter = require "chat.wordsfilter"
local coroutine = require "skynet.coroutine"
local setting = require "setting"
local trace = require "trace.c"
--local traceback = debug.traceback;
local traceback = trace.traceback
local errcode = require "enum.errcode"
local dblog=require "gamelog"

local _T = require "master.handler"
local _H=client.handler()
local _M = {}
local _S = {}

local max_count = 2500
local connect_count = 0
local online_count = 0
local crole_total = 0
local auth_cnt_total = 0

local onlines = {}		-- 在线
local offlines = {}		-- 占时离线，方便重连
local socket = {}
local authlist={}
local authindex=1
local afklist = {} 	--退出中的角色

--[[平台服务器状态
1 爆满
2 繁忙
3 流畅
4 维护
]]
local platfrom_state = 255

local dbmgr
local world_service
local team_service
local svr_id
skynet.init(function()
	dbmgr=skynet.uniqueservice("dbmgr")
	math.randomseed(skynet.time())
	wordsfilter.loadFilter()
	svr_id=assert(tonumber(skynet.getenv("svr_id")))
end)

local function new_agent()
	-- local s=table.remove(pool)
	-- if s then return s end
	-- return skynet.newservice("world/agent",skynet.self())
	return agentpool.pop()
end

local function free_agent(agent)
	-- kill agent, todo: put it into a pool maybe better
	--table.insert(pool,agent)
	--skynet.kill(agent)
	agentpool.push(agent)
end

local function on_wait(rid)
	local data = afklist[rid];
	if( not data) then
		return false;
	end
	local co = coroutine.running();
	table.insert(data.co_list, co);
	log:info("manager : on_wait : player[%s] on afk wait, co[%s]", rid, tostring(co));
	skynet.wait(co);
	log:info("manager : on_wait : player[%s] on afk wakeup, co[%s]", rid, tostring(co));
	return true;
end

local function add_to_afklist(rid)
	local info = afklist[rid];
	if( info == nil) then
		info = {
			co_list = {},
			time = skynet.time(),
		};
		afklist[rid] = info;
	end
end

local function del_from_afklist(rid)
	local data = afklist[rid];
	if( not data) then
		return ;
	end
	local co_list = data.co_list;
	for _, co in pairs(co_list) do
		skynet.wakeup(co);
		--coroutine.resume(co);
	end
	afklist[rid] = nil;
end

local function clear_timeout_afklist()
	local now = skynet.time();
	local removelist = {};
	for rid, data in pairs(afklist) do
		if( now - data.time >= 5) then
			table.insert(removelist, rid); 	--不管最后是多久开始等待，只看第一次等待时间是否超时
		end
	end
	for _, rid in pairs(removelist) do
		log:warn("manager : clear_timeout_afklist : player[%s] afk wait time out, force clear", rid);
		del_from_afklist(rid);
	end
end

local function kick_repeat(self,rid)
	local role = onlines[rid]
	local off = offlines[rid]
	if role and not off then
		repeat
			if role.agent > 0 then
				xpcall(skynet.send,debug.traceback,role.agent,"lua","error_info", rid, 13)
				log:debug("wait old %d afk,old agent=%08x,fd=%d, new fd[%d]",rid,role.agent,role.fd,self.fd)
				_M.kickout(role.gate, role.fd)
			else
				log:debug("wait offline rid=%d afk",rid)
			end
			skynet.sleep(100)
			off = offlines[rid]
			role = onlines[rid]
		until (off ~= nil or role == nil)
	end
	return true
end

local function assign(self,role)
	local rid = role.rid
	local uid = self.uid
	-- 角色重复登录
	on_wait(rid)
	if not kick_repeat(self,rid) then
		return nil
	end
	local op = "enter"
	-- 占离状态
	if offlines[rid] then
		op = "reenter"
		role = onlines[rid]
	else
		-- 新分配
		online_count = online_count + 1
		local agent=new_agent()
		role.agent=agent
	end
	local oldfd = role.fd
	role.gate=self.gate
	role.addr=self.addr
	role.fd=self.fd
	role.uid=self.uid
	role.sid=self.sid
	role.auth=self.auth
	role.newlogin=self.newlogin
	local authinfo=self.authinfo
	role.channel=authinfo and authinfo.channel or 0
	role.dev_id=authinfo and authinfo.dev_id or ''
	role.dev_type=authinfo and authinfo.dev_type or 0
	if self.addr then
		role.ip=string.sub(self.addr,1,string.find(self.addr,":")-1)
	end
	-- socket 保存 rid
	self.rid = rid
	-- onlines 保存 role
	onlines[rid] = role
	offlines[rid] = nil
	log:info("Assign %s [agent:%08x] for fd:%d(rname:%s,rid:%d) online(%d)",op,role.agent,role.fd,role.rname,role.rid,online_count)
	local ok,ret = xpcall(skynet.call,debug.traceback,role.agent, "lua", op, rid, role, oldfd)
	if ok and ret then
		return role.agent
	else
		return nil
	end
end

local function random_auth()
	local index=authindex
	authindex=authindex+1
	if authindex>#authlist then
		authindex=1
	end
	return authlist[index]
end

function _M.init( )
	agentpool.init(5,100,"world/agent",skynet.self())
end

function _M.open(gateargs)
	local gate = skynet.newservice("gate")
	gateargs.watchdog=skynet.self()
	skynet.call(gate, "lua", "open",gateargs)
	_M.init()
	skynet.call(".launcher", "lua", "GC")
	log("version %s",setting.get("version"))
	return true
end

function _M.close()
	for rid,role in pairs(onlines) do
		if role.agent > 0 then
			skynet.call(role.agent, "lua", "kick", rid)
		end
	end
end

function _M.kick(rid)
	--on_wait(rid);
	local role = onlines[rid]
	if role and role.agent > 0 then
		skynet.call(role.agent, "lua", "kick", rid)
	end
end

function _M.get_agent(rid)
	--on_wait(rid);
	local role = onlines[rid]
	if role and role.agent > 0 then
		return role.agent
	end
	return nil
end

function _M.agent_exit(rid, uid, fd)
	--on_wait(rid);--这里不能等待
	local role = onlines[rid]
	if role and role.agent > 0 then
		online_count = online_count - 1
		log:info("Free [agent:%08x] rid:%d fd:%d online(%d)",role.agent, rid, fd or -1, online_count)
		free_agent(role.agent)
	end
	offlines[rid] = nil
	onlines[rid] = nil

	del_from_afklist(rid);

	local s=socket[fd]
	if s and s.gate then
		skynet.call(s.gate,"lua","kick",fd)
	end
end

function _M.transfer(rid, args)
	on_wait(rid)
	local role = onlines[rid]
	-- 在线
	if role and role.agent > 0 then
		skynet.send(role.agent,'lua',"transfer",rid,args)
		return
	end
	-- 不在线
	add_to_afklist(rid)
	local offsvr = skynet.uniqueservice("world/offline")
	skynet.call(offsvr,'lua',"baseinfo",rid,"transfer",args)
	del_from_afklist(rid)
end

function _M.player_status(rid, dontwait)
	if dontwait ~= true then
		on_wait(rid);
	end
	local role = onlines[rid]
	if role and role.agent > 0 then
		return true, role.agent
	end
	return false, nil
end

function _M.online_players_status(list)
	local tmp = nil;
	local ret = {};
	for _, rid in pairs(list) do
		tmp, ret[rid] = _M.player_status(rid, true);
	end
	return ret;
end

function _M.broadcast_all_online_players(args)
	for rid,role in pairs(onlines) do
		if role.agent > 0 then
			skynet.send(role.agent, "lua", args.func_name, rid, args)
		end
	end
end

function _M.broadcast_agent(name,...)
	agentpool.broadcast(name,...)
end

function _M.get_role_list(maxnum)
	local ret = {}
	local tmp = {}
	for rid, role in pairs(onlines) do
		if role.agent > 0 then
			table.insert(tmp,rid)
		end
	end
	local num = 0
	local count = #tmp
	while true do
		if count < 1 then
			break
		end
		local i = math.random(1,count)
		local rid = tmp[i]
		local agent = onlines[rid].agent
		local role = skynet.call(agent, "lua", "get_player_info", rid);
		if role then
			local d = {
				rid = role.rid,
				rname = role.rname,
				gold = role.gold,
				safe = role.safe,
				online = 1
			}
			if role.map then
				d.gameid = role.map.gameid
			end
			table.insert(ret,d)
			num = num + 1
		end
		if num >= maxnum then
			break
		end
		table.remove(tmp,i)
		count = count - 1
	end
	return ret
end

function _M.platfrom_server_state(state)
	--platfrom_state = state
	platfrom_state = 3
end

function _M.info_stat()
	return connect_count,online_count,crole_total,auth_cnt_total
end

function _M.kickout(gate,fd)
	client.pushfd(fd,"kickout",{})
	skynet.call(gate,"lua","kick",fd)
end

function _S.data(gate,fd,msg,sz)
	local s=socket[fd]
	if s.auth_result==true then
		client.dispatch(s,msg,sz)
	elseif s.auth_result==nil then
		s.auth_result=false
		local ok,err=pcall(client.dispatch_special,s,"game_auth",msg)
		if ok and s.auth_result then
			return
		elseif not ok then
			log("gate_auth error %s",tostring(err))
		end
		_M.kickout(s.gate,fd)
	else
		--第一次game_auth没有成功之前不能发送其他消息
		log("plz wait game_auth 1th")
		_M.kickout(s.gate,fd)
	end
end

function _S.open(gate,fd,addr)
	socket[fd]={
		gate=gate
		,addr=addr
		,fd=fd
	}
	connect_count = connect_count + 1
	skynet.call(gate,"lua","accept",fd)
	log("accept %d(%s)",fd,addr)
end

function _S.close(gate,fd)
	log("close %d",fd)
	local s=socket[fd]
	socket[fd]=nil
	if s then
		connect_count = connect_count - 1
		if s.rid then
			local role = onlines[s.rid]
			if role and role.agent > 0 then
				offlines[s.rid] = {
					time = skynet.now(),
				}
				log:warn("暂离 %d", s.rid)
				skynet.call(role.agent,"lua","flash",s.rid)
				-- add_to_afklist(s.rid);
				-- skynet.call(role.agent,"lua","afk",s.rid)
			end
		end
	end
end

function _S.error(gate,fd,msg)
	log("error %d",fd)
	_S.close(gate,fd)
end

function _S.warning(gate,fd, size)

end

local function push_rolelist(self)
	client.push(self,"role_list",{roles=self.roles})
end

function _H:ping(msg)
	return {}
end

function _H:game_auth(msg)
	if online_count > max_count then
		return {e = errcode.server_full}
	end
	local r=false
	if self.authinfo then
		r=authmethod.check(self.authinfo,msg.token,msg.ti)
	end
	if not r then
		log("------------".."login_"..msg.auth)
		local authinfo,err=cluster.call("login_"..msg.auth,"authmgr","check_token",msg.uid,msg.token,msg.ti)
		if authinfo then
			-- 维护状态
			if platfrom_state > 3 then
				if not authinfo.iswhite then
					log("game_auth auth failure,fd=%d uid=%s state=%d",self.fd,msg.uid,platfrom_state)
					return {e = errcode.server_not_open}
				end
			end
			self.newlogin=err
			self.authinfo=authinfo
			self.uid=authinfo.uid
			self.auth=msg.auth
			self.sid=svr_id
			log:info("game_auth success,fd=%d uid=%s,token=%s(%s)",self.fd,msg.uid,msg.token,authinfo.token)
		else
			log("game_auth auth failure,fd=%d uid=%s,token=%s %s",self.fd,msg.uid,msg.token,err)
			return {e = errcode.server_auth}
		end
	end
	auth_cnt_total = auth_cnt_total + 1
	self.auth_result=true
	self.proxy=skynet.call(dbmgr,"lua","query","DB_GAME")
	self.roles=login.select_rolelist(self.proxy,self)
	-- push_rolelist(self)
	return {e=0, roles=self.roles}
end

function _H:create_role(msg)
	local now = skynet.now()
	if self.create_time and now - self.create_time < 200 then
		return {e = errcode.create_role_timeout}
	end
	if util.stringlen(msg.rname) > 10 then
		log:error("%s create errname[%s], len",self.uid, msg.rname)
		return {e = errcode.create_role_name}
	end
	self.create_time = now
	msg.uid=self.uid
	msg.sid=self.sid
	if not wordsfilter.WordsFilter_CheckName(msg.rname) then
		log:error("%s create errname[%s]",self.uid, msg.rname)
		return {e = errcode.create_role_name}
	end
	local ret = login.create_role(self.proxy,msg)
	if ret ~= 0 then
		log:error("%s create err[%d]",self.uid, ret)
		if ret == 1 then
			return {e = errcode.create_role_exist}
		elseif ret == 2 then
			return {e = errcode.create_role_full}
		else
			return {e = errcode.create_role_err}
		end
	end
	crole_total=crole_total+1
	self.roles=login.select_rolelist(self.proxy,self)
	-- push_rolelist(self)
	for _,role in ipairs(self.roles) do
		if role.rname==msg.rname then
			local ip=self.addr and string.sub(self.addr,1,string.find(self.addr,":")-1)
			local authinfo=self.authinfo
			local channel=authinfo and authinfo.channel or 0
			local dev_type=authinfo and authinfo.dev_type or 0
			break
		end
	end
	return {e=0, roles=self.roles}
end

function _H:login(msg)
	local rid=tonumber(msg.rid)
	local role
	for _,v in ipairs(self.roles) do
		if v.rid == rid then
			role = v
			break
		end
	end
	if not role then
		return {e = errcode.login_not_find}
	end
	local now = skynet.now()
	if self.login_time and now - self.login_time < 500 then
		return {e = errcode.login_timeout}
	end
	self.login_time = now
	role.mini_client = msg.mini
	local agent=assign(self, role)
	if agent then
		log:info("login ok, fd:%d", self.fd)
		self.roles[1] = role
		return {e=0,m="OK"}
	else
		log("login failure, fd:%d", self.fd)
		_M.agent_exit(rid, self.fd)
		return {e = errcode.login_err}
	end
end

local function release()
	agentpool.stop()
	local gamemgr = skynet.uniqueservice("world/gamemgr");
	if gamemgr then
		skynet.call(gamemgr, "lua", "stop");
	end
	local log = skynet.uniqueservice("dblog");
	if log then
		skynet.call(log, "lua", "stop");
	end
end

-- 1 秒频率
local function one_seconds()
	clear_timeout_afklist(); 	--定期检测是否有卡死协程，如果之前协程被卡死，会在5秒左右不能正常登陆，直到运行这里的超时处理
	local now = skynet.now()
	for rid,v in pairs(offlines) do
		-- 1 分钟离线超时
		if now - v.time > 5*60*100 then
			log:debug("离线超时 %d",rid)
			local role = onlines[rid]
			if role then
				add_to_afklist(role.rid);
				skynet.call(role.agent,"lua","afk",role.rid)
			end
		end
	end
end

-- 5 秒频率
local function five_seconds()

end

-- 1 分钟频率
local function one_minutes()
	dblog.online(online_count)
end

-- 5 分钟频率
local function five_minutes()

end

local function loop()
	local second5 = 0 -- 5 秒频率
	local one = 0 	-- 1 分钟频率
	local five = 0 	-- 5 分钟频率
	local day = 3600*24
	--每天凌晨4点手动GC一次
	local gc_num = 0
	local begin = skynet.time()
	local date = os.date("*t", begin)
	date.hour = 4
	date.min = 0
	date.sec = 0
	local four = os.time(date)
	-- 凌晨0-4点 启动服务器
	if begin < four then
		gc_num = four - begin
	else
		gc_num = four + day - begin
	end
	while true do
		second5 = second5 + 1
		one = one + 1
		five = five + 1
		if second5 == 5 then
			second5 = 0
			five_seconds()
		end
		if one == 60 then
			one = 0
			one_minutes()
		end
		if five == 300 then
			five = 0
			five_minutes()
		end
		gc_num = gc_num - 1
		if gc_num <= 0 then
			gc_num = day
			skynet.call(".launcher", "lua", "GC")
		end
		local ok, result = xpcall(one_seconds, traceback);
		if( not ok) then
			log:warn("manager : loop : ok[%s], result[%s]", tostring(ok), tostring(result));
		end
		-- 频率1秒
		skynet.sleep(100)
	end
end

return {
	command=_M,
	master=_T,
	dispatch={
		lua=function (session,source, cmd, scmd,...)
			if cmd=="socket" then
				_S[scmd](source,...)
			else
				local f = _M[cmd]
				if f then
					if session > 0 then
						skynet.retpack(f(scmd,...))
					else
						f(scmd,...)
					end
				else
					log("Unknown command : [%s]", cmd)
					if session > 0 then
						skynet.response()(false)
					end
				end
			end
		end,
	},
	init=function()
		client.init('*.c2s','*.s2c');
		local master = (require"master")
		master.reg("role");			-- 注册master模块，role关键字
		master.reg("email");
		master.reg("system");
		skynet.fork(loop)
	end,
	release=release,
}
