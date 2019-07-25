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
local _enum = require "game.cattle.enum"

local cattle_config
skynet.init(function()
	cattle_config = sharedata.query("cattle_config")[1]
end)

local function req(self, tip, cmd, args)
	log:info(tip)
	local info = client.request(self, 100, cmd, args or {})
	pdump(info, "info")
end

function H:cattle_userinfo(msg)
	log("cattle_userinfo 玩家信息")
	pdump(msg.info, "玩家信息")
end

local flag
function H:cattle_status(msg)
	log:info("%s 剩余时间%s", _enum.GameStatusName[msg.status], msg.left)
	if  msg.status == _enum.GameStatus.WAIT then
		--
		local str = string.format("%s(%s) 请求上庄", self.rname, self.rid)
		req(self, str, "cattle_dealer_operate", {operate = 1})
	elseif msg.status == _enum.GameStatus.BET then
		--
		if not flag then
			local pool = cattle_config.betpool
			local rand = math.random(1, #pool)
			local amount = pool[rand]
			local pos = math.random(1,4)
			local str = string.format("%s(%s) 请求押注 pos%s num %s", self.rname, self.rid, pos, amount)
			req(self, str, "cattle_player_bet", {pos = pos, amount = amount})
		else
			local str = string.format("%s(%s) 请求续投", self.rname, self.rid)
			req(self, str, "cattle_player_bet_continue", {})
		end
		flag = (not flag)
	elseif msg.status == _enum.GameStatus.PLAY then
		--
	elseif msg.status == _enum.GameStatus.WIN then
		--
	elseif msg.status == _enum.GameStatus.END then
		--
		-- log:info("%s(%s) 获取胜负走势", self.rname, self.rid)
		-- client.push(self, "cattle_winloss_rank", {})

		-- log:info("%s(%s) 获取坐庄列表", self.rname, self.rid)
		-- client.push(self, "cattle_dealer_list", {})

		-- log:info("%s(%s) 获取玩家列表(按近期下注数排列)", self.rname, self.rid)
		-- client.push(self, "cattle_player_ranklist", {})
	end
end

function H:cattle_poker(msg)
	log:info("master ---------------牌型 %s 倍率 %s", msg.master.type, cattle_config["c"..msg.master.type])
	for k,v in pairs(msg.master.hand) do
		log("type=%s value=%s",v.type,v.value)
	end

	log:info("others ------------------")
	for pos,v in ipairs(msg.others) do
		log("位置 %s, 牌型 %s 倍率%s", pos, v.type, cattle_config["c"..v.type])
		for _,v1 in ipairs(v.hand) do
			log("type=%s value=%s",v1.type, v1.value)
		end
	end
end

function H:cattle_win(msg)
	for k,v in pairs(msg.result) do
		if self.rid == v.rid then
			log("结算 rid(%s) pos[%s] %s %d",v.rid, v.pos, v.win > 0 and '赢' or '输', v.gold)
		end
	end
end

function H:cattle_bet_info(msg)
	if self.rid == msg.rid then
		log:info("同步下注信息")
		log:info("%s(%s) pos=%s single=%s myall=%s all=%s canbet=%s",self.rname, msg.rid, msg.pos, msg.bet, msg.posnum, msg.amount, msg.canbet)
	end
end

function H:cattle_dealder_info(msg)
	log:info("庄家信息变化")
	log("%s(%s) 坐庄轮数=%s 坐庄总轮数=%s", msg.master.rname, msg.master.rid, msg.circle, msg.totalcircle)
end
