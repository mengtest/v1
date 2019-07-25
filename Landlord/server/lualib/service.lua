local skynet = require "skynet"
local log = require "log"
local skynetdebug = require "skynet.debug"
local restart_service = require "hotfix.restart_service"
local reload_module = require "hotfix.reload_module"
local util = require "util"
local cache = require "skynet.codecache"
local cacheswitch_off="OFF"
local cacheswitch_on="ON"
local trace = require "trace.c"

local traceback=trace.traceback;
local hotfixdata_service = nil;

skynetdebug.reg_debugcmd("RELOAD",function(f)
	local _LOADED=debug.getregistry()._LOADED
	if _LOADED[f] then
		local reload = require "reload"
		return skynet.retpack(true,reload(f))
	else
		return skynet.retpack(nil)
	end
end)

skynet.register_protocol {
	name = "master",
	id = 110,
	pack = skynet.pack,
	unpack = skynet.unpack,
}

local service = {stop=false}

local function add_stop_cmd(funcs,release)
	assert(not funcs.stop,"use release replace stop")
	assert(not funcs.reloadscript,"reloadscript is a system command")
	funcs.stop=function()
		if release then
			release()
		end
		hotfixdata_service = skynet.uniqueservice("hotfixdata");
		local ok, result = xpcall(skynet.call, traceback, hotfixdata_service, "lua", "unregreload", skynet.self());
		if( not ok) then
			log:warn("service : add_stop_cmd : stop : error=[%s]", result);
		end
		--skynet.call(hotfixdata_service,"lua", "unregreload", skynet.self());

		skynet.response()(true)
		skynet.exit()
	end
end

local function add_reload_cmd(funcs)
	if( not funcs.restart_service) then
		funcs.restart_service = restart_service;
	end
	if( not funcs.reload) then
		funcs.reload = function(...)
			local args = {...}
			local module_name = args[1];
			assert(module_name);
			local rootpath = args[2];
			--todo

			local REG = debug.getregistry()
			local _LOADED = REG._LOADED
			if(not _LOADED[module_name])then
				return
			end

			local _RH=require "role.handler"
			_RH:cannewindex();
			reload_module.reload({module_name})

			--全局的需要这种方式读取  如bag.lua

			--local pathlist = {"service/", "lualib/"}
			local pathlist = nil;
			if( rootpath ~= nil) then
				pathlist = {rootpath};
			else
				pathlist = {"lualib/", "service/"};
			end
			for _, path in pairs(pathlist) do
				local filepath=path..string.gsub(module_name,"%.","/")..".lua"
				local file, err = io.open(filepath);
				if( file ~= nil) then
					--local source = file:read "*a"
					file:close();
					cache.mode(cacheswitch_off); --关闭用于开发期重读
					dofile(filepath)
					cache.mode(cacheswitch_on);
				end
			end
			_RH:cantnewindex();
		end
	end
	hotfixdata_service = skynet.uniqueservice("hotfixdata");
	assert(hotfixdata_service);
	local addr = skynet.self();

	skynet.send(hotfixdata_service, "lua", "regreload", addr);

end

local function add_other_cmd(funcs)

end

local function dispatch_default(funcs)
	return function(session,source,cmd, ...)
		local f = funcs[cmd]
		if f then
			if session>0 then
				skynet.retpack(f(...))
			else
				local ok, result = xpcall(f, traceback, ...);
				if not ok then
					log:error("raise error = %s",result);
				end
			end
		else
			log("Unknown command : [%s]", cmd)
			if session>0 then
				skynet.response()(false)
			end
		end
	end
end

function service.init(mod)
	local funcs = mod.command
	if mod.info then
		if type(mod.info=="function") then
			skynet.info_func(mod.info)
		else
			skynet.info_func(function()
				return mod.info
			end)
		end
	end

	add_stop_cmd(funcs,mod.release)

	local dispatch=mod.dispatch or {}
	if not dispatch.lua then
		skynet.dispatch("lua", dispatch_default(funcs))
	end
	if mod.master then
		skynet.dispatch("master", dispatch_default(mod.master))
	end
	for name,call in pairs(dispatch) do
		skynet.dispatch(name,call)
	end
	skynet.start(function()
		add_other_cmd(funcs);
		if mod.init then
			mod.init()
		end
		if mod.quit then
			skynet.call(skynet.uniqueservice("quitmgr"),"lua","reg",skynet.self(),SERVICE_NAME)
		end
		add_reload_cmd(funcs);
		require "debug.notice_print"
	end)
end

return service

