local skynet = require "skynet"
local socket = require "skynet.socket"
local log = require "log"

local client = {}
local host
local sender
local handler = {}

function client.handler()
	return handler
end

local thread={}
local retmsg={}
local reterr={}
local function handler_msg(fd,type,name,response,f,self,args)
	local result= f(self, args)
	if response then
		socket.write(fd, string.pack(">s2",response(result)))
	end
end

local function create_read_msg(self)
	local fd=self.fd
	return function ()
		local s = socket.read(fd,2)
		if s then
			local len=string.unpack(">H",s)
			local msg=assert(socket.read(fd,len),"closed "..fd)
			return msg,len
		end
		return nil, 0
	end
end

local function pack_msg(t, data,session)
	local msg=sender(t, data,session)
	return string.pack(">s2", msg)
end

function client.dispatch(self)
	local fd = self.fd
	local read_msg=create_read_msg(self)
	while true do
		local msg, sz = read_msg()
		if sz > 0 then
			local type,name,args,response = host:dispatch(msg, sz)
			if type=="REQUEST" then
				local f = handler[name]
				if f then
					skynet.fork(handler_msg,fd,type,name,response,f,self,args)
				else
					-- unsupported command, disconnected
					--log("Invalid command " .. name)
				end
			else
				local session, result, ud=name, args, response
				local co=thread[session]
				if not co then
					log("Invalid session " .. session)
				else
					retmsg[session]=result
					reterr[session]=nil
					thread[session]=nil
					skynet.wakeup(co)
				end
			end
		else
			log("client close,fd %d",fd)
			return self
		end
		if self.exit then
			log("client exit,fd %d",fd)
			return self
		end	
	end
end

function client.close(fd)
	socket.close(fd)
end

function client.push(c, t, data)
	assert(socket.write(c.fd, pack_msg(t,data)),"closed "..c.fd)
end

function client.pushfds(fds,t,data)
	error("not can call hear")
end

function client.request(c,ti,t,data)
	local session=skynet.genid()
	assert(socket.write(c.fd, pack_msg(t,data,session)),"closed "..c.fd)
	local co=coroutine.running()
	thread[session]=co
	skynet.timeout(ti,function()
		local co=thread[session]
		if not co then return end
		retmsg[session]=string.format("timeout %d %s",c.fd,tostring(t))
		reterr[session]=true
		thread[session]=nil
		skynet.wakeup(co)
	end)
	skynet.wait()
	local err=reterr[session]
	local ret=retmsg[session]
	reterr[session],retmsg[session]=nil,nil
	if err then
		return false,ret
	end
	return ret
end

local function sprotoloader(bin)
	local sproto = require "sproto"
	return sproto.new(bin)
end

function client.init(rpc_run,rpc_req)
	local protoloader = skynet.uniqueservice "protoloader"
	local bin1 = skynet.call(protoloader, "lua", "index", rpc_run, "server")
	host = sprotoloader(bin1):host "package"
	local bin2 = skynet.call(protoloader, "lua", "index", rpc_req, "client")
	sender = host:attach(sprotoloader(bin2))
end

return client