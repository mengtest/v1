local skynet = require "skynet"
local util = require "util"
local errcode = require "enum.errcode"

local proxy
local _M = {}
local format = string.format
skynet.init(function()
	local dbmgr = skynet.uniqueservice('dbmgr')
	proxy=assert(skynet.call(dbmgr,"lua","query","DB_GAME"))
end)

function _M.getall(receiverid)
	local now = skynet.time()
	local sql = format("call sp_email_selectall(%d);", receiverid)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	local emails = {}
	for i, v in ipairs(ret) do
		local email = {
			id = v[1],
			theme= v[2],
			content= v[3],
			gold = v[4],
			flag = v[5],
			createtime = v[6],
		}
		table.insert(emails,email)
	end
	return emails
end

function _M.email_read(receiveid, id)
	local sql = format("call sp_email_read(%d,%d);", receiveid, id)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	local r = table.unpack(ret[1])
	if r == 0 then
		return 0, id
	else
		return errcode.email_readed, "readed"
	end
end

function _M.email_reward(receiveid, id)
	local sql = format("call sp_email_reward(%d,%d);", receiveid, id)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	local r, gold = table.unpack(ret[1])
	if r == 0 then
		return 0, id, gold
	else
		return errcode.email_reward, "picked or delete"
	end
end

function _M.delete_id(receiveid, id)
	local sql = format("call sp_email_delete(%d,%d)", receiveid, id)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	return 0, id
end

function _M.all_rewards(receiveid)
	local sql = format("call sp_email_rewards(%d);", receiveid)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	local r, ids, gold = table.unpack(ret[1])
	if r == 0 then
		return 0, util.split(ids,","), gold
	else
		return errcode.email_nodata, "no data"
	end		
end

function _M.delete_reads(receiveid)
	local sql = format("call sp_email_deletes(%d)", receiveid)
	local ret = skynet.call(proxy, 'lua', 'query', sql)
	local r, ids = table.unpack(ret[1])
	if r == 0 then
		return 0, util.split(ids,",")
	else
		return errcode.email_nodata, "no data"
	end		
end

return _M
