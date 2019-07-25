local util = require "util"
local log = require "log"

local _M = {}

-- CardValue: 1 = Ace, 2 - 10, 11 = Jack, 12 = Queen, 13 = King
-- CardType = {
--     DIAMOND  = 1,   -- 方块
--     CLUB  = 2,      -- 梅花
--     HEART = 3,      -- 红桃
--     SPADE  = 4,     -- 黑桃
-- },

--[[
    创建洗过的玩法牌
    count number, 几副牌
    ace   bool, A 是大牌，值为14
    joker bool, 是否有大小王
]]

function _M.create(count, ace, joker)
    local offset = ace and 1 or 0
    local poker = {pos=1}
    for i=0,count-1 do
        for j=1,52 do
            poker[i*52+j] = {
                type = math.floor((j - 1) / 13) + 1,
                value = math.fmod(j - 1, 13) + 1 + offset
            }
        end
        if joker then
            poker[i*52+53] = {type = 0, value = 1}
            poker[i*52+54] = {type = 0, value = 2}
        end
    end
    poker.total = (joker and 54 or 52) * count
    return poker
end

-- ace   bool, A 是大牌，值为14
function _M.num2card(num, ace)
    local offset = ace and 1 or 0
    if num < 53 then
        return {
            type = math.floor((num - 1) / 13) + 1,
            value = math.mod(num - 1, 13) + 1 + offset
        }
    else
        if num == 53 then
            return {type = 0, value = 1}
        else
            return {type = 0, value = 2}
        end
    end
end

-- ace   bool, A 是大牌，值为14
function _M.card2num(card, ace)
    local offset = ace and 1 or 0
    local num = 0
    if card.type > 0 then
        num = (card.type - 1 ) * 13 + card.value - offset
    else
        num = card.value == 1 and 53 or 54
    end
    return num
end

function _M.name(card)
    local name = ""
    if card.type == 0 then
        if card.value == 1 then
            return '小王'
        else
            return '大王'
        end
    else
        if card.type == 1 then
            name = '方块'
        elseif card.type == 2 then
            name = '梅花'
        elseif card.type == 3 then
            name = '红桃'
        elseif card.type == 4 then
            name = '黑桃'
        end
        if card.value == 11 then
            name = name..'J'
        elseif card.value == 12 then
            name = name..'Q'
        elseif card.value == 13 then
            name = name..'K'
        elseif card.value == 1 or card.value == 14 then
            name = name..'A'
        else
            name = name..card.value
        end
    end
    return name
end

-- 临时发牌记录
function _M.deal_temp(poker)
    poker.temp = {
        pos = poker.pos,
        idxs = {},
        revert = {}
    }
end

-- 发牌,随机
function _M.deal(poker)
    local card
    while poker.pos <= poker.total do
        local pos = poker.pos
        local idx = math.random(poker.pos, poker.total)
        card = poker[idx]
        poker[idx],poker[poker.pos] = poker[poker.pos],poker[idx]
        poker.pos = poker.pos + 1
        if card then
            if poker.temp ~= nil then
                if poker.temp.revert[idx] == nil then
                    poker.temp.revert[idx] = poker[pos]
                end
                if poker.temp.revert[pos] == nil then
                    poker.temp.revert[pos] = poker[idx]
                end
                table.insert(poker.temp.idxs, idx)
            end
            break
        end
    end
    return card
end

-- 成功后先还原再按序取牌
function _M.deal_revert_idxs(poker)
    local cards = {}
    if poker.temp ~= nil then
        -- revert
        poker.pos = poker.temp.pos
        for pos,card in pairs(poker.temp.revert) do
            poker[pos] = card
        end
        -- deal idxs
        for _,idx in ipairs(poker.temp.idxs) do
            local card = poker[idx]
            poker[idx],poker[poker.pos] = poker[poker.pos],poker[idx]
            poker.pos = poker.pos + 1
            table.insert(cards, card)
        end
    end
    poker.temp = nil
    return cards
end

-- 按序取牌
function _M.deal_idxs(poker, idxs)
    local cards = {}

    -- deal idxs
    for _,idx in ipairs(idxs) do
        local card = poker[idx]
        poker[idx],poker[poker.pos] = poker[poker.pos],poker[idx]
        poker.pos = poker.pos + 1
        table.insert(cards, card)
    end
    return cards
end

-- 失败还原
function _M.deal_revert(poker)
    if poker.temp ~= nil then
        poker.pos = poker.temp.pos
        for pos,card in pairs(poker.temp.revert) do
            poker[pos] = card
        end
        poker.temp = nil
    end
end

-- 发牌,指定
function _M.dealCarding(poker,t,v,ace)
    local num = _M.card2num({type=t,value=v},ace)
    local card = poker[num]
    return card, num
end

-- 发牌,指定结算，从牌中剔除
function _M.dealCarded(poker,nums)
    -- 必须先排序，从小到大
    table.sort(nums)
    for _,num in ipairs(nums) do
        log('dealCarded num %s value,type=%s,%s %d', num, poker[num].value, poker[num].type, poker.pos)
        poker[poker.pos], poker[num] = poker[num], poker[poker.pos]
        poker.pos = poker.pos + 1
    end
end

-- 交换牌位置 oldcard位置的牌交换为newcard位置的牌
function _M.swapCardPos(poker,newcard,oldcard)
    for i=poker.pos,poker.total do
        local p = poker[i]
        if p and p.value == newcard.value and p.type == newcard.type then
            for j=1,poker.pos do
                p = poker[j]
                if p.value == oldcard.value and p.type == oldcard.value then
                    poker[j],poker[i] = poker[i],poker[j]
                    break
                end
            end
            break
        end
    end
end

return _M