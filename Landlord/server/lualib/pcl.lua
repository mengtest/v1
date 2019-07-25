local json=require "rapidjson.c"
local md5=require "md5"
local httpc=require "http.httpc"
local skynet=require "skynet"
local log=require "log"

local cfg
local timeout

local serverid=assert(tonumber(skynet.getenv("svr_id")))
httpc.dns()

local idx=1
local function post(url,recvheader,rbody)
	idx=idx+1
	local header={
		["Content-Type"]=string.format('application/json{"gameId":%d}',cfg.gameId),
	}
	log("%d POST %s%s %s",idx,cfg.host,url,rbody)
	local ok,code,body=pcall(httpc.request,"POST", cfg.host, url, recvheader, header,rbody)
	if not ok then
		code,body=nil,code
	end
	log("%d RECV %s %s",idx,tostring(code),tostring(body))
	return code,body
end

local _M={}

function _M.init(c,to)
	cfg=assert(c)
	httpc.timeout=(to or 3)*100
end

function _M.post(url,msgbody)
	msgbody.gameId=cfg.gameId
	msgbody.serverId=serverid
	local msg=json.encode(msgbody)
	local signmsg=md5.sumhexa(msg..cfg.game_secret)..msg
	local recvheader={}
	local status,body=post(url,recvheader,signmsg)
	if status==200 then
		return json.decode(body)
	else
		return {code=-1,errorMsg=tostring(status and "status "..status or body)}
	end
end

function _M.checkpaysign(msg,sign)
	local str=string.format('%sorderCid=%samount=%schannelId=%sserverId=%suid=%sroleId=%spayWay=%s%s'
		,cfg.game_secret,msg.orderCid,msg.amount,msg.channelId,msg.serverId,msg.userId,msg.roleId,msg.payWay,cfg.gameId)
		--print("11111111111", md5.sumhexa(str), str);
	return md5.sumhexa(str)==sign
end

return _M
