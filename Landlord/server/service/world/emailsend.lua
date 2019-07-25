local skynet = require "skynet"
local util = require "util"
local service = require "service"
local circ_queue = require "circ_queue"
local log = require "log"

local maxemailcnt = 100

local manager
local dbproxys
local count
local emaillists = {}
skynet.init(function()
	local dbmgr = skynet.uniqueservice("dbmgr")
	dbproxys = skynet.call(dbmgr, "lua", "query_list", "DB_GAME")
	manager = skynet.uniqueservice("world/manager")
	count = #dbproxys
	for i=1,count do
		emaillists[i] = circ_queue()
	end
end)

local cmd = {}
local format = string.format

local function send(dbproxy, e)
	--_emailmax,_id,_idx,_receiveid,_theme,_content,_gold,_flag,_expiretime
	local sql = format("call sp_email_insert(%d,%d,%d,%d,'%s','%s',%d,%d,%d);",
	maxemailcnt, e.id, e.idx, e.receiveid, e.theme, e.content, e.gold, 0, 30)
	local ret = skynet.call(dbproxy, 'lua', 'query', sql)
	local r = table.unpack(ret[1])
	if r == 0 then --idb
		log:debug("send to player: %d,email idx:%d,id:%d", e.receiveid, e.idx, e.id)
		local agent = skynet.call(manager, "lua", "get_agent", e.receiveid)
		if agent then
			skynet.call(agent, "lua", "send_email", e.receiveid, e)
		end
	elseif r == 1 then
		log:error("send mail player: %d, not exist player", e.receiveid)
	elseif r == 2 then
		log:error("send mail player: %d, email box overmax:%d", e.receiveid, maxemailcnt)
	elseif r == 3 then
		log:error("send mail player: %d, exist system mail:%d", e.receiveid, e.idx)
	end
end

local function handel(idx, dbproxy, data)
	local emaillist = emaillists[idx]
	while data do
		local ok,msg=xpcall(send, debug.traceback, dbproxy, data)
		if not ok then log("handel email error %s", msg) end
		data = emaillist.top()
		emaillist.pop()
	end
	dbproxys[idx] = dbproxy
end

function cmd.send(data)
	local idx = (data.receiveid % count) + 1
	local dbproxy = dbproxys[idx]
	if dbproxy then
		dbproxys[idx] = nil
		skynet.fork(handel, idx, dbproxy, data)
	else
		local emaillist = emaillists[idx]
		emaillist.push(data)
	end
end

service.init {
	command = cmd,
	init=nil,
}
