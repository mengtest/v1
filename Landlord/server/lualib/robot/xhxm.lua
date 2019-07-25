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

function H:xhxm_init(msg)
	log:debug("嘻哈熊猫： 当前免费次数 %d,基础分 %d", msg.free, msg.curr)
	for i,v in ipairs(msg.level) do
		log:debug("嘻哈熊猫低分档次：%d档 %d分", i, v)
	end

	local idx = math.random( 1, #msg.level)
	client.push(self,'xhxm_set',{idx=idx})
	client.push(self,'xhxm_play',{})

end

function H:xhxm_result(msg)
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
        log:warn("中奖id %d,个数%d",v.id,v.num)
	end
	log:debug('中奖金额：%d, 免费：%d,奖池奖金：%d',msg.gold,msg.free,msg.jackpot_all)
	skynet.sleep(200)
	client.push(self,'xhxm_play',{})
end
