local util = require "util"
local log = require "log"
local errcode = require "enum.errcode"
-- 通用基类
local _M = {}


-- 通用消息处理
local _H = require "handler"

function _H.changeGold(rid, gold)
    if not _M.get_player then
        return false
    end
    local ply = _M.get_player(rid)
    if not ply then
        return false
    end

    ply.gold = ply.gold + gold
    if ply.gold < 0 then
        ply.gold = 0
    end
    return true, ply.gold
end

-----------------------------------------转发客户端消息----------------------------------------
-- 表情处理
function _H.emote_game(rid, msg)
    if not _M.emote then
        return {e = errcode.emote_error}
    end
    if not _M.emote(rid, msg.id, msg.tid) then
        return {e = errcode.emote_error}
    end
    return {e = errcode.success}
end

return _M