local skynet = require "skynet"
local service = require "service"
local client = require "client_socket"
local socket = require "skynet.socket"
local log = require "log"
local setting = require "setting"
local timer=require "timer"
local json=require "rapidjson.c"
local pclmsg=require "login.pclmsg"
local logindb=require "login.logindb"

local _H=client.handler()
local _M={}

local auth_timeout
local format = string.format
skynet.init(function()
	auth_timeout=(tonumber(setting.get("auth").auth_timeout or 10000))
end)

function _H.signup(self,msg)
	if not self.fd then return end
	local op="reguser"
	local json_msg={
		device=msg.device,
		imei=msg.imei,
		sdkJson={
			username=msg.username,
			password=msg.password,
			mobile=msg.mobile or "",
			email=msg.email or "",
		},
		channelId=msg.channel or 0,
	}
	return pclmsg[op](self,json_msg)
end

local function login_local(self,msg)
	if msg.token ~= self.verify_token then
		return {e = 1}
	end
	local op="login"
	local json_msg={
		device=msg.device,
		sdkJson={
			username=msg.username,
			password=msg.password,
		},
		channelId=msg.channel,
	}
	return pclmsg[op](self,json_msg)
end

local function login_3rd(self,msg)
	local op="platfrom"
	local json_msg={
		device=msg.device,
		imei=msg.imei,
		sdkJson={
			sdk=msg.username,
			sess=msg.password,
		},
		channelId=msg.channel,
	}
	return pclmsg[op](self,json_msg)
end

function _H.signin(self,msg)
	msg.channel = msg.channel or 0
	if msg.channel == 0 then
		return login_local(self,msg)
	else
		return login_3rd(self,msg)
	end
end

function _H.pcl_msg(self,msg)
	local op=msg.op
	msg.op=nil
	local json_msg=json.decode(msg.json)
	return pclmsg[op](self,json_msg)
end

local function loop_error(self,fd,what)
	local closetimer=self.closetimer
	if closetimer then
		self.closetimer=nil
		timer.del(closetimer)
	end
	if self.fd then
		self.fd=nil
		log("loop %s %s",fd,what or "unknow")
		socket.close(fd)
	end
end

local function new_warning(self)
	return function(id,size)
		if id==self.fd then
			loop_error(self,id,string.format("fd[%d] write buff too big %d",id,size))
		end
	end
end

local urandom=assert(io.open("/dev/urandom","r"))
local function gen_token()
	local s=urandom:read(64)
	local r=string.gsub(s,'([^a-zA-Z0-9])',function(c)
        return string.format('%02x',string.byte(c))
    end)
    return string.sub(r,1,64)
end

local function on_connect(self)
	self.verify_token = gen_token()
	client.send_message(self, "verify", {token=self.verify_token})
end

local function messageloop(self)
	local fd=self.fd
	self.closetimer=timer.add(auth_timeout+200,function()
		self.closetimer=nil
		loop_error(self,fd,"timeout")
	end)
	client.start(self,new_warning(self))
	on_connect(self)
	local in_dispatch
	while true do
		local msg,sz=client.read_message(self)
		if not msg then
			loop_error(self,fd,"closed")
			break
		else
			if in_dispatch then
				loop_error(self,fd,"in_dispatch")
			else
				skynet.fork(function()
					in_dispatch=true
					client.dispatch(self,msg,sz)
					in_dispatch=nil
					if self.exit then
						loop_error(self,fd,"exit")
					end
				end)
			end
		end
	end
end

function _M.auth(fd,addr)
	local self={fd=fd,addr=addr}
	return pcall(messageloop,self)
end

function _M.update_tplayer(info)
	local sql
	if info.time then
		sql = format("update t_player set sid=%d,last=%d where rid=%s;",
			info.sid, info.time, info.rid)

		local d = logindb(sql)
		if d.affected_rows == 0 then
			sql = format("insert ignore t_player(rid,rname,uid,sid,last)values(%d,'%s',%d, %d ,%d)",
				info.rid, info.rname, info.uid, info.sid, info.time or skynet.time())
			logindb(sql)
		end
	end
end

function _M.authinfo()
	return pclmsg.pclcost()
end

service.init{
	command = _M,
	info = nil,
	init=function()
		client.init('*.c2s','*.s2c')
	end,
	release=function()
		
	end
}
