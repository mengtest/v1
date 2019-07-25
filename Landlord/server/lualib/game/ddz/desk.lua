local skynet = require "skynet"
local sharedata=require "skynet.sharedata"
local errcode = require "enum.errcode"
local client = require "client"
local log = require "log"
local util = require "util"
local yuncheng = require "yuncheng"
local const = require "game.ddz.const"

local _poker = require "game.poker"
local _enum = require "game.ddz.enum"
-- local _blood = require "game.ddz.blood"

local _M = {}

local isdebug = true

-- local ddz_misc_cfg = nil
skynet.init(function ()
    -- ddz_misc_cfg = sharedata.query("ddz_misc")
end)

function _M.new(id, roomid, cfg)
    return setmetatable({
        id = id,            -- deskid
        roomid = roomid,    -- roomid
        cfg = cfg,
        cards = nil,        -- 桌子牌
        ai_type = nil,      -- 血池状态
        player = {},        -- {[rid] = {robot=1/0(1为机器人),rid=,deskpos=,hand=,show=,multiple=,thrownum=出了几次牌,throwcards=出的牌,},...}
        common = {
            callinfo = {
                max = 0,
                rid = nil,
            },
            history = {
                call = {},
                multiple = {},
                throw = {},
            },
            bombtimes = 0,      -- 炸弹次数
            buttomcards = {},   -- 底牌
            wincards = nil,     -- 上家出的牌 {idx=,cards=,rid=,deskpos=,}
            recordleft = {},    -- 记录场上 王 2 a k 四张牌的剩余张数
            throwtimes = 0,      -- 一轮游戏中要不起次数
            userdata = yuncheng.new(0),
        },
        num = 0,            -- 玩家数
        masterpos = 0,      -- 地主桌子pos位置
        oppos = {},         -- 一轮的操作顺序，逆时针序从master开始 {rid=,deskpos=,}
        curidx = 1,         -- 当前操作位置
        pos = {},           -- 以我为始 逆时针3个位置 1-3
        -- pos = {
        --     [deskpos] = {  player对象
        --         fd=,
        --         agent=,
        --         ...
        --     },
        -- }
        status = {s = _enum.GameStatus.MATCH, t = 0},
        waitmask = 0,
    },{__index=_M}
)
end

local function broadcast(self, t, d, except)
    for _, player in ipairs(self.pos) do
        if except ~= player.rid then
            client.push(player, t, d)
        end
    end
end

local function show_game_status(self)
    if isdebug then
        log:info("game status %s", _enum.GameStatusName[self.status.s])
        if self.status.s == _enum.GameStatus.END then
            log("\n\n")
        end
    end
end

local function send_status(self, player)
    local left = (self.status.t - skynet.now()) * 10
    local s = self.status.s
    if s == _enum.GameStatus.PLAY or s == _enum.GameStatus.END then
        left = -1
    end
    local pack = {
        status = s,
        left = left,
        mask = self.waitmask,
    }
    if not player then
        broadcast(self, "ddz_status", pack)
    else
        client.push(player, "ddz_status", pack)
    end
end

-- 更新桌子状态及倒计时
function _M.update_status_timeout(self, mask, status, new)
    self.status.s = status
    self.status.t = new + skynet.now()
    self.waitmask = mask
    send_status(self)
    show_game_status(self)
end

local function sync_players(self, player)
    local msg = {}
    for i, _player in ipairs(self.pos) do
        table.insert(msg,{
            rid = _player.rid,
            rname = _player.rname,
            icon = _player.icon,
            gold = _player.gold,
            pos = i,
        })
    end
    if not player then
        broadcast(self, "ddz_players", {players = msg})
    else
        client.push(player, "ddz_players", {players = msg})
    end
end

local function gen_circle(self)
    self.oppos = {}
    for i=self.masterpos,self.num do
        table.insert(self.oppos, {rid = self.pos[i].rid, deskpos = i})
    end
    for i=1,self.masterpos-1 do
        table.insert(self.oppos, {rid = self.pos[i].rid, deskpos = i})
    end
end

