local skynet = require "skynet"
local sharedata = require "skynet.sharedata"
local errcode = require "enum.errcode"
local log = require "log"

local _room = require "game.ddz.room"
-- local _blood = require "game.ddz.blood"

local _H = require "handler"
local _M = require "game.public"

-- 所有房间
local rooms = {}
-- 所有玩家
local players = {}

local ddz_base_cfg
skynet.init(function()
    ddz_base_cfg = sharedata.query("ddz_base")
end)
----------------------------------管理模块-------------------------------------
local function create_room(config)
    local room = _room.new(config)
    rooms[config.id] = room
end

-- 100毫秒频率
function _M.timeout()
    for _,room in pairs(rooms) do
        room:timeout()
    end
end

-- 关服调用
function _M.stop()
end

-- 开服调用
function _M.init()
    for _,v in pairs(ddz_base_cfg) do
        create_room(v)
        break
    end
    -- _blood.init()
end

function _M.desk_player(rid)
    local player = players[rid]
    if not player then return end
    local room = rooms[player.roomid]
    if not room then return end
    return room:get_desk(rid), player
end

function _M.get_player(rid)
    return players[rid]
end
-----------------------------------------玩家消息处理模块----------------------------------------
function _H.enter(args, ply)
    if not args.roomid then
        return errcode.ddz_roomid_err
    end
    local player
    local first
    if players[ply.rid] then
        player = players[ply.rid]
        -- 重连处理
        player.fd = ply.fd
        player.gate = ply.gate
        player.agent = ply.agent
    else
        player = ply
        first = true
    end
    log("%s enter ddz", player.rname)
    local room = rooms[args.roomid]
    if not room then
        return errcode.ddz_roomid_err
    end
    local err = room:enter(player, args, first)
    if not err then
        return errcode.ddz_roomid_enter_err
    end
    log("%s enter ddz room[%d]", player.rname, player.roomid)
    players[player.rid] = player

    return errcode.success
end

function _H.flash(rid)
    local player = players[rid]
    if not player then
        return
    end
    -- local desk,_ = _M.desk_player(rid)
    -- desk:flash(rid)
    log("%s 暂离 ddz", player.rname)
    player.fd = -1
end

function _H.leave(rid)
    local ret = true
    local data = nil
    local player = players[rid]
    if player then
        local room = rooms[player.roomid]
        if room then
            ret,data = room:leave(player)
        end
    end
    if ret then
        players[rid] = nil
    end
    return ret,data
end

function _H.dataSyncToMap(rid, data)
    local _, ply = _M.desk_player(rid)
    if ply then
        ply.data = data
    end
end

-- 叫地主
function _H.ddz_call(rid, args)
    local desk,_ = _M.desk_player(rid)
    if not desk then
        return errcode.ddz_desk_err
    end
    local err = desk:ddz_call(rid, args)
    return {e = err}
end

-- 加倍
function _H.ddz_multiple(rid, args)
    local desk,_ = _M.desk_player(rid)
    if not desk then
        return errcode.ddz_desk_err
    end
    local err = desk:ddz_multiple(rid, args)
    return {e = err}
end

-- 出牌
function _H.ddz_throw(rid, args)
    local desk,_ = _M.desk_player(rid)
    if not desk then
        return errcode.ddz_desk_err
    end
    local err = desk:ddz_throw(rid, args)
    return {e = err}
end

-- 下一局
function _H.ddz_more(rid)
    local player = players[rid]
    if not player then
        return {e = errcode.player_not_in_game}
    end
    local room = rooms[player.roomid]
    if not room then
        return {e = errcode.player_not_in_desk}
    end
    local ret = room:leave(player)
    if not ret then
        return {e = errcode.player_leave_desk}
    end
    if not room:enter(player) then
        return {e = errcode.player_enter_desk}
    end
    return {e = errcode.success}
end

return _M