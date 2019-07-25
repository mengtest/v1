local skynet = require "skynet"
local service = require "service"
local util = require "util"
local uniq = require "uniq.c"
local log = require "log"

local format = string.format

local proxy
local emailsend
skynet.init(function()
	emailsend = skynet.uniqueservice("world/emailsend")
	local dbmgr = skynet.uniqueservice('dbmgr')
	proxy=assert(skynet.call(dbmgr,"lua","query","DB_GAME"))
end)

local systememails = {}
local online = {}
local _M = {}

function _M.mail_insert(args)
	local expiretime = args.expiretime or 15*60*24 -- 单位分钟,默认15天
	local createtime = args.createtime or skynet.time()
	local deletetime = createtime + expiretime * 60 
	local sql = format("call sp_emailsys_insert('%s','%s',%d,%d,%d,%d,'%s');", 
		args.theme,
		args.content,
		args.gold,
		createtime,
		deletetime,
		args.type,
		args.condition
	)
	local ret1,ret2 = skynet.call(proxy, 'lua', 'query', sql)
	local count = table.unpack(ret1[1])
	local v = ret2[1]
	local email = {
			idx = v[1],
			theme= v[2],
			content= v[3],
			gold = v[4],
			createtime = v[5],
			deletetime = v[6],
			type = v[7],
			condition = v[8],
		}
	systememails[email.idx] = email
	log:debug("systememail insert ok,count[%d]",count)
	-- 在线玩家发送邮件
	for receiveid,_ in pairs(online) do
		_M.send(receiveid, email)
	end
end

function _M.mail_delete(idx)
	local sql = format("call sp_emailsys_delete(%d);",idx)
	skynet.call(proxy, 'lua', 'query', sql)
	systememails[idx] = nil
end

local function check_condition(condition,args)
	return true
end

function _M.loginout(receiveid)
	online[receiveid] = nil
end

function _M.login(receiveid,args)
	online[receiveid] = 1
	local idxs = {}
	local sql = format("call sp_emailflag_select(%d);",receiveid)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	for i, v in ipairs(ret) do
		local idx = v[1]
		idxs[idx] = 1
	end
	local now = skynet.time()
	for idx,email in pairs(systememails) do
		if now < email.deletetime then
			if now >= email.createtime and (not idxs[idx]) then
				if email.type == 0 then
					-- 补偿邮件
					if email.createtime > args.createtime then
						if check_condition(email.condition,args) then
							_M.send(receiveid, email)
						end
					end
				else
					-- 全服邮件
					if check_condition(email.condition,args) then
						_M.send(receiveid, email)
					end
				end
			end
		else
			_M.mail_delete(idx)
		end
	end
end

function _M.send(receiveid, data)
	data.id = uniq.id(1)
	data.receiveid = receiveid
	skynet.send(emailsend, 'lua', 'send', data)
end

local function init()
	local sql = "call sp_emailsys_select();"
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	for i, v in ipairs(ret) do
		local idx = v[1]
		systememails[idx] =  {
			idx = idx,
			theme= v[2],
			content= v[3],
			gold = v[4],
			createtime = v[5],
			deletetime = v[6],
			type = v[7],
			condition = v[8],			
		}
	end
end

skynet.start(function()
	init()
	skynet.dispatch("lua", function(_, _, command, ...)
		local f = assert(_M[command])
		skynet.ret(f(...))
	end)
end)
