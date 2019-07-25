local skynet=require "skynet"

local address
local function get_address()
	if not address then
		address=skynet.uniqueservice("masterd")
	end
	return address
end

local _M={}

function _M.reg(master_key,address)
	require("master."..master_key)
	skynet.call(get_address(),"lua","reg",master_key,address)
end

return _M
