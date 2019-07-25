local skynet = require "skynet"
local service = require 'service'
local client=require 'robot.client'
local socket=require 'skynet.socket'
local sharedata=require "skynet.sharedata"
local util=require "util"
local log=require "log"
local md5=require "md5"
local timer=require "timer"
local H=client.handler()
local _enum = require "game.baccarat.enum"

local baccarat_base_cfg
skynet.init(function()
	baccarat_base_cfg = sharedata.query("baccarat_base")[1]
end)

local function req(self, tip, cmd, args)
	local info = client.request(self, 100, cmd, args or {})
	pdump(info, tip)
end

function H:baccarat_userinfo(msg)
	pdump(msg.info, "baccarat_userinfo 玩家信息")
end

local flag
function H:baccarat_status(msg)
	log:info("%s 剩余时间%s", _enum.GameStatusName[msg.status], msg.left)
	if  msg.status == _enum.GameStatus.WAIT then
		req(self, "请求房间内各桌子信息", "baccarat_desk_info")
	elseif msg.status == _enum.GameStatus.BET then
		--
		if not flag then
			local pool = baccarat_base_cfg.betpool
			local rand = math.random(1, #pool)
			local amount = pool[rand]
			local pos = math.random(1,5)
			local str = string.format("%s(%s) 请求押注 pos%s num %s", self.rname, self.rid, pos, amount)
			req(self, str, "baccarat_player_bet", {pos = pos, amount = amount})
		else
			local str = string.format("%s(%s) 请求续投", self.rname, self.rid)
			req(self, str, "baccarat_player_bet_continue", {})
		end
		flag = (not flag)
	elseif msg.status == _enum.GameStatus.PLAY then
		--
	elseif msg.status == _enum.GameStatus.WIN then
		--
	elseif msg.status == _enum.GameStatus.END then
		-- req(self, "获取胜负结果（用于显示路图）", "baccarat_winloss")
		-- req(self, "获取玩家列表(按近期下注数排列)", "baccarat_player_ranklist")
	end
end

function H:baccarat_poker(msg)
	log:info("发牌")
	log:info("master ---------------")
	for _,v in ipairs(msg.master.hand) do
		log:info("牌值 %s",v.value)
	end

	log:info("player ------------------")
	for _,v in ipairs(msg.player.hand) do
		log:info("牌值 %s",v.value)
	end
end

function H:baccarat_win(msg)
	for k,v in pairs(msg.result) do
		if self.rid == v.rid then
			log:error("结算 rid(%s) pos[%s] %s %d 倍率 %s",v.rid, v.pos, v.win > 0 and '赢' or '输', v.gold, baccarat_base_cfg["c"..v.pos]/100)
		end
	end
end

function H:baccarat_bet_info(msg)
	if self.rid == msg.rid then
		log:info("同步下注信息")
		log:info("%s(%s) pos=%s single=%s myall=%s all=%s",self.rname, msg.rid, msg.pos, msg.bet, msg.posnum, msg.amount)
	end
end

function H:baccarat_cardbox(msg)
	log:info("牌盒信息 used=%s left=%s", msg.used, msg.left)
end

function H:baccarat_win_pop(msg)
	log:info("结算显示总输赢冒字(场内人)")
	for k,v in pairs(msg.result) do
		log:info("场内 rid(%s) %s %d",v.rid, v.gold > 0 and '赢' or '输', v.gold)
	end
end