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

function H:mlhg_init(msg)
	log:debug("麻辣火锅： 基础分 %d", msg.curr)
	for i,v in ipairs(msg.level) do
		log:debug("麻辣火锅低分档次：%d档 %d分", i, v)
	end

	local idx = math.random( 1, #msg.level)
	client.push(self,'mlhg_set',{idx=idx})
	client.push(self,'mlhg_play',{})

end

function H:mlhg_result(msg)
    local str = ""
    for i=1,#msg.roller do
        if i % 3 == 0 then
            str=str .. msg.roller[i] .. '\r\n'
        else
            str=str .. msg.roller[i] .. '\t'
        end
	end
	log:info("\r\n%s",str)
    str = ""
    for i=1,#msg.roller_la do
        if i % 3 == 0 then
            str=str .. msg.roller_la[i] .. '\r\n'
        else
            str=str .. msg.roller_la[i] .. '\t'
        end
	end
	log:info("\r\n%s",str)
    log:debug('普通中奖金额：%d, 辣池中奖：%d',msg.gold,msg.jackpot)
	skynet.sleep(200)
	client.push(self,'mlhg_play',{})
end
