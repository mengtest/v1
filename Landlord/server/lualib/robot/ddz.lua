local skynet = require "skynet"
local client=require 'robot.client'
local log=require "log"
local util = require "util"
local sharedata=require "skynet.sharedata"
local _enum = require "game.ddz.enum"
local H=client.handler()

skynet.init(function()

end)

local function req(self, tip, cmd, args)
	local info = client.request(self, 100, cmd, args or {})
	pdump(info, tip)
end

-- 玩家列表
function H:ddz_players(msg)
	self.players = {}
	for pos,v in pairs(msg.players) do
		v.pos = pos
		self.players[v.rid] = v
	end
	pdump(self.players, "ddz_players 玩家列表")
end

function H:ddz_status(msg)
	log:info("%s 剩余时间%s", _enum.GameStatusName[msg.status], msg.left)
	if  msg.status == _enum.GameStatus.MATCH then

	elseif msg.status == _enum.GameStatus.DEAL then
		--
	elseif msg.status == _enum.GameStatus.CALL then
	elseif msg.status == _enum.GameStatus.MULTIPLE then
	elseif msg.status == _enum.GameStatus.THROW then
	elseif msg.status == _enum.GameStatus.WIN then
	elseif msg.status == _enum.GameStatus.END then
		local str = string.format("%s(%s) 下一局", self.rname, self.rid)
		req(self, str, "ddz_more", {})
	end
end

function H:ddz_poker(msg)
	pdump(msg.list, "发牌")
end

function H:ddz_multiple_info(msg)
	pdump(msg.ddz_info, "加倍信息")
end

function H:ddz_call_info(msg)
	pdump(msg.ddz_info, "叫地主信息")
end

function H:ddz_throw_info(msg)
	pdump(msg.ddz_info, "出牌信息")
end

function H:ddz_win(msg)
	pdump(msg.ddz_win_info, "结算结果")
end

function H:ddz_record_left(msg)
	pdump(msg.record_left, "记牌器")
end

function H:ddz_bomb_info(msg)
	pdump(msg.bomb, "更新炸弹倍数")
end
