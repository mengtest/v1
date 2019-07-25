local skynet=require "skynet"
local util=require "util"
local setting = require "setting"
local logindb=require "login.logindb"
local localmsg=require "login.localmsg"
local log=require "log"

local svr_id
local maxrole = 4

local pclcnt=0
local pcltime=0

local authmgr
skynet.init(function()
	svr_id=assert(tonumber(skynet.getenv("svr_id")))
	-- urandomd=skynet.uniqueservice("urandomd")
	authmgr=skynet.uniqueservice("login/authmgr")
end)

local urandom=assert(io.open("/dev/urandom","r"))
local function gen_token()
	local s=urandom:read(64)
	local r=string.gsub(s,'([^a-zA-Z0-9])',function(c)
        return string.format('%02x',string.byte(c))
    end)
    return string.sub(r,1,64)
end

local _M={}
function _M.reguser(self,msg)
	self.exit=true
	msg.ip=util.split_row(self.addr,":")
	msg.sdkJson.created=skynet.time()
	local n=skynet.now()
	local r=localmsg.create(msg)
	pcltime,pclcnt=pcltime+skynet.now()-n,pclcnt+1
	return {e=r.code}
end

local function on_login(self,msg,r)
	self.exit=true
	if tonumber(r.code)~=0 then
		return {e=r.code}
	else
		local userInfo=r.userInfo
		local userStatus=tonumber(userInfo.userStatus)
		local uid=tostring(userInfo.userId)
		local iswhite=tonumber(userInfo.specialUser)
		local channel=userInfo.channelId
		local last = skynet.time()
		logindb(string.format("update t_user set last=%d where uid='%s'",last,uid))

		local token=gen_token()
		local o={
			last=last,
			token=token,
			uid=uid,
			auth = skynet.self(),
			iswhite=iswhite>0,
			channel=channel,
			dev_id=msg.imei or "",
			dev_type=tonumber(msg.device) or 0,
		}
		skynet.call(authmgr,"lua","add_token",o)
		log("signin uid=%s",uid)
		
		local auth = setting.get("auth")
		local serverinfo = {
			ip = auth.game_ip,
			port = auth.game_port,
		}
		return {e=0,uid=uid,token=o.token,servers=serverinfo,auth=svr_id}
	end
end

function _M.login(self,msg)
	msg.sdkJson.login_time=skynet.time()
	msg.ip=util.split_row(self.addr,":")
	local n=skynet.now()
	local r=localmsg.login(msg)
	pcltime,pclcnt=pcltime+skynet.now()-n,pclcnt+1
	return on_login(self,msg,r)
end

function _M.pclcost()
	return pcltime,pclcnt
end

return _M
