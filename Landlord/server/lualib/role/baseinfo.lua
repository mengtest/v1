local skynet=require "skynet"
local client=require "client"
local MOD=require "role.mods"
local cache=require "mysql.cache"
local event=require "role.event"
local util = require "util"
local log = require "log"
local dblog=require "gamelog"
local login = require "world.login"
local errcode = require "enum.errcode"

local _RH = require "role.handler"
local _CH = client.handler()

local nm = "baseinfo"

local _M={}

local redeem
local manager
skynet.init(function()
	redeem = skynet.uniqueservice("world/redeem")
	manager = skynet.uniqueservice("world/manager")
end)


function _M.load(self, offline)
	local init = false
	self.base = cache.load(self.rid,nm)
	local D = self.base
	D.redeem = D.redeem or {}		-- 兑换码记录
	D.safe = D.safe or {			-- 保险柜
		open = nil,					-- 打开标记
		modify = 0,					-- 密码修改次数
		password = '',				-- 当前密码
		transfer = {},				-- 赠送日志
		receive = {}				-- 获赠日志
	}
	if D.safe.transfer == nil then
		init = true
		D.safe = {			-- 保险柜
			open = nil,					-- 打开标记
			modify = 0,					-- 密码修改次数
			password = '',				-- 当前密码
			transfer = {},				-- 赠送日志
			receive = {}				-- 获赠日志
		}
	end
	if init then
		cache.dirty(self.rid,nm)
	end
end

function _M.enter(self)
	local D = self.base
	D.safe.open = nil
end

function _M.leave(self)
	local D = self.base
	D.safe.open = nil
end

function _M.reenter(self)
	local D = self.base
	D.safe.open = nil
end

function _M.redeem(self, name, only)
	local D = self.base
	if not D.redeem[name] then
		D.redeem[name] = 1
	elseif only == 0 then
		D.redeem[name] = D.redeem[name] + 1
	end
	cache.dirty(self.rid,nm)
	cache.save(self.rid)
end

-- 修改金币
function _M.changeGold(self, amount, src)
	local gold = self.gold + amount
	if gold < 0 then
		return -1
	end
	dblog.money(self, self.gold, gold, amount, src)
	self.gold = gold
	client.push(self, "player_gold", {info = {self}})
	login.update_gold(self, gold)
	return self.gold
end

-- 存钱
function _M.saveSafe(self, amount)
	local gold = self.gold - amount
	if gold < 0 or amount < 0 then
		return -1
	end
	dblog.money(self, self.gold, gold, amount, 'safe_save')
	self.gold = gold
	self.safe = self.safe + amount
	login.update_safe(self, self.safe, self.gold)
	client.push(self, "player_gold", {info = {self}})
	cache.dirty(self.rid,nm)
	return amount
end

-- 取款
function _M.drawSafe(self, amount)
	local safe = self.safe - amount
	if safe < 0 or amount < 0 then
		return -1
	end
	dblog.money(self, self.gold, self.gold+amount, amount, 'safe_draw')
	self.gold = self.gold + amount
	self.safe = safe
	login.update_safe(self, self.safe, self.gold)
	client.push(self, "player_gold", {info = {self}})
	cache.dirty(self.rid,nm)
	return amount
end

-- 修改保险箱
function _M.changeSave(self, amount, src)
	local safe = self.safe + amount
	if safe < 0 then
		return -1
	end
	self.safe = safe
	login.update_safe(self, safe)
	cache.dirty(self.rid,nm)
	return self.safe
end

-- 能否汇款
function _M.canTransfer(self, rid, amount)
	if self.rid == rid then
		return nil
	end
	local safe = self.safe - amount
	if safe < 0 or amount < 0 then
		return nil
	end
	if self.tmp.get_name ~= nil and self.tmp.get_name.rid == rid then
		return self.tmp.get_name.rname
	end
	local rname = login.get_name(self.proxy, rid)
	return rname
end


MOD(nm,_M)

local OP_TYPE = {
	open = 1,
	password = 2,
	save = 3,
	draw = 4,
	transfer = 5,
	receive = 6
}
local MAX_LOG = 100
local function add_log(self, log)
	local D = self.base
	if log.op == OP_TYPE.transfer then
		table.insert(D.safe.transfer, log.args)
		if #D.safe.transfer > MAX_LOG then
			table.remove(D.safe.transfer, 1)
		end
	elseif log.op == OP_TYPE.receive then
		table.insert(D.safe.receive, log.args)
		if #D.safe.receive > MAX_LOG then
			table.remove(D.safe.receive, 1)
		end
	end
	if D.safe.open ~= nil then
		if log.op == OP_TYPE.open then
			client.push(self, 'safe_info', {gold=self.safe,transfer=D.safe.transfer,receive=D.safe.receive})
		elseif log.op == OP_TYPE.transfer then
			client.push(self, 'safe_info', {gold=self.safe,transfer={log.args}})
		elseif log.op == OP_TYPE.receive then
			client.push(self, 'safe_info', {gold=self.safe,receive={log.args}})
		else
			client.push(self, 'safe_info', {gold=self.safe})
		end
	end
