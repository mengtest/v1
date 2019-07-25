local skynet=require "skynet"
local log=require "log"
local util = require "util"

local _M={}

local event = {}
--
function _M.register( e, n, f )
 	local t = event[e]
 	t[n] = f
end

function _M.trigger( e, ... )
	local t = event[e]
	if t then
		for n,f in pairs(t) do
			f(...)
		end
	end
end

return _M