local function get_deskpos_by_curidx(self)
    return self.oppos[self.curidx].deskpos
end

local function get_rid_by_curidx(self)
    return self.oppos[self.curidx].rid
end

local function get_mask_by_curidx(self)
    return 1 << get_deskpos_by_curidx(self)
end

local function is_landlord_by_deskpos(self, deskpos)
    if self.masterpos == deskpos then
        return true
    end
    return false
end

local function get_mask_by_farmer(self)
    local mask = 1
    for pos=1,const.MAX_PLAYER do
        if not is_landlord_by_deskpos(self, pos) then
            mask = mask << pos
        end
    end
    return mask
end

local function get_deskpos_by_rid(self, rid)
    return self.player[rid].deskpos
end

local function is_landlord_by_rid(self, rid)
    local deskpos = get_deskpos_by_rid(self, rid)
    if is_landlord_by_deskpos(self, deskpos) then
        return true
    end
    return false
end

local function get_landlord_rid(self)
    return self.pos[self.masterpos].rid
end

local function get_max_call_score(self)
    local deskpos = nil
    local rid = self.common.callinfo.rid
    if rid then
        deskpos = get_deskpos_by_rid(self, rid)
    end
    return self.common.callinfo.max, deskpos
end

local function is_turn_me(self, rid)
    if rid == get_rid_by_curidx(self) then
        return true
    end
    return false
end

-- 更新玩家的手牌
local function refresh_user_cards(self, rid)
    local player = self.player[rid]
    self.common.userdata:setHandCards(player.deskpos, player.hand)
end

local function landlord_stuff(self)
    local rid = get_landlord_rid(self)
    -- 补底牌
    local player = self.player[rid]
    local hand = player.hand
    util.array_combine_ref1(hand, self.common.buttomcards)
    player.hand = self.common.userdata:sortMyCards(hand)
    refresh_user_cards(self, rid)
    broadcast(self, "ddz_poker", {list = {{rid = rid, hand = self.common.buttomcards, landlord = 1}}})
end

