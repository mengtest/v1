
local service_name=SERVICE_NAME
if service_name~="world/agent" then return end

local client=require "client"

local skynet=require "skynet"
local socketdriver = require "skynet.socketdriver"
local profile=require "skynet.profile"
local log=require "log"

local xpcall=xpcall
local traceback=debug.traceback

local profiled
skynet.init(function()
	profiled=skynet.uniqueservice("debug/profiled")
end)

local function getupvalue(func,name)
	for i=1,math.maxinteger do
		local nm,value=debug.getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end

local function handler_msg(self,type,name,response,f,self,args)
	profile.start()
	local ok,result= xpcall(f,traceback,self,args)
	if ok then
		local fd=self.fd
		if response and fd then
			local msg=string.pack(">s2",response(result))
			if not socketdriver.send(fd,msg) then
				log("response %s failure",name)
			end
		end
	else
		log("raise error = %s",result)
	end
	local ti=profile.stop()
	skynet.send(profiled,"lua","stat","agentclient".."."..name,ti)
end

local _,upidx=assert(getupvalue(client.dispatch,"handler_msg"))
debug.setupvalue(client.dispatch,upidx,handler_msg)
