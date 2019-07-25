local skynet = require "skynet"
local socketdriver = require "skynet.socketdriver"
local log = require "log"
local trace = require "trace.c"

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

--local traceback=debug.traceback
local traceback=trace.traceback;
local function forward_msg(fd,type,name,response,service,self,args)
	local start=skynet.now()
	local f = skynet.send
	if response then
		f = skynet.call
	end
	local ok,result= xpcall(f,traceback,service,"lua",name,self.rid, args)
	if ok then
		if response then
			local msg=string.pack(">s2",response(result))
			if not socketdriver.send(fd,msg) then
				log("forward_msg response %s failure",name)
			end			
		end
	else
		log:error("raise error = %s",result)
	end
	local cost=skynet.now()-start
	if cost>0 then
		log("forward_msg %s cost %d",name,cost)
	end
end

local function handler_msg(fd,type,name,response,f,self,args)
	local start=skynet.now()
	local ok,result= xpcall(f,traceback, self, args)
	if ok then
		if response then
			local msg=string.pack(">s2",response(result))
			if not socketdriver.send(fd,msg) then
				log("handler_msg response %s failure",name)
			end
		end
	else
		log:error("raise error = %s",result)
	end
	local cost=skynet.now()-start
	if cost>0 then
		log("handler_msg %s cost %d",name,cost)
	end
end

function client.dispatch(self,msg,sz)
	local type, name, args, response = host:dispatch(msg, sz)
	if type=="REQUEST" then
		local f = handler[name]
		if f then
			handler_msg(self.fd,type,name,response,f,self,args)
		else
			if handler["forward"] then
				local svr = handler["forward"](self)
				if svr then
					forward_msg(self.fd,type,name,response,svr,self,args)
				else
					log:error("Invalid forward map, commond " .. name)
					-- skynet.send(self.gate,"lua","kick",self.fd)
				end
			else
				log:error("Invalid forward nil, commond " .. name)
			end
		end
	else
		local session,result,ud=name,args,response
		local co=thread[session]
		if not co then
			log("Invalid session " .. session)
		else
			retmsg[session]=result
			thread[session]=nil
			reterr[session]=nil
			skynet.wakeup(co)
		end
	end
	if self.quit then
		self.response()(self)
	end
end

function client.dispatch_special(self,sp_msg,msg,sz)
	local type, name, args, response = host:dispatch(msg, sz)
	assert(type=="REQUEST","need message "..sp_msg)
	assert(name==sp_msg,"need message "..sp_msg)
	local f = handler[name]
	handler_msg(self.fd,type,name,response,f,self,args)
end

function client.close(self)
	skynet.call(self.gate,"lua","kick",self.fd)
end

function client.pack(t, data)
	return string.pack(">s2",sender(t, data))
end

function client.push(self, t, data)
	if self.fd ~= nil and self.fd > 0 then
		client.pushfd(self.fd, t, data)
	end
end

function client.pushfd(fd, t, data)
	local msg=string.pack(">s2",sender(t, data))
	socketdriver.send(fd,msg)
end

function client.pushfds(fds,t,data)
	local msg=string.pack(">s2",sender(t, data))
	for fd in pairs(fds) do
		socketdriver.send(fd,msg)
	end
end

function client.pushobjs(objs,t,data)
	local msg=string.pack(">s2",sender(t, data))
	for id,obj in pairs(objs) do
		if obj.fd ~= nil and obj.fd > 0 then
			socketdriver.send(obj.fd,msg)
		end
	end
end

function client.request(self,ti,t,data)
	local session=skynet.genid()
	assert(socketdriver.send(self.fd, sender(t,data,session)))
	local co=coroutine.running()
	thread[session]=co
	skynet.timeout(ti,function()
		local co=thread[session]
		if not co then return end
		retmsg[session]=string.format("timeout %d %s",self.fd,tostring(t)) 
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
