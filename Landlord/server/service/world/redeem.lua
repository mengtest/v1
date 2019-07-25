
local skynet=require "skynet"
local service=require "service"
local util = require "util"
local log = require "log"
local dblog=require "gamelog"
local trace = require "trace.c" 
local traceback = trace.traceback; 

local format = string.format
local str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

local proxy
skynet.init(function()
	math.randomseed(skynet.time())
	local dbmgr = skynet.uniqueservice('dbmgr')
	proxy=assert(skynet.call(dbmgr,"lua","query","DB_GAME"))
end)

local function query(...)
	local ok, data = xpcall(skynet.call, traceback, proxy, "lua", "query", ...)
	if( not ok) then
		log:error("redeem : query : query faild, data[%s]", tostring(data));
		return nil;
	end
	if( data.errno) then
		log:error("redeem : query :  errno[%s], err[%s], sql[%s]", data.errno, data.err, table.concat({...}));
		return nil;
	end
	return data;
end

local function randomStr(len)
	local rankStr = ""
	local randNum = 0
	for i=0,len do
		local r = math.random(1,3)
		if r == 1 then
			randNum = string.char(math.random(0,25)+65)
		elseif r == 2 then
			randNum = string.char(math.random(0,25)+97)
		else
			randNum = math.random(0,9)
		end
		rankStr = rankStr .. randNum
	end
	return rankStr
end

local _M = {}

function _M.create_code(num,name,only,gold)
	local ret = {}
	for i=1,num do
		local code = ""
		while true do
			code = randomStr(16)
			local ret = query(format("select count(*) from t_redeem where code = '%s';", code));
			if ret and ret[1][1] == 0 then
				break
			end
		end
		query(format("insert into t_redeem(`code`,`name`,`only`,`gold`,`create`,`flag`) values('%s','%s',%d,%d,%d,%d);",code,name,only,gold,skynet.time(),0));
		table.insert(ret, code)
	end
	return ret
end

function _M.redeem_code(code)
	local ret = query(format("call sp_redeem_code('%s');", code));
	if not ret then
		return 1,"err sql"
	end
	if not ret[1] then
		return 2,"not find code"
	end
	local flag = ret[1][1]
	if flag > 0 then
		return 3,"redeemed"
	end
	local gold = ret[1][2]
	return 0, gold
end

function _M.code_type(code)
	local ret = query(format("select name,only from t_redeem where code = '%s';", code));
	if not ret then
		return 1,"err sql"
	end
	if not ret[1] then
		return 2,"not find code"
	end
	local name,only = ret[1][1],ret[1][2]
	return 0,name,only
end

service.init {
	command = _M,
	init=function()

	end,
}
