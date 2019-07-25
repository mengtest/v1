--全服公告
--
local skynet = require "skynet"
local service = require "service"
local sharedata = require "skynet.sharedata"
local util = require "util"
local errcode = require "enum.errcode"
local log = require "log"
local stringval = require "string.stringval"
local timer = require "timer"
local globalnoticeenum = require "enum.globalnotice"
local chatenum = require "enum.chat"

local abs = math.abs;
local floor = math.floor;

local _M = {}

local global_notice_config = nil;
local global_notice_time_cache = nil;

local co_run = nil;
local co = nil;

local cache = {
	--[[
	-- 	{
	-- 	 	[wday] = { 
	-- 	 	 	daysec={
	-- 	 	 	 	[key]={
	-- 	 	 	 	 	pack = {
	-- 	 	 	 	 	 	__proto = "",
	-- 	 	 	 	 	 	...
	-- 	 	 	 	 	}
	-- 	 	 	 	}
	-- 	 	 	} 
	-- 	 	 }
	-- 	}
	--]]
	wday_msg = {},
};

local function loadconfig()
	global_notice_config = sharedata.query("global_notice");
	global_notice_time_cache = {};
	for k, info in pairs(global_notice_config) do
		local t = util.get_second_from_hms_cfg(info.time);
		--rawset(global_notice_config, "_time", t);
		t = floor(t / 60);
		global_notice_time_cache[t] = global_notice_time_cache[t] or {};
		table.insert(global_notice_time_cache[t], info);
	end
end

local function resettimer()
	local diff = skynet.time() % 60;
	timer.addloop()
end

local function system_info_by_str(str)
	local chat_manager_service = skynet.uniqueservice("world/chat_manager");
	local pack = {
		chatid = chatenum.systemchat,
		txt = str,
	};
	skynet.call(chat_manager_service, "lua", "chat_reg", nil, {}, pack);
	return true;
end

local function system_notice_by_str(str)
	local chat_manager_service = skynet.uniqueservice("world/chat_manager");
	skynet.call(chat_manager_service, "lua", "system_notice", str);
	return true;
end

local function system_notice(key, ...)
	-- local str = stringval.getstringval(key, ...);
	-- system_notice_by_str(str);
	return true;
end

local function add_wday_msg(key, proto, pack, wday, daysec, tp)
	daysec = floor(daysec / 60);
	local wdayinfo = cache.wday_msg[wday];
	if( wdayinfo) then
		local daysecinfo = wdayinfo[daysec];
		if( daysecinfo) then
			local keyinfo = daysecinfo[key];
			if( keyinfo) then
				-- log:info("globalnotice : add_wday_msg : key[%s] proto[%s] wday[%d], daysec[%d] already register", key, tostring(proto), wday, daysec);
				return false;
			end
		end
	end
	if( proto) then
		pack.__proto = proto;
	end
	cache.wday_msg[wday] = cache.wday_msg[wday] or {};
	local wdayinfo = cache.wday_msg[wday];
	wdayinfo[daysec] = wdayinfo[daysec] or {};
	local daysecinfo = wdayinfo[daysec];
	daysecinfo[key] = {
		pack = pack,
		tp = tp,
	};
	return true;
end

local function try_process_wday_msg(daymin)
	local datetimes = util.get_date_times();
	local wday = datetimes.wday;
	local wdayinfo = cache.wday_msg[wday];
	if(not wdayinfo) then
		return false;
	end
	local daymininfo = wdayinfo[daymin];
	if( not daymininfo) then
		return false;
	end
	local world_service = skynet.uniqueservice("world/worldchat");

	for key, info in pairs(daymininfo) do
		local packtype = type(info.pack);
		if(packtype == "table") then
			skynet.send(world_service,"lua", "boardcast_msg", info.pack);
		elseif( packtype == "string") then
			if( info.tp == globalnoticeenum.notice_type_notice) then
				system_notice_by_str(info.pack);
			--elseif( info.tp == globalnoticeenum.notice_type_systeminfo) then
				--system_info_by_str(info.pack);
			else
				log:warn("globalnotice : try_process_wday_msg : undefined type[%s], key[%s]", tostring(info.tp), tostring(key));
			end
		else
			log:error("globalnotice : try_process_wday_msg : undefined pack type[%s], key[%s]", tostring(packtype), key);
		end
	end
end

local function update()
	local lastmin = 0;--skynet.time();
	while( co_run) do
		--local nowsec = skynet.time();
		local nowmin = floor(skynet.time() / 60);
		if( abs(nowmin - lastmin) >= 1) then
			lastmin = nowmin;
			--每天定时执行
			local daymin = nowmin - floor(util.get_zero_time() / 6000);
			if( global_notice_time_cache[daymin]) then
				local list = global_notice_time_cache[daymin];
				for time, info in pairs(list) do
					system_notice( info.key);
				end
			end
			--按星期几的几点执行
			try_process_wday_msg(daymin);
		end
		skynet.sleep(100);
	end
end

local function init()
	loadconfig();
	co_run = true;
	co = skynet.fork(update);
end

--=======================================
--[[
--全服通知消息
--@param key : 功能唯一Key
--@param proto : 协议名
--@param pack : 包体
--@param wday : 星期几
--@param daysec : 从当天0点开始的秒数
--@return :
--]]
function _M.register_wday_msg(key, proto, pack, wday, daysec)
	add_wday_msg(key, proto, pack, wday, daysec, nil);
	return true, errcode.success;
end

--[[
--全服跑马灯公告
--@param key : 功能唯一Key
--@param wday : 星期几
--@param daysec : 从当天0点开始的秒数
--@param str : 公告字符串
--@return :
--]]
function _M.register_wday_notice(key, wday, daysec, str, tp)
	assert(type(str) == "string");
	add_wday_msg(key, nil, str, wday, daysec, tp);
	return true, errcode.success;
end
--=======================================
--
--[[
--全服跑马灯公告
--]]
service.init {
	command = _M,
	init = init,
};
