local skynet = require "skynet"
local service = require "service"
local socket = require "skynet.socket"
local log = require "log"
local authmethod = require "login.authmethod"

local token={}
local online={}
local authlist={}
local gatelist={}
local _M={}

local function clear_timeout()
	local now = skynet.now()
	for k,v in pairs(token) do
		if v and v.ti+30000<=now then -- timeout 300s
			log("del token %s",v.uid)
			token[v.uid]=nil
		end
	end
end

function _M.start(cnt)
	for i=1,math.max(cnt,1) do
		table.insert(authlist,skynet.newservice("login/auth",skynet.self()))
	end
end

function _M.stop_auth()
	for _,auth in pairs(authlist) do
		skynet.call(auth, "lua", "stop")
	end
	authlist={}
end

function _M.start_gate(ip,port)
	assert(#authlist>0,"need start first")
	local gate = skynet.newservice("login/gate")
	skynet.call(gate, "lua", "open", ip, port, authlist)
	table.insert(gatelist,gate)
	return true
end

function _M.stop_gate()
	for _,gate in pairs(gatelist) do
		skynet.call(gate, "lua", "stop")
	end
	gatelist={}
end

local authokcnt=0
function _M.add_token(tk)
	local uid=assert(tostring(tk.uid))
	log("addtoken %s(%s)",uid,assert(tk.token))
	local thetoken=token[uid]
	tk.ti=skynet.now()
	token[uid]=tk
	online[uid]=nil
	authokcnt=authokcnt+1
end

function _M.check_token(uid,...)
	local newlogin = true
	uid=tostring(uid)
	local tk=token[uid]
	if not tk then
		tk=online[uid]
		if not tk then
			log('check_token timeout %s',uid)
			return false,'timeout'
		end
		newlogin = false
	end
	local r=authmethod.check(tk,...)
	if not r then
		log('check_token failure %s',uid)
		return false,'failure'
	end
	log('check_token %s, newlogin %s',uid,newlogin)
	return tk,newlogin
end

function _M.update_tplayer(up_type, info)
	if up_type == 1 then
		info.time = skynet.time()
	end
	_M.update_token(up_type, info.uid)
	skynet.call(authlist[1], "lua", "update_tplayer", info) 
end

function _M.update_token(up_type, uid)
	if up_type == 1 then
		local tk = token[uid]
		if tk then
			online[uid]=tk
			token[uid]=nil
			log('update_token login uid=%s,token=%s',uid, tk.token)
		end		
	else
		local tk = online[uid]
		if tk then
			tk.ti = skynet.now()
			token[uid]=tk
			online[uid] = nil
			log('update_token logout uid=%s,token=%s',uid, tk.token)
		end
	end
end

function _M.kick(uid)
	token[uid]=nil
	online[uid]=nil
end

function _M.authinfo()
	local pcltime,pclcnt=0,0
	for _,auth in pairs(authlist) do
		local _time,_cnt=skynet.call(auth, "lua", "authinfo")
		pcltime,pclcnt=pcltime+_time,pclcnt+_cnt
	end
	return pcltime,pclcnt,authokcnt
end

service.init {
	command = _M,
	info = {authlist,token},
	init=function()
		skynet.fork(function()
			while true do
				clear_timeout()
				skynet.sleep(100)
			end
		end)
	end,
	release=function()
		_M.stop_auth()
		_M.stop_gate()
	end,
}
