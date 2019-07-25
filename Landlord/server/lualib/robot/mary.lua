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

function H:mary_init(msg)
	log:debug("水果小玛丽：玛利次数 %d, 免费次数 %d,基础分 %d,奖池 %d", msg.game, msg.free, msg.curr, msg.jackpot)
	for i,v in ipairs(msg.level) do
		log:debug("水果小玛丽低分档次：%d档 %d分", i, v)
	end
	if msg.game == 0 then
		local idx = math.random( 1, #msg.level)
		client.push(self,'mary_set',{idx=idx})
		client.push(self,'mary_play',{})
	else
		client.push(self,'mary_game',{})
	end
end

function H:mary_result(msg)
    local str = ""
    for i=1,#msg.roller do
        if i % 5 == 0 then
            str=str .. msg.roller[i] .. '\r\n'
        else
            str=str .. msg.roller[i] .. '\t'
        end
	end
	log:info("\r\n%s",str)
    for _,v in ipairs(msg.lines) do
        log:warn("中奖%d线,个数%d",v.line,v.num)
	end
	log:debug('中奖金额：%d, 奖池：%d, 玛丽：%d, 免费：%d',msg.gold,msg.jackpot,msg.game,msg.free)
	skynet.sleep(200)
	if msg.game > 0 then
		client.push(self,'mary_game',{})
	else
		client.push(self,'mary_play',{})
	end
end

function H:mary_game_ret(msg)
	local inner = "内圈："
	for i,v in ipairs(msg.inner) do
		inner= inner .. v .. ","
	end
	log:debug('小玛丽外圈：%d, %s 剩余次数：%d, 中奖：%d, 总额：%d',msg.outer,inner,msg.game,msg.gold,msg.total)
	skynet.sleep(200)
	if msg.game > 0 then
		client.push(self,'mary_game',{})
	else
		client.push(self,'mary_play',{})
	end
end
