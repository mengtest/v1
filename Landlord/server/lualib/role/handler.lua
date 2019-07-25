--[[

world/agent 服务和其他服务的lua消息分发的区别

	添加第一个参数role	function(role,...)
		world/agent
			skynet.retpack(f(role,...))
		其他为
			skynet.retpack(f(...))

	由于client.handler() 中的处理函数定义是   function (role,msg)
		则lua消息可以派发到client.handler()中
		暂时没有打开这个功能

	world/agent的消息数量多
	
	则但单独为 world/agent 做了一个lua消息管理器
	命名规则
		award.lua文件中

		local _M=require "role.handler"
		_M.award_add(self,list,origin)
		功能名字_方法名字 来避免冲突
]]
local tt={}

function tt:cannewindex()
	setmetatable(self, {
		__index=tt,
		__newindex = function(t, k, v)
			tt[k] = v;
		end
	});
end

function tt:cantnewindex()
	setmetatable(self, {
		__index=tt,
		__newindex=function(t,k,v)
			assert(not tt[k], k)
			tt[k]=v
		end,
	});
end

local cmds=setmetatable({},{
	__index=tt,
	__newindex=function(t,k,v)
		-- assert(not tt[k], k)
		tt[k]=v
	end,
	})

return cmds
