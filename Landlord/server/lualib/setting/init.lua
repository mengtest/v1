local skynet=require "skynet"
local datacenter=require "skynet.datacenter"

local _M={}

function _M.init(s)
	datacenter.set("SETTING",s)
end

function _M.get(...)
	return assert(datacenter.get("SETTING",...))
end

function _M.set(k,v)
	local s = datacenter.get("SETTING")
	if s then
		s[k] = v
		datacenter.set("SETTING",s)
	end
end

function _M.sets(t)
	local s = datacenter.get("SETTING")
	if s then
		for k,v in pairs(t) do
			s[k] = v
		end
		datacenter.set("SETTING",s)
	end
end

function _M.clusternode()
	local c = datacenter.get("SETTING")
	return c and c.clusternode 
end

return _M
