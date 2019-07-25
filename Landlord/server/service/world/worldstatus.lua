local skynet=require "skynet"
local json=require "rapidjson.c"
local md5=require "md5"
local httpc=require "http.httpc"
local setting=require "setting"
local service=require "service"
local log=require "log"

local manager
local gameid
local serverid
local game_secret
local centerhost

local function serverstatus()
	local msg=json.encode{
		gid=gameid,
		sid=serverid,
		reqTime=skynet.time(),
	}
	httpc.timeout=300

	local signmsg=md5.sumhexa(msg..game_secret)
	local url=string.format("/game-server/server-status?sign=%s",signmsg)
	-- log("POST %s%s %s",centerhost,url,msg)
	local ok,status,body=pcall(httpc.request,"POST",centerhost, url, {}, {},msg)
	if not ok then
		status,body=nil,status
	end
	-- log("RECV %s %s",tostring(status),tostring(body))
	if status==200 then
		return json.decode(body)
	else
		return false,tostring(status and "status "..status or body)
	end
end

local function send2manager(state)
	-- local ret = 255
	-- if state then
	-- 	ret = tonumber(state.data[1].server_status)
	-- end
	local ret = 3
	skynet.call(manager,"lua","platfrom_server_state",ret)
end

local function loop()
	while true do
		skynet.sleep(500)
		-- local ok,ret=pcall(send2manager,serverstatus())
		local ok,ret=pcall(send2manager)
		if not ok then
			log(ret)
		end
	end
end

skynet.init(function()
	serverid=setting.get("svr_id")
	manager = skynet.uniqueservice("world/manager")
end)
httpc.dns()

service.init{
	command={},
	info=nil,
	init=function()
		skynet.fork(loop)
	end,
	release=nil,
}
