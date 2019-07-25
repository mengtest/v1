local skynet = require "skynet"
local client = require "client"
local sharedata = require "skynet.sharedata"
local log = require "log"
local util = require "util"
local cfg=require 'cfg.loader'
local setting = require "setting"

local _M = require "master.handler"

local redeem
skynet.init(function()
	redeem = skynet.uniqueservice("world/redeem")
end)

function _M.reload(args)
	log("reload config %s",args.file)
	cfg.reload(args.file)
	return true
end

function _M.setting(args)
	log("setting config %s=%s",args.key,args.value)
	setting.set(args.key,args.value)
	return true
end

function _M.createcode(args)
	log("create redeem code,name:%s only:%s num:%s gold:%s",args.num, args.name, args.only, args.gold)
	local ret = skynet.call(redeem, "lua", "create_code", tonumber(args.num), args.name, tonumber(args.only), tonumber(args.gold));
	return ret
end

function _M.notice(args)
	local chat = skynet.uniqueservice("world/chat_manager")
	if args.id then
		args.id = tonumber(args.id)
	end
	if args.time then
		args.time = tonumber(args.time)
	end
	if args.max then
		args.max = tonumber(args.max)
		if args.max < 1 then
			args.max = 1
		end
	end
	if args.per then
		args.per = tonumber(args.per)
		if args.per < 0 then
			args.per = 0
		end
	end	
	return skynet.call(chat, "lua", "gm_notice", args);
end

return _M