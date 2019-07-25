-- 用于测试

local skynet = require "skynet"
local util = require "util"
local mysqlaux = require "skynet.mysqlaux.c"
local sharedata = require "skynet.sharedata"
local snax = require "skynet.snax"
local trace = require "trace.c"

local args = {...}
local cmd = {}

local manager_service

-- rh
-- ch
-- test callmod privilegecard_mod_continue_days rid 274487115252417 number cardid 1 number days 1
-- test callmsg charge_day_chargereward_get_reward string id test_id_110

skynet.init(function()

end)
--=================================================================
--
--
local function callmsg(rid, cmd, ...)
	local agent = skynet.call(manager_service, "lua", "get_agent", tonumber(rid))
	print("=============", rid, agent, cmd, ...)
	if agent then
		skynet.call(agent, "lua", "on_client_msg", tonumber(rid), cmd, ...)
	else
		assert(false, "get agent failed")
	end
end

local function callmod(rid, cmd, ...)
	local agent = skynet.call(manager_service, "lua", "get_agent", rid)
	local res = nil
	local err = nil
	if agent then
		return skynet.call(agent, "lua", cmd, rid, ...)
	else
		assert(false, "get agent failed")
	end
end

local _rid = 93256138359489 --qwe002
local rid = _rid

function cmd.callmsg(msg, ...)
	local args = {...}
	local m = {}

	local len = 3
	local _rid = nil
	if( args[1] == "rid") then
		_rid = tonumber(args[2])
		table.remove(args,1)
		table.remove(args,1)
	end
	if( args[1] == "string" or args[1] == "number") then
		local nextcall = nil
		local nextkey = nil
		for k, v in ipairs(args) do
			local index = k%len
			if( index == 1) then 	--第一个为类型
				if( v == "string") then
					nextcall = tostring
				elseif( v == "number") then
					nextcall = tonumber
				else
					assert(false, string.format("undefined type[%s],index[%d] ", v, k))
				end
			elseif( index == 2) then --第二个为key
				nextkey = tostring(v)
			else --为真实参数
				assert(nextcall)
				assert(nextkey)
				m[nextkey] = nextcall(v)
			end
		end
	else
		for k, v in pairs(args) do
			m[k] = v
		end
	end
	callmsg(_rid or rid, msg, m)
end

function cmd.callmod(msg, ...)
	local args = {...}
	local m = {}

	local len = 3
	local _rid = nil
	if( args[1] == "rid") then
		_rid = tonumber(args[2])
		table.remove(args,1)
		table.remove(args,1)
	end
	if( args[1] == "string" or args[1] == "number") then
		local nextcall = nil
		local nextkey = nil
		for k, v in ipairs(args) do
			local index = k%len
			if( index == 1) then 	--第一个为类型
				if( v == "string") then
					nextcall = tostring
				elseif( v == "number") then
					nextcall = tonumber
				else
					assert(false, string.format("undefined type[%s],index[%d] ", v, k))
				end
			--[[
			elseif( index == 2) then --第二个为key
				nextkey = tostring(v)
			--]]
			else --为真实参数
				assert(nextcall)
				--assert(nextkey)
				table.insert(m, nextcall(v))
			end
		end
	else
		for k, v in pairs(args) do
			table.insert(m, v)
		end
	end
	local ret = {callmod(_rid or rid, msg, table.unpack(m))}
	print("=============mod ret", msg, table.unpack(m))
	pdump(ret)
end

skynet.start(function()
	manager_service = skynet.uniqueservice("world/manager")

	local f = cmd[args[1]]
	assert(f)
	table.remove(args, 1)

	f(table.unpack(args))
	skynet.exit()
end)
