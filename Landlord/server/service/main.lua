local skynet = require "skynet"
local lpeg = require "lpeg"
local log = require "log"
local cluster = require "cluster"

local _M = {}

local function split(s,sep)
	sep = lpeg.P(sep)
  	local elem = lpeg.C((1 - sep)^0)
  	local p = lpeg.Ct(elem * (sep * elem)^0)
  	return lpeg.match(p, s)
end

skynet.start(function()
	local boot=skynet.getenv("boot")
	local list=split(boot," ")
	for _,name in pairs(list) do
		log("boot %s/boot.lua",name)
		skynet.newservice(name.."/boot")
	end
	local nodename=skynet.getenv("clustername")
	cluster.open(nodename)
	skynet.exit()
end)
