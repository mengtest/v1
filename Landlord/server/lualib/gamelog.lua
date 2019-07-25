local skynet = require "skynet"

local _M = {}

local function getplyinfo( role )
	local args = {
		platform = 100,
		-- sdk = "",
		uid = role.uid,
		-- uname,
		rid = role.rid or role.id,
		rname = role.rname or role.name,
	}
	return args
end

---------------------------- 玩家日志 ----------------------------
-- 创建
function _M.createrole(role)
	local args = getplyinfo(role)
	-- ["createrole"]= {{"optime",1}},
	skynet.send(_M.log,"lua","log","createrole",args, skynet.time())
end
-- 登录
function _M.login(role)
	local args = getplyinfo(role)
	-- ["login"]= {{"logintime",1},{"logouttime",1},{"seri",2},{"optime",1}},
	skynet.send(_M.log,"lua","log","login", args, skynet.time(), 0, role.last_uuid, skynet.time())
end
-- 退出
function _M.logout(role)
	local set = string.format("set logouttime=%d where seri=%d", skynet.time(), role.last_uuid)
	skynet.send(_M.log,"lua","update","login",set)
end
-- 货币
function _M.money(role, old, new, num, src)
	local args = getplyinfo(role)
	-- ["money"]= {{"old",2},{"new",2},{"val",2},{"src",3},{"optime",1}},
	skynet.send(_M.log,"lua","log","money", args, old, new, num, src, skynet.time())
end
---------------------------- 其他日志 ----------------------------

-- 在线人数
function _M.online( num )
	skynet.send(_M.log,"lua","log","online",nil, num, skynet.time())
end

-------------------------------------------------------------------
local function init()
	_M.log = skynet.uniqueservice("dblog")
end

skynet.init(function()
	init()
end)

return _M
