local skynet = require "skynet"
local log = require "log"
local sharedata=require "skynet.sharedata"
local client=require "client"
local util = require "util"
local setting = require "setting"

local _RH = require "role.handler"

skynet.init(function()

end)

local cmd = {}

-- 修改系统时间
function cmd.time(self, args)
	if #args < 1 then
		return false
	end
	local t = tonumber(args[1])
	skynet.offset(t)
	return true
end

-- 修改系统时间
function cmd.date(self, args)
	if #args < 1 then
		return false
	end
	local t = util.get_time_from_date(args[1], args[2]) / 100
	local now = skynet.time()
	skynet.offset(t-now)
	return true
end

-- 跳到下周一前10s
function cmd.nextweek(self, args)
	local next_monday_ts = util.get_monday_zero_time() + (7*24*60*60 - 10)*100 - skynet.tick()
	skynet.offset(math.floor(next_monday_ts / 100))
	return true
end

-- 跳到下一天前10s
function cmd.nextday(self, args)
	local nextday_ts = util.get_zero_time() + (86400 - 10)*100 - skynet.tick()
	skynet.offset(math.floor(nextday_ts / 100))
	return true
end

-- 跳到下一天前10s
function cmd.set_money(self, args, src)
	if args.safe ~= nil and self.safe ~= args.safe then
		_RH.changeSave(self, args.safe - self.safe, src)
	end
	if self.map then
		if args.gold ~= nil and self.gold ~= args.gold then
			local sucess,gold=skynet.call(self.map.service, "lua", "changeGold", self.rid, args.gold - self.gold)
			if sucess then
				self.gold = gold;
			end
		end
	else
		if args.gold ~= nil and self.gold ~= args.gold then
			_RH.changeGold(self, args.gold - self.gold, src)
		end
	end
	return {rid=self.rid,gold=self.gold,safe=self.safe}
end

--------------------------------------------------------------------------------------------
-- 外部调用gm命令
local _M = {}
function _M.exe_gm_command(self, order, sys, args, origin)
	local flag = tonumber(setting.get("gmflag"))
	if sys or flag > 0 then
		local f = cmd[order]
		if f then
			return f(self,args,origin)
		end
	end
	return false
end
return _M
