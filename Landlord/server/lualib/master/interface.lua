local whandler=require "whandler"
local json=require "rapidjson.c"
local cluster=require "cluster"
local util=require "util"
local skynet=require "skynet"
local format=require "exporter.format"

whandler("/",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"
	local r={}
	for k,v in pairs(whandler) do
		table.insert(r,string.format("%s=%s",k,v))
	end
	return 200,json.encode(r)
end)

whandler("/listcluster",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"
	return 200,json.encode(cluster.getconfig())
end)

whandler("/updatecluster",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"
	local config=cluster.getconfig()
	local all={}
	local oks={}
	for node in pairs(config) do
		skynet.fork(function()
			oks[node]=pcall(cluster.call,node,"debuggerd","update_cluster")
		end)
	end
	skynet.sleep(10)
	for node in pairs(config) do
		local type,id=string.match(node,"(%a+)_(%d+)")
		table.insert(all,{
			id=node,
			name=node,
			type=type,
			status=oks[node] and 1 or 0,
		})
	end
	return 200,json.encode({e=0,list=all})
end)

whandler("/statuscluster",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"
	local config=cluster.getconfig()
	local all={}
	local oks={}
	for node in pairs(config) do
		skynet.fork(function()
			oks[node]=pcall(cluster.call,node,"clusterd","ping")
		end)
	end
	skynet.sleep(10)
	for node in pairs(config) do
		local type,id=string.match(node,"(%a+)_(%d+)")
		local ok=true
		table.insert(all,{
			id=node,
			name=node,
			type=type,
			status=oks[node] and 1 or 0,
		})
	end
	return 200,json.encode({e=0,list=all})
end)


whandler("/dispatch",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"

	local sid=assert(tonumber(args.sid),"not sid")
	local node="world_"..sid
	local config=cluster.getconfig()
	if not config[node] then
		return 200,json.encode{e=1,m="NODE_ERROR"}
	end
	local op=string.lower(assert(args.op,"not op"))
	local ret,msg=cluster.call(node,"masterd",op,args)
	if ret then
		return 200,json.encode({e=0,d=ret})
	else
		return 200,json.encode({e=1,m=msg or "error"})
	end
end)

whandler("/pay",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"

	local serverId=assert(tonumber(args.serverId),"not serverId")
	
	local node="world_"..serverId
	local config=cluster.getconfig()
	if not config[node] then
		return 200,json.encode{e=1,m="NODE_ERROR"}
	end
	local ok,err=cluster.call(node,"recharged","on_pay",args)
	if ok then
		return 200,json.encode{e=0}
	else
		return 200,json.encode{e=1,m=err}
	end
	
end)

whandler("/giftcodeinfo", function(args, header)
	header["Content-Type"]="application/json;charset=UTF-8"
	local serverId = assert(tonumber(args.serverId),"not serverId")

	local node="world_"..serverId
	local config=cluster.getconfig()
	if not config[node] then
		return 200,json.encode{e=1,m="NODE_ERROR"} 
	end
	local ok,err=cluster.call(node,"giftcoded", "on_check_info", args)
	if ok then
		return 200,json.encode{e=0,m='SUCCESS',msg='SUCCESS',code='0'}
	else
		return 200,json.encode{e=1,m=err}
	end
end)

whandler("/test",function(args,header)
	header["Content-Type"]="application/json;charset=UTF-8"
	local sid=assert(tonumber(args.sid),"not sid")
	local node="world_"..sid
	local config=cluster.getconfig()
	if not config[node] then
		return 200,json.encode{e=1,m="not find node "..node}
	end
	local ok,err=cluster.call(node,"masterd","role_gm",args)
	if ok then
		return 200,json.encode{e=0}
	else
		return 200,json.encode{e=1,m=err}
	end
end)

whandler("/metrics",function(args,header)
	header["Content-Type"]="text/plain"

	local config=cluster.getconfig()
	local oks={}
	for node in pairs(config) do
		skynet.fork(function()
			local ok,data=pcall(cluster.call,node,"exporter","data")
			if ok then
				oks[node]=data
			else
				oks[node]={}
				skynet.error(data)
			end
		end)
	end
	skynet.sleep(30)
	return 200,format(oks)
end)
