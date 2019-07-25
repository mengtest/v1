local skynet=require "skynet"
local service=require "service"

local LIST={}

local _M={}
function _M.reg(addr,name)
	addr=addr
	table.insert(LIST,{addr,name})
end

function _M.stopall()
	while true do
		local addr=table.remove(LIST)
		if not addr then break end

		skynet.error(string.format("stop :%08x(%s)",addr[1],addr[2] or "Unknown"))
		local ok,err=pcall(skynet.call,addr[1],"lua","stop")
		if not ok then
			skynet.error(err)
		end
		--skynet.sleep(10)
	end
end

service.init{
	info=nil,
	command=_M,
	release=function()
		_M.stopall()
		skynet.sleep(1)
	end,
}
