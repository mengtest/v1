local uniq = require "uniq.c"
local skynet = require "skynet"
local sharedata=require "skynet.sharedata"
local log=require "log"
local attrlib = require "attrlib"
local awardtype = require "enum.awardtype"
local format = string.format


local emailsend
local emailcfg
skynet.init(function()
	emailsend = skynet.uniqueservice("world/emailsend")
	emailcfg = sharedata.query("mail")
end)

local _M = {}
function _M.send(data)
	assert(data.receiveid)
	data.params = data.params or {}

	data.receiveid = data.receiveid
	data.theme = data.theme or ""
	data.content = format(data.content or "", table.unpack(data.params))
	data.gold = data.gold
	data.id = uniq.id(1)
	data.idx = 0

	skynet.send(emailsend, 'lua', 'send', data)
end

function _M.send_reward(receiveid, rewardid, gold, params)
	local cfg = emailcfg[rewardid]
	if not cfg then
		log:error("send email reward not find[%d]", rewardid)
	end
	local data = {}
	data.receiveid = receiveid
	data.sendid = 0
	data.sender = cfg.sender
	data.theme = cfg.mailname
	data.content = cfg.mailtext
	data.gold = gold or cfg.gold
	data.params = params

	_M.send(data)
end

return _M
