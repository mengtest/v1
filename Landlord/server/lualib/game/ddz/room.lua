local skynet = require "skynet"
local client = require "client"
local util = require "util"
local log = require "log"

local _desk = require "game.ddz.desk"

local _M = {}

local MAX_PLAYER = 3

function _M.new(cfg)
    return setmetatable({
        id = cfg.id,
        cfg = cfg,
        idx = 0,
        desks = {},     -- 正在玩的桌子
        matchs = {},    -- 正在匹配的玩家
        players = {},   -- 进入房间的所有玩家
    },{__index=_M}
)
end

function _M.enter(self, player, first)
    if self.cfg.needgold > player.gold then
        return false
    end
    if player.roomid then
        if player.deskid then
            local desk = self.desks[player.deskid]
            if desk:is_over() then
                local ret = desk:leave(player.rid)
                if not ret then
                    return false
                end
            else
                if first then
                    client.push(player, 'game_entered', {status=0,gameid='ddz',roomid=self.id})
                end
                desk:back(player)
                return true
            end
        else
            return false
        end
    end
    player.roomid = self.id
    self.matchs[player.rid] = skynet.now()
    self.players[player.rid] = player
    if first then
        client.push(player, 'game_entered', {status=1,gameid='ddz',roomid=self.id})
    end
    return true
end

function _M.leave(self, player)
    local ret = true
    local data = nil
    if player.deskid then
        local desk = self.desks[player.deskid]
        if desk then
            ret,data = desk:leave(player.rid)
        end
    end
    if ret then
        self.players[player.rid] = nil
        self.matchs[player.rid] = nil
        player.roomid = nil
    end
    return ret,data
end

function _M.get_desk(self, rid)
    local desk = nil
    local player = self.players[rid]
    if player then
        if player.deskid then
            desk = self.desks[player.deskid]
        end
    end
    return desk
end

-- 匹配
local function match(self)
    local now = skynet.now()
    local bucket = {}
    local begin = now
    local dels = {}
    for rid, time in pairs(self.matchs) do
        local player = self.players[rid]
        if player then
            if #bucket < MAX_PLAYER then
                table.insert(bucket, player)
                if time < begin then
                    begin = time
                end
            end
        else
            table.insert(dels, rid)
        end
    end
    for _,rid in ipairs(dels) do
        self.matchs[rid] = nil
    end
    if (#bucket == MAX_PLAYER) or (now - begin > 150) then
        self.idx = self.idx + 1
        local desk = _desk.new(self.idx, self.id, self.cfg)
        -- 玩家进入
        for _, player in ipairs(bucket) do
            self.matchs[player.rid] = nil
            desk:enter(player)
        end
        -- 机器人进入
        desk:robot()
        -- 开始
        desk:start()
        self.desks[self.idx] = desk
    end
end

-- 100毫秒定时器
function _M.timeout(self)
    local dels = {}
    for id, desk in pairs(self.desks) do
        desk:timeout()
        if desk:destroy() then
            table.insert(dels, id)
        end
    end
    for _,id in ipairs(dels) do
        local desk = self.desks[id]
        desk:delete()
        self.desks[id] = nil
    end
    match(self)
end

return _M