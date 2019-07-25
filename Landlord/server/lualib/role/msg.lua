local skynet=require "skynet"
local sharedata=require "skynet.sharedata"
local client=require "client"
local log = require "log"
local util = require "util"

local errcode = require "enum.errcode"

local emailmgr
local manager
skynet.init(function()
	emailmgr = skynet.uniqueservice("world/emailmgr")
	manager = skynet.uniqueservice("world/manager")
end)

local _RH = require "role.handler"
----------------------------------客户端消息----------------------------------------
local _CH=client.handler()

function _CH:ping(msg)
	return {}
end

-- 邮件操作
function _CH:email_opt(msg)
	local emailid = msg.id
	local e = errcode.email_err
	if msg.opt == 1 then		-- 读标记
		local ret,id = skynet.call(emailmgr, 'lua', 'email_read', self.rid, emailid)
		if ret == 0 then
			client.push(self, "player_email_update", {ids={id},flag=1})
		end
		e = ret
	elseif msg.opt == 2 then	-- 单取附件
		local ret,id,gold = skynet.call(emailmgr, 'lua', 'email_reward', self.rid, emailid)
		if ret == 0 then
			client.push(self, "player_email_update", {ids={id},flag=2})
			_RH.changeGold(self, gold, 'email')
		end
		e = ret
	elseif msg.opt == 3 then	-- 删除指定
		local ret,id = skynet.call(emailmgr, 'lua', 'delete_id', self.rid, emailid)
		if ret == 0 then
			client.push(self, "player_email_del", {ids={id}})
		end
		e = ret
	elseif msg.opt == 4 then	-- 获取所有附件
		local ret,ids,gold = skynet.call(emailmgr, 'lua', 'all_rewards', self.rid)
		if ret == 0 then
			client.push(self, "player_email_update", {ids=ids,flag=2})
			_RH.changeGold(self, gold, 'email')
		end
		e = ret
	elseif msg.opt == 5 then	-- 删除所有已读和已领取
		local ret,ids = skynet.call(emailmgr, 'lua', 'delete_reads', self.rid)
		if ret == 0 then
			client.push(self, "player_email_del", {ids=ids})
		end
		e = ret
	else
		log:error("error email_opt=%d", msg.opt)
	end
	return {e=e}
end

----------------------------------内部到agent消息----------------------------------------
function _RH.send_email(self,email)
	if not email.createtime then
		email.createtime = skynet.time()
	end
	if not email.flag then
		email.flag = 0
	end
	client.push(self, "player_email_add", {info=email})
end

return _RH