local function call_get_next_pos(self)
    local max, deskpos = get_max_call_score(self)
    local callscores = self.cfg.callscores
    if max >= callscores[#callscores] then
        -- 达到最大叫分
        -- 直接下阶段 加倍
        self.masterpos = deskpos
        landlord_stuff(self)
        self.curidx = 1
        gen_circle(self)
        local mask = get_mask_by_farmer(self)
        _M.update_status_timeout(self, mask, _enum.GameStatus.MULTIPLE, self.cfg.multipletime)
        return
    end
    if self.curidx >= #self.oppos then
        if max == 0 then
            -- 无人叫地主重新开始游戏
            _M.reset(self)
            log:info("ddz nobody call, restart game")
            _M.update_status_timeout(self, 0, _enum.GameStatus.DEAL, self.cfg.dealtime)
            return
        end
        -- 下阶段 加倍
        self.masterpos = deskpos
        landlord_stuff(self)
        self.curidx = 1
        gen_circle(self)
        local mask = get_mask_by_farmer(self)
        _M.update_status_timeout(self, mask, _enum.GameStatus.MULTIPLE, self.cfg.multipletime)
        return
    end
    self.curidx = self.curidx + 1
    local mask = get_mask_by_curidx(self)
    _M.update_status_timeout(self, mask, _enum.GameStatus.CALL, self.cfg.calltime)
end

local function get_throwtime(self)
    local idx = 1
    local time = self.common.throwtimes
    local throwtime = self.cfg.throwtime
    local len = #throwtime
    if time >= 1 then
        idx = (time + 1 > len) and len or (time + 1)
    end
    return throwtime[idx]
end

local function throw_get_next_pos(self)
    if self.curidx >= #self.oppos then
        self.curidx = 1
    else
        self.curidx = self.curidx + 1
    end
    local precards = self.common.wincards
    -- 轮过一轮还是自己最大
    if precards and precards.idx == self.curidx then
        self.common.wincards = nil
        -- 重置pass次数
        self.common.throwtimes = 0
        --
        for i=#self.common.history.throw,1,-1 do
            table.remove(self.common.history.throw, i)
        end
    end
    local mask = get_mask_by_curidx(self)
    _M.update_status_timeout(self, mask, _enum.GameStatus.THROW, get_throwtime(self))
end

-- 春天
local function spring_multiple(self)
    for _,v in pairs(self.player) do
        if v.thrownum > 0 and not is_landlord_by_deskpos(self, v.deskpos) then
            return 1
        end
    end
    return 2
end

-- 反春
local function anti_spring_multiple(self)
    for _,v in pairs(self.player) do
        if v.thrownum == 1 and is_landlord_by_deskpos(self, v.deskpos) then
            return 2
        end
    end
    return 1
end

local function get_ply_by_rid(self, rid)
    local deskpos = get_deskpos_by_rid(self, rid)
    return self.pos[deskpos]
end

local function deal_record_left(self, cards)
    for _,v in ipairs(cards) do
        local val = const.getCardValue(v)
        if self.common.recordleft[val] then
            self.common.recordleft[val] = self.common.recordleft[val] - 1
        end
    end
end

local function sync_record_left(self)
    local pack = {}
    for k,v in pairs(self.common.recordleft) do
        table.insert(pack, {value = k, left = v})
    end
    broadcast(self, "ddz_record_left", {record_left = pack})
end

local function sync_bomb_info(self, player)
    local bomb = 1 << self.common.bombtimes
    if not player then
        broadcast(self, "ddz_bomb_info", {bomb = bomb})
    else
        client.push(player, "ddz_bomb_info", {bomb = bomb})
    end
end

-- 结算
function _M.win(self, rid)
    local pack = {}

    -- 炸弹
    local multiple = 1 << self.common.bombtimes
    local call = self.common.callinfo.max
    local base = self.cfg.betbase * call

    local mul = {}
    mul.bomb = multiple
    mul.call = call
    if is_landlord_by_rid(self, rid) then
        log:info("%s 地主赢", rid)
        -- 地主赢
        -- 春天
        local spring = spring_multiple(self)
        mul.spring = spring
        multiple = multiple * spring
        base = base * multiple
        local sum = 0
        for _,v in pairs(self.player) do
            -- 农民输
            if v.rid ~= rid then
                local num = base * v.multiple
                local ply = get_ply_by_rid(self, v.rid)
                local gold = 0 - num
                ply.gold = ply.gold + gold
                if ply.agent > 0 then
                    -- 同步agent
                    skynet.call(ply.agent, "lua", "changeGold", ply.rid, gold, "ddz_play")
                end
                sum = sum + num
                log:info("农民 %s(%s) 输 %s", ply.rname, ply.rid, num)

                local tmp = {
                    rid = ply.rid,
                    rname = ply.rname,
                    betbase = self.cfg.betbase,
                    gold = gold,
                    multiple = util.copy(mul),
                }
                tmp.multiple.multiple = v.multiple
                table.insert(pack, tmp)
            end
        end

        -- 地主赢
        if sum > 0 then
            sum = math.floor(sum * ( 1 - self.cfg.taxratio / 100))
            local ply = get_ply_by_rid(self, rid)
            ply.gold = ply.gold + sum
            if ply.agent > 0 then
                -- 同步agent
                skynet.call(ply.agent, "lua", "changeGold", ply.rid, sum, "ddz_play")
            end
            log:info("地主 %s(%s) 赢 %s", ply.rname, ply.rid, sum)
            local tmp = {
                rid = ply.rid,
                rname = ply.rname,
                betbase = self.cfg.betbase,
                gold = sum,
                multiple = util.copy(mul),
            }
            tmp.multiple.multiple = 1
            table.insert(pack, tmp)
        end
    else
        log:info("农民赢")
        -- 农民赢
        -- 反春
        local antisprint = anti_spring_multiple(self)
        mul.antisprint = antisprint
        multiple = multiple * antisprint
        base = base * multiple
        local sum = 0
        for _,v in pairs(self.player) do
            if not is_landlord_by_rid(self, v.rid) then
                -- 农民赢
                local num = base * v.multiple
                num = math.floor(num * ( 1 - self.cfg.taxratio / 100))
                local ply = get_ply_by_rid(self, v.rid)
                ply.gold = ply.gold + num
                if ply.agent > 0 then
                    -- 同步agent
                    skynet.call(ply.agent, "lua", "changeGold", ply.rid, num, "ddz_play")
                end
                sum = sum + num
                log:info("农民 %s(%s) 赢 %s", ply.rname, ply.rid, num)

                local tmp = {
                    rid = ply.rid,
                    rname = ply.rname,
                    betbase = self.cfg.betbase,
                    gold = num,
                    multiple = util.copy(mul),
                }
                tmp.multiple.multiple = v.multiple
                table.insert(pack, tmp)
            end
        end

        -- 地主输
        local master = self.pos[self.masterpos]
        log:info("地主 %s(%s) 输 %s", master.rname, master.rid, sum)
        sum = 0 - sum
        master.gold = master.gold + sum
        if master.agent > 0 then
            -- 同步agent
            skynet.call(master.agent, "lua", "changeGold", master.rid, sum, "ddz_play")
        end
        local tmp = {
            rid = master.rid,
            rname = master.rname,
            betbase = self.cfg.betbase,
            gold = sum,
            multiple = util.copy(mul),
        }
        tmp.multiple.multiple = 1
        table.insert(pack, tmp)
    end
    local pack_ = {}
    for _,v in pairs(self.player) do
        table.insert(pack_, {rid = v.rid, hand = v.hand})
    end
    broadcast(self, "ddz_poker", {list = pack_})
    broadcast(self, "ddz_win", {ddz_win_info = pack})
end

-- 游戏开始
function _M.start(self)
    log:info("ddz game start")
    -- 能否开始
    _M.update_status_timeout(self, 0, _enum.GameStatus.MATCH, 20)  -- 匹配成功后，等待200毫秒
end

-- 匹配
local function to_match(self)
    self.num = #self.pos
    log:info("ddz num %s", self.num)
    for i=1, self.num do
        local j = math.random(1, self.num)
        self.pos[i],self.pos[j] = self.pos[j],self.pos[i]
    end
    for i=1, self.num do
        local obj = self.pos[i]
        self.player[obj.rid] = {robot=(obj.agent == 0 and 1 or 0),rid=obj.rid,deskpos=i,show=0,thrownum=0}
    end
    sync_players(self)

    _M.update_status_timeout(self, 0, _enum.GameStatus.DEAL, self.cfg.dealtime)
end

-- 发牌
local function to_deal(self)
    _M.create_cards(self)
    local userdata = self.common.userdata

    -- 血池状态
    -- self.ai_type = _blood.get(self.roomid)
    -- log:info("当前血池状态 %s", _enum.AiStatusName[self.ai_type])

    -- if self.robot then
    --     -- todo
    --     print("robot")
    -- else
        -- 洗牌
        local cards = {}
        for i=1,const.CARD_NUM do
            table.insert(cards, i)
        end
        util.shuffle(cards)
        -- 全是玩家
        local idx = 1
        for pos=1,const.MAX_PLAYER do
            local ply = self.pos[pos]
            local rid = ply.rid
            local player = self.player[rid]
            local hand = {}
            for _=1,const.PER_PLAYER_CARD_NUM do
                table.insert(hand, cards[idx])
                idx = idx + 1
            end
            hand = userdata:sortMyCards(hand)
            userdata:setHandCards(pos, hand)
            player.hand = hand
            log:error("%s(%s) cards", ply.rname, rid)
            for i=1,const.PER_PLAYER_CARD_NUM do
                log:info("value %s", hand[i])
            end
            client.push(ply, "ddz_poker", {list = {{rid = rid, hand = hand}}})
        end
        -- 三张底牌
        for _=1,const.BOTTOM_CARD_NUM  do
            table.insert(self.common.buttomcards, cards[idx])
            idx = idx + 1
        end
    -- end

    -- 记牌器
    self.common.recordleft = {
        [const.kCard_ValueK] = 4,
        [const.kCard_ValueA] = 4,
        [const.kCard_Value2] = 4,
        [const.kCard_ValueJoker1] = 1,
        [const.kCard_ValueJoker2] = 1,
    }
    sync_record_left(self)

    -- 随机一个叫地主的位置
    local rand = math.random(1, self.num)
    self.masterpos = rand
    gen_circle(self)
    self.curidx = 1

    local mask = get_mask_by_curidx(self)
    _M.update_status_timeout(self, mask, _enum.GameStatus.CALL, self.cfg.calltime)
end

-- 叫地主
local function to_call(self)
    -- 默认不叫地主
    local rid = get_rid_by_curidx(self)
    local score = 0

    -- just4test
    local rand = math.random(0, 3)
    local max = get_max_call_score(self)
    if rand > max or rand > 0 then
        score = rand
    end
    _M.ddz_call(self, rid, {score = score})
end

-- 加倍
local function to_multiple(self)
    -- 默认不加倍
    for rid,v in pairs(self.player) do
        if not is_landlord_by_deskpos(self, v.deskpos) and not v.multiple then
            local multiple = self.cfg.farmermultiples[1]
            multiple = (multiple == 0 and 1 or multiple)
            v.multiple = multiple
            local pack = {rid = rid, multiple = multiple}
            broadcast(self, "ddz_multiple_info", {ddz_info = {pack}}, rid)
            table.insert(self.common.history.multiple, pack)
        end
    end
    -- 出牌阶段
    self.curidx = 1
    local mask = get_mask_by_curidx(self)
    _M.update_status_timeout(self, mask, _enum.GameStatus.THROW, get_throwtime(self))
end

-- 出牌
local function to_throw(self)
    local rid = get_rid_by_curidx(self)

    -- 服务器托管
    local userdata = self.common.userdata
    userdata:updateSeats(self.masterpos, get_deskpos_by_curidx(self))

    local card
    local wincards = self.common.wincards
    if not wincards then
        card = userdata:robotFirstPlay()
    else
        card = userdata:robotFollowCards(wincards.deskpos,wincards.cards)
    end

    local player = self.player[rid]
    local ok, cards = const.getSelCards(player.hand, const.getCardItSelf, card, const.getCardItSelf)
    if not ok then
        print ("can't find selected cards in first play")
    end
    _M.ddz_throw(self, rid, {cards = cards})
end

-- 结束
local function to_end(self)
    _M.update_status_timeout(self, 0, _enum.GameStatus.END, -1)

    -- 删除机器人
    for i, obj in ipairs(self.pos) do
        if obj.agent == 0 then
            self.player[obj.rid] = nil
            self.pos[i] = {}
            self.num = self.num - 1
        end
    end
end

-- 超时处理
function _M.timeout_handler(self)
    if self.status.s == _enum.GameStatus.MATCH then
        to_match(self)
    elseif self.status.s == _enum.GameStatus.DEAL then
        to_deal(self)
    elseif self.status.s == _enum.GameStatus.CALL then
        to_call(self)
    elseif self.status.s == _enum.GameStatus.MULTIPLE then
        to_multiple(self)
    elseif self.status.s == _enum.GameStatus.THROW then
        to_throw(self)
    elseif self.status.s == _enum.GameStatus.WIN then
        to_end(self)
    end
end

-- 创建桌牌
function _M.create_cards(self)
    self.cards = _poker.create(1, true)
end

function _M.robot(self)
    if self.num < 3 then
        -- add robot
    end
end

function _M.timeout(self)
    if skynet.now() >= self.status.t then
        _M.timeout_handler(self)
    end
end
-----------------------------------------------------------------------
-- client msg cope with
-- 叫地主
function _M.ddz_call(self, rid, args)
    if self.status.s ~= _enum.GameStatus.CALL then
        return errcode.ddz_call_not_in_phase
    end
    if not is_turn_me(self, rid) then
        return errcode.ddz_not_turn_me
    end
    local score = args.score
    if not score then
        return errcode.ddz_call_score_err
    end
    local callscores = self.cfg.callscores
    if not util.find(callscores, score) then
        return errcode.ddz_call_score_err
    end

    if score >= 0 and score <= self.common.callinfo.max then
        return errcode.ddz_call_less_last_score
    end
    self.player[rid].call = score
    self.common.callinfo.max = score
    self.common.callinfo.rid = rid
    local pack = {rid = rid, score = score}
    broadcast(self, "ddz_call_info", {ddz_info = {pack}}, rid)
    table.insert(self.common.history.call, pack)
    call_get_next_pos(self)
    return errcode.success
end

-- 加倍
function _M.ddz_multiple(self, rid, args)
    if self.status.s ~= _enum.GameStatus.MULTIPLE then
        return errcode.ddz_multiple_not_in_phase
    end
    if is_landlord_by_rid(self, rid) then
        return errcode.ddz_landlord_can_not_multiple
    end
    local multiple = args.multiple
    if not multiple then
        return errcode.ddz_multiple_multiple_err
    end
    if not util.find(self.cfg.farmermultiples, multiple) then
        return errcode.ddz_multiple_multiple_err
    end
    if self.player[rid].multiple then
        return errcode.ddz_multiple_already
    end
    multiple = (multiple == 0 and 1 or multiple)
    self.player[rid].multiple = multiple

    local pack = {rid = rid, multiple = multiple}
    broadcast(self, "ddz_multiple_info", {ddz_info = {pack}}, rid)
    table.insert(self.common.history.multiple, pack)

    local enter_throw = true
    for _,v in pairs(self.player) do
        if not is_landlord_by_deskpos(self, v.deskpos) and not v.multiple then
            enter_throw = false
            break
        end
    end
    if enter_throw then
        -- 出牌阶段
        self.curidx = 1
        local mask = get_mask_by_curidx(self)
        _M.update_status_timeout(self, mask, _enum.GameStatus.THROW, get_throwtime(self))
    end
    return errcode.success
end

-- 出牌
function _M.ddz_throw(self, rid, args)
    if self.status.s ~= _enum.GameStatus.THROW then
        return errcode.ddz_throw_not_in_phase
    end
    if not is_turn_me(self, rid) then
        return errcode.ddz_not_turn_me
    end

    -- 出牌
    local cards = args.cards
    local player = self.player[rid]
    if not cards or not next(cards) then
        -- pass处理
        log:info("rid %s deskpos %s pass", rid, player.deskpos)
        player.throwcards = {}
        local pack = {rid = rid, cards = {}}
        broadcast(self, "ddz_throw_info", {ddz_info = {pack}}, rid)
        table.insert(self.common.history.throw, pack)
        self.common.throwtimes = self.common.throwtimes + 1
        throw_get_next_pos(self)
        return errcode.success
    end

    local testcards = util.copy(player.hand)
    local ok = const.removeSubset(testcards, cards)
    if not ok then
        return errcode.ddz_throw_not_your_cards
    end
    local userdata = self.common.userdata
    userdata:updateSeats(self.masterpos, get_deskpos_by_curidx(self))
    local prevcards = self.common.wincards and self.common.wincards.cards or nil
    local ret, sorted = userdata:canPlayCards(cards, prevcards)
    if ret ~= 0  then
        -- 不能出牌
        return const.errcode_map[ret]
    end

    deal_record_left(self, cards)
    sync_record_left(self)

    local cardinfo = {
        idx = self.curidx,
        rid = rid,
        cards = util.copy(sorted),
        deskpos = player.deskpos,
    }
    self.common.wincards = cardinfo
    player.throwcards = cardinfo.cards
    pdump(cardinfo.cards, "throwcards rid "..rid.. " deskpos "..player.deskpos)
    player.thrownum = player.thrownum + 1
    player.hand = testcards
    local pack = {rid = rid, cards = cardinfo.cards}
    broadcast(self, "ddz_throw_info", {ddz_info = {pack}}, rid)
    table.insert(self.common.history.throw, pack)

    --
    refresh_user_cards(self, rid)

    -- 处理炸弹
    local node = userdata:getNodeType(cardinfo.cards)
    if const.isRocket(node) or const.isBomb(node) then
        self.common.bombtimes = self.common.bombtimes + 1
        sync_bomb_info(self)
    end

    -- 出牌每次检查是否结束
    local mask = get_mask_by_curidx(self)
    if #player.hand <= 0 then
        _M.win(self, rid)
        _M.update_status_timeout(self, mask, _enum.GameStatus.WIN, self.cfg.settletime)
    else
        throw_get_next_pos(self)
    end
    return errcode.success
end

-----------------------------------------------------------------------
function _M.enter(self, player)
    table.insert(self.pos, player)
    player.deskid = self.id
end

function _M.leave(self, rid)
    if self.status.s ~= _enum.GameStatus.END then return false end
    local d = self.player[rid]
    if not d then return false end
    log:info("desk : leave rid(%s)", rid)
    local ply = self.pos[d.deskpos]
    self.player.hand = nil
    self.player[rid] = nil
    self.pos[d.deskpos] = {}
    self.num = self.num - 1
    return true,ply.data
end

function _M.back(self, player)
    if player.agent > 0 then
        log:info("%s(%s) back", player.rname, player.rid)
    end
    local rid = player.rid
    send_status(self, player)
    sync_players(self, player)

    local s = self.status.s
    -- 结算阶段
    if s >= _enum.GameStatus.WIN and s < _enum.GameStatus.END then
        -- 开牌
        local pack = {}
        for _,v in pairs(self.player) do
            table.insert(pack, {rid = v.rid, hand = v.hand})
        end
        client.push(player, "ddz_poker", {list = pack})
        -- 结算结果
        client.push(player, "ddz_win", {})
    end

    -- 发牌后
    if s >= _enum.GameStatus.DEAL and s <= _enum.GameStatus.WIN then
        -- 自己的牌
        client.push(player, "ddz_poker", {list = {{rid = rid, hand = self.player[rid].hand}}})
        sync_bomb_info(self, player)
        sync_record_left(self)
    end

    if s >= _enum.GameStatus.CALL and s < _enum.GameStatus.MULTIPLE then
        -- 历史叫地主分数
        client.push(player, "ddz_call_info", {ddz_info = self.common.history.call})
    end

    if s >= _enum.GameStatus.MULTIPLE and s < _enum.GameStatus.END then
        -- 确定地主后 地主底牌
        client.push(player, "ddz_poker", {list = {{rid = get_landlord_rid(self), hand = self.common.buttomcards, landlord = 1}}})
    end

    if s >= _enum.GameStatus.MULTIPLE and s < _enum.GameStatus.THROW then
        -- 历史加倍
        client.push(player, "ddz_multiple_info", {ddz_info = self.common.history.multiple})
    end

    if s >= _enum.GameStatus.THROW and s < _enum.GameStatus.WIN then
        -- 历史出牌
        client.push(player, "ddz_throw_info", {ddz_info = self.common.history.throw})
    end

    client.push(player, "game_revert", {})
end

function _M.delete(self)
    log:debug('delete ddz desk %d', self.id)
    self.cards = nil
    self.cfg = nil
    self.pos = nil
    self.player = nil
    self.oppos = nil
    if self.common.userdata then
        self.common.userdata:release()
    end
    self.common = nil
    self.status = nil
end

function _M.reset(self)
    self.cards = nil
    for _,v in pairs(self.player) do
        v.thrownum = 0
        v.show = 0
        v.call = nil
        v.multiple = nil
        v.hand = nil
    end
    self.common.callinfo.max = 0
    self.common.callinfo.rid = nil
    self.common.buttomcards = {}
    self.common.bombtimes = 0
    self.common.wincards = nil
    self.masterpos = 0
    self.oppos = {}
    self.curidx = 1
    self.status.s = _enum.GameStatus.MATCH
    self.status.t = 0
    self.waitmask = 0
end

function _M.is_over(self)
    return self.status.s == _enum.GameStatus.END
end

function _M.destroy(self)
    return _M.is_over(self) and self.num == 0
end

return _M