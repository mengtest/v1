local skynet = require "skynet"
local util = require "util"    

local args = {...} 
local cmd = {};

skynet.init(function()
end);

--[[
--在保留原有消息队列的情况下重启服务，仅用于开发期调试方便，不用重启整个服务器
--*如果有正在挂起的协程则会抛弃，并在相关返回中抛出异常
--*如果服务中有任何动态的状态值，则会丢失
--@param service_name : 服务器名
--@param ... : 服务器启动参数
--@return : 无返回
--]]
function cmd.restart_service(...)
	local service_name = args[1];
	assert(service_name);
	table.remove(args,1);
	local service = skynet.uniqueservice(service_name);
	assert(service);
	skynet.send(service, "lua", "restart_service", ...);
end

--[[
--重新加载，经过绑定的服务
--]]
function cmd.reload(...)
	local hotfixdata_service = skynet.uniqueservice("hotfixdata");
	assert(hotfixdata_service);
	local servicelist = skynet.call(hotfixdata_service, "lua", "getreloadlist");
	assert(servicelist);

	for addr, infostr in pairs(servicelist) do                      
		pcall(skynet.send, addr, "lua", "reload", ...);
	end                
end

--[[
--向所有服务器地址发送执行reload命令，如果在服务器启动时没有调用 service.init初始化，则会报错，用于查看哪些服务器不支持reload
--]]
function cmd.reloadall(...)
	local data = skynet.call(".launcher", "lua", "LIST");     
	local servicelist = {};                                   

	for addr, infostr in pairs(data) do                      
		pcall(skynet.call, addr, "lua", "reload", infostr, ...);
	end                                                       

end

skynet.start(function()
	local f = cmd[args[1]];
	assert(f, tostring(args[1]));
	table.remove(args, 1);

	f(table.unpack(args));

	skynet.exit();
end)
