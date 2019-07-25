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

function H:yxdc_init(msg)
	log:debug("夜袭貂蝉： 基础分 %d", msg.curr)
	for i,v in ipairs(msg.level) do
		log:debug("夜袭貂蝉低分档次：%d档 %d分", i, v)
	end

	local idx = math.random( 1, #msg.level)
	client.push(self,'yxdc_set',{idx=idx})
	client.push(self,'yxdc_play',{})

end

function H:yxdc_result(msg)
    local str = ""
    for i=1,#msg.roller do
        if i % 3 == 0 then
            str=str .. msg.roller[i] .. '\r\n'
        else
            str=str .. msg.roller[i] .. '\t'
        end
	end
	log:info("\r\n%s",str)
    pdump(msg)
	skynet.sleep(200)
	if msg.chose_type ==1 then
		local rd = math.random(1,3)
		client.push(self,'yxdc_setType',{idx=rd})
		skynet.sleep(200)
		client.push(self,'yxdc_play',{})
	else
		client.push(self,'yxdc_play',{})
	end
end
