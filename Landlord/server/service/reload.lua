local skynet=require "skynet"
skynet.cache.clear()

local mod=assert(...)

skynet.start(function()
	local list=skynet.call(".launcher","lua","LIST")
	skynet.error("reload ",mod)
	for address,v in pairs(list) do
		local name=string.match(v,"^snlua ([^ ]+)") or ""
		local ok,result=pcall(skynet.call,address,"debug","RUN","require 'debug.checkreload' ")
		if not ok then
			skynet.error(result)
		else
			ok,result=pcall(skynet.call,address,"debug","CHECKRELOAD",mod)
			if not ok then
				skynet.error(result)
			else
				if result then
					skynet.error(string.format("%s(%s) reload ok",address,name))
				end
			end
		end
	end
	skynet.exit()
end)
