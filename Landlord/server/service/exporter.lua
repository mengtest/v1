local skynet=require "skynet"
local service=require "service"
local exporter=require ("exporter."..skynet.getenv("svr_type"))
local cluster=require "cluster"

local _M=require "handler"
function _M.data()
	local D={}
	exporter(D)
	return D
end

service.init{
	command=_M,
	init=function()
		cluster.register("exporter",skynet.self())
	end,
}
