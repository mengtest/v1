local skynet = require "skynet"
local client=require 'robot.client'
local sharedata=require "skynet.sharedata"
local util=require "util"
local log=require "log"
local H=client.handler()
local _enum = require "game.goldenflower.enum"

local goldenflower_base_cfg
skynet.init(function()
	goldenflower_base_cfg = sharedata.query("goldenflower_base")[1]
end)

local function req(self, tip, cmd, args)
	local info = client.request(self, 100, cmd, args or {})
	pdump(info, tip)
end

-- 玩家列表
function H:goldenflower_players(msg)
	self.players = {}
	for pos,v in pairs(msg.players) do
		v.pos = pos
		self.players[v.rid] = v
	end
	pdump(self.players, "goldenflower_players 玩家列表")
end

local flag
function H:goldenflower_status(msg)
	log:info("%s 剩余时间%s", _enum.GameStatusName[msg.status], msg.left)
	if  msg.status == _enum.GameStatus.MATCH then

	elseif msg.status == _enum.GameStatus.DEAL then
		--
	elseif msg.status == _enum.GameStatus.PLAY then
		-- local len = #goldenflower_base_cfg.betgrade
		-- if not self.max_betgradeidx then
		-- 	self.max_betgradeidx = 2
		-- end
		-- if not flag or self.max_betgradeidx >= len then
			local str = string.format("%s(%s) 跟注", self.rname, self.rid)
			req(self, str, "goldenflower_follow_bet", {})
		-- else
		-- 	local rand = math.random(3,len)
		-- 	if rand > self.max_betgradeidx then
		-- 		local addvalue = goldenflower_base_cfg.betgrade[rand]
		-- 		local str = string.format("%s(%s) 加注 gradeidx %s addvalue %s", self.rname, self.rid, rand, addvalue)
		-- 		req(self, str, "goldenflower_add_bet", {gradeidx = rand})
		-- 	end
		-- end
		-- flag = (not flag)

		-- local str = string.format("%s(%s) 看牌", self.rname, self.rid)
		-- req(self, str, "goldenflower_look", {})

		if self.rid ==  167856046113 then
			if self.circle >= 4 then
				-- local str = string.format("%s(%s) 跟到底", self.rname, self.rid)
				-- req(self, str, "goldenflower_follow_end", {})
				local str = string.format("%s(%s) 弃牌", self.rname, self.rid)
				req(self, str, "goldenflower_abandon", {})
			else
				-- local str = string.format("%s(%s) 跟到底", self.rname, self.rid)
				-- req(self, str, "goldenflower_follow_end", {})
			end
		else --if self.rid == 168510357537 then
			-- local str = string.format("%s(%s) 跟到底", self.rname, self.rid)
			-- req(self, str, "goldenflower_follow_end", {})
		end

		-- local rand = math.random(1,2)
		-- if rand == 1 then
		-- 	local str = string.format("%s(%s) 跟到底", self.rname, self.rid)
		-- 	req(self, str, "goldenflower_follow_end", {})
		-- end
	elseif msg.status == _enum.GameStatus.END then
		local str = string.format("%s(%s) 下一局", self.rname, self.rid)
		req(self, str, "goldenflower_more", {})
	end
end

local op = {
	compare = 1,
	compare_agree = 2,
	-- allin = 1,
	allin_agree = 2,
}

function H:goldenflower_op_time(msg)
	pdump(msg, "操作时间同步")
	local rid = msg.rid

	if op.compare then
		-- 比牌
		if string.find(self.players[rid].rname, "玩家") then
			local other_rid
			local str = string.format("%s(%s) 比牌", self.rname, self.rid)
			for _,v in ipairs(self.players) do
				if string.find(v.rname, "玩家") then
					if v.rid ~= rid then
						other_rid = v.rid
						break
					end
				end
			end
			req(self, str, "goldenflower_compare", {rid = other_rid})
		end
	elseif op.allin then
		-- 全押
		if string.find(self.players[rid].rname, "玩家") then
			local str = string.format("%s(%s) 全押", self.rname, self.rid)
			req(self, str, "goldenflower_all_in", {})
		end
	end

	if self.rid ==  167856046113 and rid == self.rid and  self.circle >= 4 then
		local str = string.format("%s(%s) 跟到底", self.rname, self.rid)
		req(self, str, "goldenflower_follow_end", {})
		str = string.format("%s(%s) 弃牌", self.rname, self.rid)
		req(self, str, "goldenflower_abandon", {})
	end
end

function H:goldenflower_op_info(msg)
	-- pdump(msg, "操作状态同步")

	local otherrid = msg.otherrid

	if op.allin_agree then
		-- 同意全押
		if msg.status == _enum.OpType.ALLIN then
			local other = self.players[otherrid]
			if self.rid == other.rid then
				local str = string.format("%s(%s) 同意全押", self.rname, self.rid)
				req(self, str, "goldenflower_all_in", {})
			end
		end
	end
end

function H:goldenflower_player_info(msg)
	-- pdump(msg, "玩家现在状态同步")
end

function H:goldenflower_circle_info(msg)
	pdump(msg, "第几轮")
	self.circle = msg.circle
	if self.circle == 2 then
		local str = string.format("%s(%s) 看牌", self.rname, self.rid)
		req(self, str, "goldenflower_look", {})
	end
end

function H:goldenflower_betgradeidx(msg)
	pdump(msg, "最大押注序号")
	self.max_betgradeidx = msg.betgradeidx
end

function H:goldenflower_poker(msg)
	pdump(msg.list, "发牌")
end

function H:goldenflower_win(msg)
	pdump(msg.result, "结算")
end