end
----------------------------------内部到agent消息-----------------------------------
-- 修改金币
function _RH.changeGold(self, amount, src)
	return _M.changeGold(self, amount, src)
end

-- 修改金币
function _RH.changeSave(self, amount, src)
	return _M.changeSave(self, amount, src)
end

-- 修改头像
function _RH.chargeIcon(self, idx)

end

-- 汇款到账
function _RH.transfer(self, args)
	_M.changeSave(self, args.amount, 'transfer_recv')
	add_log(self, {op=OP_TYPE.receive,args={rid=args.rid,rname=args.rname,amount=args.amount,ti=skynet.time()}})
	cache.dirty(self.rid,nm)
end

----------------------------------客户端消息----------------------------------------
-- 获取角色名
function _CH.get_name(self, args)
	local rname = login.get_name(self.proxy, args.rid)
	if rname == nil then
		rname = ''
	else
		self.tmp.get_name = {
			rid = args.rid,
			rname = rname
		}
	end
	return {rname = rname}
end
-- 打开保险箱
function _CH.safe_open(self, args)
	local D = self.base
	if D.safe.modify == 0 then 
		return {e = errcode.safe_null}
	end
	if D.safe.password ~= args.password then
		log:error('%s safe_open password=%s, args=%s',self.rname,D.safe.password,args.password)
		return {e = errcode.safe_password}
	end
	D.safe.open = skynet.time()
	add_log(self, {op=OP_TYPE.open,args={ti=skynet.time()}})
	return {e = errcode.success}
end

-- 修改保险箱密码
function _CH.safe_password(self, args)
	if args.old == nil or args.new ==nil then
		return {e = errcode.safe_null}
	end
	local D = self.base
	if D.safe.password ~= args.old then
		log:error('%s safe_password old=%s, args=%s',self.rname,D.safe.password,args.old)
		return {e = errcode.safe_password}
	end
	add_log(self, {op=OP_TYPE.password,args={ti=skynet.time()}})
	D.safe.modify = D.safe.modify + 1
	D.safe.password = args.new
	cache.dirty(self.rid,nm)
	cache.save(self.rid)
	return {e = errcode.success}
end

-- 保险箱存钱
function _CH.safe_save(self, args)
	local D = self.base
	if D.safe.open == nil then
		return { e = errcode.safe_not_open}
	end
	if _M.saveSafe(self, args.amount) < 0 then
		return { e = errcode.safe_save_gold}
	end
	add_log(self, {op=OP_TYPE.save,args={amount=args.amount,ti=skynet.time()}})
	cache.dirty(self.rid,nm)
	cache.save(self.rid)
	return {e =  errcode.success}
end

-- 保险箱取钱
function _CH.safe_draw(self, args)
	local D = self.base
	if D.safe.open == nil then
		return {e = errcode.safe_not_open}
	end
	if _M.drawSafe(self, args.amount) < 0 then
		return {e = errcode.safe_draw_gold}
	end
	add_log(self, {op=OP_TYPE.draw,args={amount=args.amount,ti=skynet.time()}})
	cache.dirty(self.rid,nm)
	return {e = errcode.success}
end

-- 保险箱汇款
function _CH.safe_transfer(self, args)
	local D = self.base
	if D.safe.open == nil then
		return {e = errcode.safe_not_open}
	end
	local rname = _M.canTransfer(self, args.tid, args.amount)
	if rname == nil then
		return {e = errcode.safe_tran_gold}
	end
	_M.changeSave(self, 0-args.amount, 'transfer_send')
	cache.dirty(self.rid,nm)
	local d = {
		amount = args.amount,
		rid = self.rid,
		rname = self.rname,
	}
	skynet.send(manager, "lua", "transfer", args.tid, d)
	add_log(self, {op=OP_TYPE.transfer,args={rid=args.tid,rname=rname,amount=args.amount,ti=skynet.time()}})		
	return {e = errcode.success}
end

-- 兑换码
function _CH.redeem(self, args)
	local ret1,name,only = skynet.call(redeem, 'lua', 'code_type', args.code)
	if ret1 > 0 then
		log:error("%d redeem %s name",self.rid,args.code,name)
		return 1
	end
	if only > 0 and self.base.redeem[name] then
		log:error("%d redeem %s name(%s) is onley(%d)",self.rid,args.code,name,only)
		return 2
	end
	local ret2,gold = skynet.call(redeem, 'lua', 'redeem_code', args.code)
	if ret2 == 0 then
		_M.redeem(self, name, only)
		_M.changeGold(self, gold, "redeem")
	else
		log:error("%d redeem %s err(%s)",self.rid,args.code,gold)
	end
	return 0
end

return _M
