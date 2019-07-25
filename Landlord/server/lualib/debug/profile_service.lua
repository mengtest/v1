local service_name=SERVICE_NAME

local USELIST={
["login/world_status"]=true,
["login/auth"]=true,
["login/authmgr"]=true,
["debuggerd"]=true,
["masterd"]=true,
["center/melee"]=true,
["center/mobafive"]=true,
["center/mobathr"]=true,
["zset_manger"]=true,
["cfgcache"]=true,
["exporter"]=true,
["wordfilterd"]=true,
["world/faction"]=true,
["world/teammgr"]=true,
["world/map_manager"]=true,
["world/agent"]=true,
["world/gate"]=true,
["world/dropd"]=true,
["world/arena"]=true,
["world/hangup"]=true,
["world/roleinfod"]=true,
["world/equip_affixd"]=true,
["world/master_emailmgr"]=true,
["world/escort"]=true,
["world/master_rank"]=true,
["world/map"]=true,
["world/manager"]=true,
["world/recharged"]=true,
["world/shopdatad"]=true,
["world/factionmgr"]=true,
["world/command"]=true,
["world/world_boss"]=true,
["world/friendmgr"]=true,
["world/chatmgr"]=true,
["world/master_marquee"]=true,
["world/dragon_treasure"]=true,
["world/emailreceive"]=true,
["world/consign"]=true,
["world/home_guard"]=true,
["world/emailmgr"]=true,
["world/babelmgr"]=true,
["world/gmcfgmgr"]=true,
["mysqld"]=true,

}

if not USELIST[service_name] then return end

local service=require "service"
local skynet=require "skynet"
local profile=require "skynet.profile"
local log=require "log"


local profiled
skynet.init(function()
	profiled=skynet.uniqueservice("debug/profiled")
end)

local function getupvalue(func,name)
	for i=1,math.maxinteger do
		local nm,value=debug.getupvalue(func,i)
		if not nm then break end
		if nm==name then return value,i,name end
	end
	assert("not found upvalue "..name)
end

local add_stop_cmd=getupvalue(service.init,"add_stop_cmd")
local ret=service.ret

local function dispatch_default(funcs)
	return function(session,_,cmd, ...)
		local f = funcs[cmd]
		if f then
			profile.start()
			if session>0 then
				ret(f(...))
			else
				f(...)
			end
			skynet.send(profiled,"lua","stat",service_name.."."..cmd,profile.stop())
		else
			log("Unknown command : %s", cmd)
			if session>0 then
				skynet.response()(false)
			end
		end
	end
end

local function warp_dispatch(call)
	return function (session,source,cmd, ...)
		profile.start()
		call(session,source,cmd,...)
		skynet.send(profiled,"lua","stat",service_name.."."..cmd,profile.stop())
	end
end

function service.init(mod)
	local info=mod.info or mod
	if type(info)~="function" then
		service.info=function() return info end
	else
		service.info=info
	end
	skynet.info_func(service.info)

	local funcs = mod.command or require "lua_handler"
	add_stop_cmd(funcs,mod.release)

	local dispatch=mod.dispatch or {}
	if not dispatch.lua then
		skynet.dispatch("lua", dispatch_default(funcs))
	end
	if not dispatch.master then
		skynet.dispatch("master", dispatch_default(mod.master_command or require "master_handler"))
	end
	for name,call in pairs(dispatch) do
		skynet.dispatch(name,call)
	end
	skynet.start(function()
		if mod.init then
			mod.init()
		end
		if mod.reg_quit then
			skynet.call(skynet.uniqueservice("quitmgr"),"lua","reg",skynet.self(),SERVICE_NAME)
		end
		local master_key=mod.master_key
		if master_key then
			require("master").reg(master_key)
		end
	end)
end
