local errcode = require "enum.errcode"

local const = {}
setmetatable(const, {
    __index = function (t, k)
        return function()
            print("unknown field from const: ", k, t)
        end
    end
    })

const.CARD_NUM = 54
const.MAX_PLAYER = 3
const.PER_PLAYER_CARD_NUM = 17
const.BOTTOM_CARD_NUM = 3

-- 牌值定义
-- 从1开始编号，按花色和面值有序排放，1-13为♣️梅花， 14-26为♦️方片，27-39为♥️红桃，40-52为♠️黑桃
-- 53和54特殊牌，表示大小王(kCard_Joker1, kCard_Joker2)

-- 面值定义如下
const.kCard_ValueLeast        =   2
const.kCard_Value3            =   3
const.kCard_Value4            =   4
const.kCard_Value5            =   5
const.kCard_Value6            =   6
const.kCard_Value7            =   7
const.kCard_Value8            =   8
const.kCard_Value9            =   9
const.kCard_ValueT            =   10     -- Ten
const.kCard_ValueJ            =   11
const.kCard_ValueQ            =   12
const.kCard_ValueK            =   13
const.kCard_ValueA            =   14
const.kCard_Value2            =   15
const.kCard_ValueJoker1       =   16
const.kCard_ValueJoker2       =   17

const.kCard_Joker1            =   53
const.kCard_Joker2            =   54


const.kCardType_Single        =   1   -- 单纯类型, seriaNum == 1
const.kCardType_Serial        =   2   -- 单顺, 双顺, 三顺(飞机), 4顺
const.kCardType_Rocket        =   3   -- 火箭(大小王)

const.YUNCHENG_ACL_STATUS_RESTART_NO_MASTER                     =   101;  -- 没有人叫地主， 重新开始
const.YUNCHENG_ACL_STATUS_NO_SELECT_CARDS                       =   102;  -- 你没有选择任何牌
const.YUNCHENG_ACL_STATUS_NOT_VALID_TYPE                        =   103;  -- 不能组成有效牌型
const.YUNCHENG_ACL_STATUS_NOT_SAME_TYPE                         =   104;  -- 不是同一牌型
const.YUNCHENG_ACL_STATUS_NOT_BIGGER                            =   105;  -- 打不过别人的牌
const.YUNCHENG_ACL_STATUS_NO_BIG_CARDS                          =   106;  -- 没有牌能大过上家
const.YUNCHENG_ACL_STATUS_NO_YOUR_CARDS                         =   107;  -- 发的牌不是你的牌

const.errcode_map = {
    [const.YUNCHENG_ACL_STATUS_NO_SELECT_CARDS] = errcode.ddz_throw_no_select_cards,    -- 你没有选择任何牌
    [const.YUNCHENG_ACL_STATUS_NOT_VALID_TYPE] = errcode.ddz_throw_not_valid_type,      -- 不能组成有效牌型
    [const.YUNCHENG_ACL_STATUS_NOT_SAME_TYPE] = errcode.ddz_throw_not_same_type,        -- 不是同一牌型
    [const.YUNCHENG_ACL_STATUS_NOT_BIGGER] = errcode.ddz_throw_not_bigger,              -- 打不过别人的牌
    [const.YUNCHENG_ACL_STATUS_NO_BIG_CARDS] = errcode.ddz_throw_no_big_cards,          -- 没有牌能大过上家
    [const.YUNCHENG_ACL_STATUS_NO_YOUR_CARDS] = errcode.ddz_throw_no_your_cards,        -- 发的牌不是你的牌
}

const.isRocket = function (node)
    return node.cardType == const.kCardType_Rocket
end

const.isBomb = function (node)
    return node.seralNum==1 and node.mainNum >= 4 and node.subNum == 0
end

const.removeSubset = function (main, sub)
    local all = true
    for _, n in ipairs(sub) do
        local idx = nil
        for i,v in ipairs(main) do
            if v == n then
                idx = i
                break
            end
        end

        if not idx then
            all = nil
            print(n , " not found in main ")
        else
            table.remove(main, idx)
        end
    end

    return all
end

const.getCardValue = function (card)
    if card == const.kCard_Joker1 then
        return const.kCard_ValueJoker1;
    end

    if card == const.kCard_Joker2 then
        return const.kCard_ValueJoker2;
    end

    local t = card % 13;
    if t < 3 then
        t = t + 13;
    end
    return t;
end

-- 01234 依次大小王♣️梅花♦️方片♥️红桃♠️黑桃
const.getCardSuit = function (card)
    if card == const.kCard_Joker1 or card == const.kCard_Joker2 then
        return 0
    end
    assert(card > 0 and card < const.kCard_Joker1)
    return math.ceil(card / 13)
end

const.getCardItSelf = function (card)
    return card
end

const.getSelCards = function (array, mainFunc, subset, subFunc)
    local cards = {}
    local subArr = {}
    for i, v in ipairs(subset) do
        subArr[i] = v
    end

    for _, sp in ipairs(array) do
        local valueT = mainFunc(sp)

        for i, v in ipairs(subArr) do
            if valueT == subFunc(v) then
                table.insert(cards, sp)

                table.remove(subArr, i)
                break
            end
        end
    end

    local ok = false
    if #subArr == 0 then
        ok = true
    end

    return ok, cards
end

return const

