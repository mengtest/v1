local md5=require "md5"

local _M={}

function _M.check(tk,token,ti)
	local server_token=md5.sumhexa(tk.token..ti)
	return server_token==token
end

return _M
