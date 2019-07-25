local client=require "client"
local skynet=require "skynet"
local socketdriver = require "skynet.socketdriver"
local log = require "log"
local _MASTER=require "master_handler"

local function new_handler_msg(before_wait,after_wait)
	return function(self,type,name,response,f,self,args)
		local start=skynet.now()
		if before_wait>0 then skynet.sleep(before_wait) end
		local ok,result= xpcall(f,debug.traceback,self,args)
		if ok then
			local fd=self.fd
			if response and fd then
				if after_wait>0 then skynet.sleep(after_wait) end
				local msg=string.pack(">s2",response(result))
				if not socketdriver.send(fd,msg) then
					error(string.format("response %s failure",tostring(name)))
				end
			end
		else
			log("raise error = %s",result)
		end
		local cost=skynet.now()-start
		if cost>0 then
			log("handler_msg %s cost %d",name,cost)
		end
	end
end

local function getupvalue(func,name)
	for i=1,math.maxinteger do
		local nm,value=debug.getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end

return function(before_wait,after_wait)
	local _,upidx=assert(getupvalue(client.dispatch,"handler_msg"))
	debug.setupvalue(client.dispatch,upidx,new_handler_msg(before_wait,after_wait))
end
