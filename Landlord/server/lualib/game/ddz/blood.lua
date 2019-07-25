local skynet = require "skynet"
local log = require "log"
local sharedata = require "skynet.sharedata"
local format = string.format

local _enum = require "game.ddz.enum"

local function query(proxy,...)
	local d
	if select("#",...)==1 then
		d= skynet.call(proxy,'lua','query',...)
	else
		d= skynet.call(proxy,'lua','query',format(...))
	end
	if d.errno then
		error(format("%s[%s]",d.err,table.concat({...})))
	end
	return d
end

local dbproxy
local ddz_blood
skynet.init(function()
    local dbmgr = skynet.uniqueservice('dbmgr')
    dbproxy=assert(skynet.call(dbmgr,"lua","query","DB_GAME"))

    local blood = sharedata.query("ddz_blood")
    ddz_blood = {}
    for _,v in ipairs(blood) do
        if not ddz_blood[v.roomid] then
            ddz_blood[v.roomid] = {

            }
        end
        table.insert(ddz_blood[v.roomid],v)
    end
end)

local _core = {}
local _M = {}

function _M.init()
    _core.blood = {}
    _core.current = {}
    local ret = query(dbproxy, 'select * from t_game_ddz_blood')
    for _, v in ipairs(ret) do
		local roomid = v[1]
        local blood = v[2]
        _core.blood[roomid] = {
            num = blood,
            tick = 0
        }
    end
    for roomid, _ in ipairs(ddz_blood) do
        if _core.blood[roomid] == nil then
            log('ddz blood db init,roomid=%d',roomid)
            query(dbproxy, 'insert into t_game_ddz_blood values(%d,0)', roomid)
            _core.blood[roomid] = {
                num = 0,
                tick = 0
            }
        end
        _M.current(roomid)
    end
end

function _M.current(roomid)
    local blood = ddz_blood[roomid]
    local num = _core.blood[roomid].num
    if blood ~= nil and num ~= nil then
        for _,v in ipairs(blood) do
            if num >= v.lower and num < v.upper then
                _core.current[roomid] = v
                break
            end
        end
    end
end

function _M.timeout()
    local now = skynet.now()
    for roomid,v in ipairs(_core.blood) do
        if v.tick > 0 and now - v.tick > 6000 then
            v.tick = 0
            query(dbproxy, 'update t_game_ddz_blood set blood = %d where roomid = %d', v.num, roomid)
            break
        end
    end
end

function _M.stop()
    for roomid,v in ipairs(_core.blood) do
        if v.tick > 0 then
            query(dbproxy, 'update t_game_ddz_blood set blood = %d where roomid = %d', v.num, roomid)
            break
        end
    end
end

-- win：系统赢
function _M.save(roomid, win , blood)
    if _core.blood[roomid] == nil then
        query(dbproxy, 'insert into t_game_ddz_blood values(%d,0)', roomid)
        _core.blood[roomid] = {
            num = 0,
            tick = 0
        }
    end
    local current = _core.blood[roomid].num
    local orig = current
    if win > 0 then
        current = current + blood
    else
        current = current - blood
    end
    log:error("blood change %s %s %s = %s", orig, win > 0 and "+" or "-", blood, current)
    _core.blood[roomid].num = current
    _core.blood[roomid].tick = skynet.now()
    _M.current(roomid)
end

-- return: ai逻辑
function _M.get(roomid)
    local d = _core.current[roomid]
    if d then
        log:error("blood num %s 原始血池状态 AiStatus %s", _core.blood[roomid].num, _enum.AiStatusName[d.type])
        if d.type == _enum.AiStatus.LOSER then
            if math.random(1,10000) <= d.odds then
                return _enum.AiStatus.LOSER
            else
                return _enum.AiStatus.NORMAL
            end
        elseif d.type == _enum.AiStatus.WINER then
            if math.random(1,10000) <= d.odds then
                return _enum.AiStatus.WINER
            else
                return _enum.AiStatus.NORMAL
            end
        end
    end
    return _enum.AiStatus.NORMAL
end

function _M.get_robot_num(roomid)
    local d = _core.current[roomid]
    return d.robot
end

return _M