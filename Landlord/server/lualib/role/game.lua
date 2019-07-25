local MOD=require 'role.mods'
local cache=require 'mysql.cache'
local skynet=require "skynet"
local client=require "client"
local sharedata=require "skynet.sharedata"
local log = require "log"
local util = require "util"
local _RH = require "role.handler"
local errcode = require "enum.errcode"

local nm='game'

local _M={}

local gamemgr
skynet.init(function()
	gamemgr = skynet.uniqueservice("world/gamemgr")
end)

local function resetData(self, data)
	local dirty = false
	for roomid,d in pairs(data) do
		if type(d) == "table" then
			for k,_ in pairs(d) do
				d[k] = 0
				dirty = true
			end
		end
	end
	if dirty then
		data.time = util.get_zero_time()
		cache.dirty(self.rid,nm)
	end
end

local function getGame(self, gameid)
	local D = self.game
	if gameid == 'bull' then
		return D.bull
	elseif gameid == 'goldenflower' then
		local gf = D.goldenflower
		if gf.time and gf.time ~= util.get_zero_time() then
			resetData(self, gf)
		end
		return gf
	elseif gameid =='mlhg' then
		return D.mlhg
	end
end

local function setGame(self, gameid, data)
	local D = self.game
	if gameid == 'bull' then
		D.bull = data -- 本日从系统赢的总数
	elseif gameid == 'goldenflower' then
		data.time = util.get_zero_time()
		D.goldenflower = data
	elseif gameid == 'mlhg' then
		D.mlhg = data
	end
	cache.dirty(self.rid,nm)
end

function _M.load(self)
	local init = false
	self.game = cache.load(self.rid,nm)
	local D = self.game
	D.bull = D.bull or {}					-- 抢庄牛牛数据
	D.goldenflower = D.goldenflower or {}	-- 炸金花数据
	D.mlhg = D.mlhg or {}	-- 炸金花数据
	if init then
		cache.dirty(self.rid,nm)
	end
end

function _M.enter(self)

end

function _M.leave(self)
	if self.map then
		local ret, data = skynet.call(self.map.service, "lua", "leave", self.rid)
		if ret and data ~= nil then
			setGame(self, self.map.gameid, data)
		end
	end
	self.map = nil
end

local function dataSyncToMap(self, data)
	local svr = self.map.service
	if svr then
		skynet.send(svr, "lua", "dataSyncToMap", self.rid, data)
	end
end

function _M.ondayrefresh(self)
	local D = self.game
	-- 炸金花
	resetData(self, D.goldenflower)
	dataSyncToMap(self, D.goldenflower)
end

MOD('game',_M)

local _CH=client.handler()
-- 消息转发到game服务器
function _CH:forward()
	if self.map then
		return self.map.service
	end
	return nil
end

-- 选择游戏
function _CH:enter_game(args)
	if self.map then
		if self.map.gameid ~= args.gameid then
			log:error('enter_game %s err[is in %s]',args.gameid, self.map.gameid)
			return {e = errcode.player_is_in_game}
		end
	end
	local svr
	if self.map then
		svr = self.map.service
	else
		svr = skynet.call(gamemgr, "lua", "get", args.gameid)
	end
	if not svr then
		-- 游戏未开放
		log:error('enter_game %s err[game not open]',args.gameid)
		return {e = errcode.game_not_open}
	end
	local player = {
		fd = self.fd,
		gate = self.gate,
		agent =  skynet.self(),
		rid = self.rid,
		rname = self.rname,

		gold = self.gold,
		icon = self.icon,

		data = getGame(self, args.gameid)
	}
	local err = skynet.call(svr, "lua", "enter", args, player)
	if err ~= errcode.success then
		-- 进入游戏失败
		log:error('enter_game %s err[%d]',args.gameid, err)
		return {e = err}
	end
	log('enter_game %s ok',args.gameid)
	self.map = {}
	self.map.gameid = args.gameid
	self.map.roomid = args.roomid
	self.map.deskid = args.deskid
	self.map.deskpos = args.deskpos
	self.map.service = svr
	return {e = errcode.success}
end

-- 百家乐进入游戏
function _CH:baccarat_play(args)
	if not self.map then
		log:error('baccarat_play player_not_in_game')
		return {e = errcode.player_not_in_game}
	end
	if self.map.gameid ~= "baccarat" then
		return {e = errcode.player_not_in_game}
	end
	local svr = self.map.service
	if not svr then
		-- 游戏未开放
		log:error('baccarat_play %s err[game not open]', self.map.gameid)
		return {e = errcode.game_not_open}
	end
	local err = skynet.call(svr, "lua", "baccarat_play", args, {rid = self.rid})
	if err ~= errcode.success then
		-- 进入游戏失败
		log:error('baccarat_play %s err[%d]', self.map.gameid, err)
		return {e = err}
	end
	self.map.deskid = args.deskid
	return {e = errcode.success}
end

-- 百家乐从桌子返回大厅
function _CH:baccarat_back_hall(args)
	if not self.map then
		log:error('baccarat_back_hall player_not_in_game')
		return {e = errcode.player_not_in_game}
	end
	if self.map.gameid ~= "baccarat" then
		return {e = errcode.player_not_in_game}
	end
	local svr = self.map.service
	if not svr then
		-- 游戏未开放
		log:error('baccarat_back_hall %s err[game not open]', self.map.gameid)
		return {e = errcode.game_not_open}
	end
	local err, info = skynet.call(svr, "lua", "baccarat_back_hall", args, {rid = self.rid})
	if err ~= errcode.success then
		-- 进入游戏失败
		log:error('baccarat_back_hall %s err[%d]', self.map.gameid, err)
		return {e = err}
	end
	self.map.deskid = nil
	return {e = errcode.success, baccarat_desk = info}
end


-- 退出游戏
function _CH:exit_game(args)
	if not self.map then
		return {e = errcode.player_not_in_game}
	end
	local err, data = skynet.call(self.map.service, "lua", "leave", self.rid)
	if not err then
		return {e = errcode.player_exit_game}
	end
	if data ~= nil then
		setGame(self, self.map.gameid, data)
	end
	log("%s exit_game", self.rname)
	self.map = nil
	return {e = errcode.success}
end

return _M
