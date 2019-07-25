local skynet=require "skynet"
local cluster=require "cluster"
local util=require "util"

skynet.register_protocol {
	name = "master",
	id = 110,
	pack = skynet.pack,
	unpack = skynet.unpack,
}

local _M = {}

local interfaces={}
function _M.reg(source,name,address)
	if not address then
		address=source
	end
	local old=interfaces[name]
	if old and old~=address then
		skynet.error(string.format("warning masterd handle[%s_] %08x replace %08x",name,address,old))
	else
		skynet.error(string.format("masterd interface register %s_ from %08x",name,address))
	end
	interfaces[name]=address
end

local function dispatch(session,source,cmd,...)
	local f = _M[cmd]
	if f then
		return skynet.retpack(f(source,...))
	end
	for name,address in pairs(interfaces) do
		local m=string.match(cmd,name.."_(.+)")
		if m then
			return skynet.retpack(skynet.call(address,"master",m,...))
		end
	end
	return skynet.retpack(false, "not find cmd:"..cmd..",args:"..util.sdump(...))
end

skynet.start(function()
	skynet.dispatch("lua",dispatch)
	cluster.register("masterd")
end)
