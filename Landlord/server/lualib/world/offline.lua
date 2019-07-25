local skynet = require "skynet"
local service = require "service"
local log = require "log"
local mods = require 'role.mods'
local cache = require 'mysql.cache'
local errcode = require "enum.errcode"
local uniq = require "uniq.c"
require "role.init"
local login = require "world.login"

local dbmgr
skynet.init(function ()
	dbmgr = skynet.uniqueservice("dbmgr")
end)

local _RH = require "role.handler"

local _M = {}

local function begin_offline(rid,nms)
	local role = {}
	role.rid=rid
	role.proxy=skynet.call(dbmgr,"lua","query","DB_GAME")
	local sql = string.format("select uid,rname,gold,safe from t_player where rid=%d",rid)
	local d = skynet.call(role.proxy,'lua','query', sql)
	if d[1] then
		role.uid = d[1][1]
		role.rname = d[1][2]
		role.gold = d[1][3]
		role.safe = d[1][4]
	else
		role = nil
	end
	-- 数据加载
	if role then
		mods.load_offline(role,nms)
	end
	return role
end

local function end_offline(role,nms)
	mods.unload_offline(role,nms)
	cache.save(role.rid)
end

--------------------------------------- 离线处理 start -----------------------------------------
-- 获取对象
function _M.get_player_info(role, args)
	return role
end

-- 转账到账
function _M.transfer(role, args)
	_RH.transfer(role, args)
end

-- 设置金币
function _M.set_money(role, args)
	if args.gold ~= nil then
		role.gold = args.gold
	end
	if args.safe ~= nil then
		role.safe = args.safe
	end
	return role
end
---------------------------------------离线处理 end --------------------------------------------
return {
	command=_M,
	dispatch={
		lua = function(_, _, cmd, rid, func, ...)
			local mods = {}
			if type(cmd) == "table" then
				mods = cmd
			else
				table.insert(mods, cmd)
			end
			local f = assert(_M[func], func)
			local ret = nil
			local role = begin_offline(rid, mods)
			if role then
				ret = f(role, ...)
				end_offline(role, mods)
			end
			skynet.retpack(ret)
		end
	},
}
