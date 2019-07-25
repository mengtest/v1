local skynet=require "skynet"
local uniq = require "uniq.c"
local util=require "util"
local logindb=require "login.logindb"
local log=require "log"

local function create(username,password)
	-- local uid = uniq.id(1)
	local now = skynet.time()
	local platid = "my"
	local sql = string.format("insert into t_user(platid,uname,upwd,`create`,`last`) values('%s','%s','%s',%d,0);",platid,username,password,now,now)
	logindb(sql)
	local ret=logindb("SELECT LAST_INSERT_ID()")
	return ret[1][1]
end

local _M={}
function _M.create(msg)
	if not msg.sdkJson.username or not msg.sdkJson.password then
		return {code=1}
	end
	local username = msg.sdkJson.username
	local password = msg.sdkJson.password
	local ret=logindb(string.format("select uid from t_user where uname='%s';",username))
	if ret[1] then
		return {code=2}
	end
	local uid = create(username,password)
	return {code=0,uid=uid}
end

function _M.login(msg)
	local info = {code=0}
	if not msg.sdkJson.username or not msg.sdkJson.password then
		info.code=1
	else
		local username = msg.sdkJson.username
		local password = msg.sdkJson.password		
		local ret=logindb(string.format("select uid,upwd from t_user where uname='%s';",username))
		if ret[1] then
			local uid = ret[1][1]
			local upwd = ret[1][2]
			if upwd == password then
				info.userInfo = {
					userId = uid,
					userStatus = 1,		-- 账号状态
					specialUser = 0,	-- 特殊账号
					channelId = 0,
				}
			else
				info.code=2 -- 密码错误
			end
		else
			local uid = create(username,password)
			info.userInfo = {
				userId = uid,
				userStatus = 1,		-- 账号状态
				specialUser = 0,	-- 特殊账号
				channelId = 0,
			}
		end		
	end
	return info
end	

return _M
