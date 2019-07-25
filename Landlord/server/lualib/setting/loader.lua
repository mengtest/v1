local skynet=require "skynet"
local cluster=require "cluster"
local setting=require "setting"
local json=require "rapidjson.c"
local httpc=require "http.httpc"
local log=require "log"

local function request(host,url,body)
	log("setting request http://%s/%s",host,url)
	local code,body=httpc.request("GET", host, url, {}, {},body)
	assert(code==200,body)
	return json.decode(body)
end

local _M={}
function _M.load_from_remote()
	local stype,sid=skynet.getenv("svr_type"),skynet.getenv("svr_id")
	local name=string.format("%s_%d",stype,sid)
	local lpeg=require "lpeg"
	local HPPT=lpeg.P("http://")^-1
	local HOST=lpeg.C(lpeg.R("AZ","az","09","..","::")^1)
	local DIR=lpeg.C(lpeg.P("/")^0*lpeg.P(1)^0)
	local URL=HPPT*HOST*DIR

	local setting_host=skynet.getenv("setting_host")
	local host,url=URL:match(setting_host)
	if url then
		if string.byte(url,#url)==string.byte("/") then
			url=string.sub(url,1,#url-1)
		end
	end	
	local s=request(host,string.format("%s/%s.json",url,name),"")
	if s.clusternode then
		cluster.reload(request(host,url.."/clusternode.json",""))
		if setting.clusternode()~=s.clusternode then
			cluster.open(s.clusternode)
		end
	end
	return s
end

local function fopen( name )
	local file=assert(io.open(name,"r"))
	local s=file:read("*a")
	file:close()
	return json.decode(s)
end

function _M.load_from_local()
	local stype,sid=skynet.getenv("svr_type"),skynet.getenv("svr_id")
	local name=string.format("run/setting/%s_%d.lua",stype,sid)
	local s=fopen(name)
	if s.clusternode then
		cluster.reload(fopen("run/setting/clusternode.lua"))
		if setting.clusternode()~=s.clusternode then
			cluster.open(s.clusternode)
		end
	end
	return s	
end

function _M.init_setting()
	local s= _M.load_from_local()
	setting.init(s)
end

return _M
