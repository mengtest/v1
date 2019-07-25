local skynet = require "skynet"
local util = require "util"
local service = require "service"

local args = {...}
local cmd = {};

local reloadservicelist = {};

local function init()
end

local function release()
end

function cmd.regreload(addr)
	local ret = {res=true,err=""};
	if( reloadservicelist[addr]) then
		ret.res = false;
		ret.err = "addr exist"
		return ret;
	end
	reloadservicelist[addr] = skynet.time();
	return ret;
end

function cmd.unregreload(addr)
	local ret = {res=true,err=""};
	if( not reloadservicelist[addr]) then
		ret.res = false;
		ret.err = "addr not exist"
		return ret;
	end
	reloadservicelist[addr] = nil;
	return ret;
end

function cmd.getreloadlist()
	--和launcher比较，去掉失效的addr
	local launcherdata = skynet.call(".launcher", "lua", "LIST");
	local removelist = {};
	for addr, info in pairs(reloadservicelist) do
		local _addr = skynet.address(addr);
		if(launcherdata[_addr] == nil) then
			table.insert(removelist, addr);
		end
	end
	for _, addr in pairs(removelist) do
		reloadservicelist[addr] = nil;
	end

	return reloadservicelist;
end

skynet.start(function()
	init();
	skynet.dispatch("lua", function(_,_,command, ...)
		local f = assert(cmd[command], command);
		local ret = f(...);
		skynet.ret(skynet.pack(ret));
	end)
end)
