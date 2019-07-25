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

function H:bull_Players(msg)
	log:debug("抢庄牛牛玩家列表")
	for k,v in pairs(msg.players) do
		log("rid=%d\tpos=%d\trname=%s",v.rid,v.pos,v.rname)
	end
end

function H:game_revert(msg)
	log:debug("重连结束")
end

function H:bull_dealer(msg)
	log("rid=%d 确认为庄家",msg.rid)
end

function H:bull_poker(msg)
	for i,v in ipairs(msg.list) do
		log("rid=%d %d张牌 牌型 %d,显示 %d",v.rid, #v.cards, v.type, v.show)
	end
end

function H:bull_win(msg)
	for k,v in pairs(msg.result) do
		log("rid=%d %s %d",v.rid, v.win > 0 and '赢' or '输',v.gold)
	end
end

function H:bull_status(msg)
	log:info("抢庄牛牛 状态%d 剩余时间%d", msg.status, msg.left)
	if  msg.status == 2 then
		-- 抢庄
		local idx = math.random(1, #msg.data)
		log('抢庄 %d倍',msg.data[idx])
		client.push(self,'bull_dealer',{idx=idx})
	end
	if  msg.status == 3 then
		-- bull_bet
		local idx = math.random(1, #msg.data)
		log('押注 %d倍',msg.data[idx])
		client.push(self,'bull_bet',{idx=idx})
	end
	if  msg.status == 4 then
		-- bull_show
		log('摊牌')
		client.push(self,'bull_show',{})
	end	
	if  msg.status == 6 then
		skynet.sleep(math.random(1,20) * 100)
		if math.random(1,100) > 10 then
			client.push(self,'bull_more',{})
		else
			client.push(self,'exit_game',{})
		end
	end
end

function H:bull_grap(msg)
	for i,v in ipairs(msg.list) do
		log("%d 抢庄 %d倍", v.rid, v.odds)
	end
end

function H:bull_bet(msg)
	for i,v in ipairs(msg.list) do
		log("%d 压住 %d倍", v.rid, v.bet)
	end
end
