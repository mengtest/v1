return {
    Type = {
    },
    TypeName = {
-- 火箭
-- 炸弹
-- 单张
-- 对子
-- 三张牌
-- 三带一
-- 三带二
-- 单顺子
-- 双顺子
-- 三顺子
-- 飞机带翅膀
-- 四带二
    },
    GameStatus = {
        MATCH = 1,          --匹配
        DEAL = 2,           --发牌
        CALL = 3,           --叫地主
        MULTIPLE = 4,       --加倍
        THROW = 5,          --出牌
        WIN = 6,            --结算
        END = 7,            --结束
    },
    GameStatusName = {
        [1] = "匹配",
        [2] = "发牌",
        [3] = "叫地主",
        [4] = "加倍",
        [5] = "出牌",
        [6] = "结算",
        [7] = "结束",
    },
    AiStatus = {
        LOSER = 1,        --系统输
        NORMAL = 0,       --正常
        WINER = 2,        --系统赢
    },
    AiStatusName = {
        [1] = "系统输",
        [0] = "正常",
        [2] = "系统赢",
    },
    CardStatus = {
        ABANDON = 1,    --弃牌
        LOSE = 2,       --失败
        WIN = 3,        --赢
    },
}
