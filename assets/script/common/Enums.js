/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:53:55
 * @LastEditTime: 2019-07-04 15:55:04
 */
window.enums = {
    ////////////////////普通值类型枚举//////////////////

    debug_state : cc.Enum({                         //游戏debug类型
        DEBUG                : 0,                   //开发/测试
        RELEASE              : 1,                  //正式
        MARKET_DEBUG : 2,             // 市场内部测试
    }),

    channel : cc.Enum({
        UNKNOWN                    : 0,
        IOS_COMPANY                : 1,      //ios企业包
        ANDROID_OFFICIAL           : 2,      //android官网
        ANDROID_YINGYONGBAO        : 3,      //android应用宝
        IOS_OFFICIAL               : 4,      //appStore包
    }),

    ios_type : cc.Enum({
        APPSTORE             : 0,               // App Store包
        COMPANY       : 1,                      // 企业包
    }),

    game_id : cc.Enum({
        GAME_HALL         : 0,               //大厅
        MAHJONG_DKG       : 1,               //断卡勾麻将
        NIUNIU            : 2,               //牛牛
        MAHJONG_SCXZ      : 3,               //血战麻将
        WUZIQI            : 4,               //五子棋
		ZHAJINHUA		  : 6,				 //炸金花	
        PAODEKUAI         : 7,               //跑的快
        REDBLACK          : 100,             //红黑大战
        LONGHUDOU         : 101,             // 龙虎斗
        BAIJIALE          : 102,             //百家乐
        SHUIHUZHUAN       : 104,             //水浒传		
        BREAKAWAY         : 105,             //冰球突破
		BENCHIBAOMA       : 106,             //奔驰宝马
        HIGHWAY           : 107,             //高速公路
        GEM_FRENZY        : 109,             // 疯狂宝石
        JINPINGMEI        : 108,             //金瓶梅
        BAIRENNIUNIU	  : 103,			   //百人牛牛
        SUPER_WINER       : 110,             //超级玩家
        ROU_PU_TUAN       : 111,             //肉蒲团
        FULUSHOU          : 112,             //福禄寿
	    BASEKETBALL       : 113,             //疯狂篮球
        FRUIT             : 120,             //水果机
        FRUITNEW          : 121,             //带小玛丽的水果机
        BUYU              : 333,             //捕鱼
    }),

    load_type : cc.Enum ({                   //界面加载方式：
        DEFAULT           : 1,               //直接加载
        PRELOAD           : 2,               //预加载界面
        RESIDENT          : 3,               //直接加载并常驻内存
        PRELOAD_RESIDENT  : 4,               //预加载并常驻内存
    }),

    priority : cc.Enum ({                    //界面优先级（值越大，优先级越高）：
        GAMEHALL        : 500,
        DEFAULT           : 1000,            //基础界面
        WINDOW            : 2000,            //二级界面
        WAITTING          : 3000,            //等待界面
        COMFIRM           : 4000,            //确认框
        SYSTEM            : 5000,            //系统界面
    }) ,

    res_load_type : cc.Enum ({               //资源加载方式
        FILE              : 1,               //加载类型为单个文件
        FOLDER            : 2,               //加载类型为文件夹
    }) ,

    auth_type : cc.Enum ( {
        OFFICIAL_GUEST    : 1,               //游客
        WECHAT            : 2,               //微信
        CUSTOM_GUSET      : 3,               //账号登陆的注册登陆方式
        CUSTOM_LOGIN      : 4,               //账号登陆的直接登陆方式
    }),

    proto_type : cc.Enum ({                 // 协议解析类型
        JSON                : 1,
        SPROTO              : 2,
        GOOGLE_PROTO_BUFFER : 3
    }),

    network_state : cc.Enum ({
        UNKNOWN           : 0,              //游戏开始后还没有开始链接任何网络，否则只能是下面的其中之一
        CONNECTTING       : 1,              //连接中
        RECONNECTTING     : 2,              //已连接
        READY             : 3,              //准备
        CLOSED            : 4,              //已关闭
    }),

    sex : cc.Enum({
        MALE              : 1,              //男
        FEMALE            : 2               //女
    }),

    toggle_type : cc.Enum({                 //按钮组类型
        TOGGLE            : 1,              //多选
        RADIO             : 2,              //单选
        DEFAULT           : 3,              //默认
    }),

    player_type : cc.Enum({                 //玩家类型
        SELF              : 1,              //自己
        FRIEND            : 2,              //好友
        STRANGER          : 3,              //陌生人
    }),

    rank_type : cc.Enum({                   //排行榜
        COIN              : 1,              //金币排行榜
        LOTTERY           : 2,              //奖券排行榜
        MAX_WIN_COIN      : 3,              //每日最大金币赢取排行榜
        MAKE_MONEY        : 4,              //赚金榜
    }),

    room_type : cc.Enum({
        UNKNOW            : 0,
        COMMON            : 1,              //系统场
        ROOM_CARD         : 2,              //房卡场
        GOLD              : 3,              //金币场
        MATCH             : 4,              //比赛场
    }),

    table_type : cc.Enum ( {
        TABLE_PRIMARY				: 1,	//初级场
        TABLE_INTERMEDIATE		    : 2,	//中级场
        TABLE_SENIOR				: 3,	//高级场
        TABLE_EXPERIENCE			: 4,	//体验场
    }),

    keypad_type : cc.Enum({                 //数字按钮功能
        UNKNOWN           : 0,
        ROOM_NUMBER       : 1,              //输入房间号
        PASSWORD          : 2,              //输入密码，
        ENTRY_LIMIT       : 3,              //进入条件
        LEAVE_LIMIT       : 4,              //离开条件
        BASE_SCORE        : 5,              //底分
        INPUT_COIN        : 6,              //输入金币
        TRANSFER_INPUT    : 7,              //转账输入
    }),

    table_state : cc.Enum({
        // --所有游戏的公用状态
        UNKNOW               : 0,
        WAIT_FOR_READY       : 1,	       //等待所有玩家准备
        GAME_START           : 2,          //游戏开始状态
        ROUND_START          : 3,          //一局游戏开始
        WAIT_ROUND_START     : 4,          //等待一局游戏开始
        WAIT_ROUND_OVER      : 5,          //等待一局游戏真正结束
        WAIT_GAME_OVER       : 6,          //等待游戏结束
        ROUND_OVER           : 7,          //一局游戏结束
        GAME_OVER            : 8,          //一局游戏真正结束
        CONTINUE             : 9,          //继续处理逻辑
        CONTINUE_AND_STANDUP : 10,
        CONTINUE_AND_LEAVE   : 11,
        GAME_END             : 12,  	   //游戏结束
        WAIT_CLIENT_ACTION   : 13,         //等待客户端操作
        WAIT_PLAYER_SITDOWN	 : 14,         //等待玩家坐下,
        DISBAND_GAME         : 15,         //解散游戏
        WAIT_GAME_START      : 16,         //等待游戏开始
    }),

    seat_state : cc.Enum({                        //所有游戏的通用桌位状态
        UNKNOW               : 0,
        NO_PLAYER            : 1,          //没有玩家
        WAIT_READY           : 2,          //等待准备
        WAIT_START           : 3,          //等待开局
        PLAYING              : 4,          //正在游戏中
    }),

    align_type : cc.Enum({                       //节点排列方式
        LEFT_TO_RIGHT        : 1,          //左到右
        RIGHT_TO_LEFT        : 2,          //右到左
        CENTER_TO_LR         : 3,          //中间到左右
        TOP_TO_BUTTOM        : 4,          //上到下
        BUTTOM_TO_TOP        : 5,          //下到上
        CENTER_TO_TB         : 6,          //中间到上下
    }),

    disband_state : cc.Enum({
        UNKNOWN              : 0,          //等待操作
        AGREE                : 1,          //同意
        DISAGREE             : 2,          //不同意
    }),

    zimo_charge_type : cc.Enum({
        ZMCT_JiaDi          : 0,
        ZMCT_JiaFan         : 1,
    }),

    welfare_type : cc.Enum({
        WT_ZhanJi           : 1,        // 战绩分享
        WT_HaoYou           : 2,        // 邀请好友
        WT_FuLi             : 3,        // 福利分享
    }),

    platform_type : cc.Enum({
        TIANTIANLE          : 1,           //天天乐
    }),

    channel_type : cc.Enum({
        TIANTIANLE_OFFICIAL_ANDROID   : 1,
        TIANTIANLE_OFFICIAL_IOS       : 2,
    }),

    comfirm_type : cc.Enum({
        PROMPT                  : 1,            //提示
        UP_DATA                 : 2,            //更新提示
        ROOM_FULL               : 3,            //房间已满
        GOLD_LACK               : 4,            //金币不足
        IP_ALIKE                : 5,            //IP相同
        BACK_HALL               : 6,            //返回大厅
        BACK_ROOM               : 7,            //返回房间
        match_hint              : 8,            //比赛报名提醒
        match_rank              : 9,            //比赛晋级成功提示
        match_miss              : 10,           //无法参加比赛提醒
        GAME_RENSHU             : 11,           //五子棋认输
    }),

    check_state_way : cc.Enum({
        GAME_HALL               : 1,       //在大厅请求
        CREATE_ROOM             : 2,       //在创建房间里请求
        JOIN_ROOM               : 3,       //在加入房间中请求
        ROOM_INFO               : 4,       //房间信息
        TEA_HOUSE               : 5,        // 茶馆
    }),

    identify_type : cc.Enum({              // 请求类型 0 验证手机号及验证码 1 获取验证码
        PHONE_AND_CODE : 0,
        CODE           : 1
    }),

    player_state : cc.Enum({
        DEFAULT : 0,    //正常状态
        READY   : 1,    //已准备
        OFFLINE : 2,    //离线
        TUOGUAN : 3,    //托管
    }),

    match_type : cc.Enum({
        INVALID_MATCH       : 0,                //非法
        RANK_MATCH          : 1,                //排行
        AT_FULL_START       : 2,                //人满开赛
    }),

    match_state : {
        INVALID                     : 0,    //表示该比赛还不能开始
        NOT_SIGNUP_NOT_ENTER        : 1, 	//比赛能看到但是不能报名不能进入
        CAN_SIGNUP_NOT_ENTER        : 2, 	//可以报名, 但报了名不能进入
        CAN_SIGNUP_CAN_ENTER        : 3,    //比赛开始前能报名能进入
        NOT_SIGNUP_CAN_ENTER        : 4, 	//开赛前报名结束
        START_CANSIGNUP_CANENTER    : 5,    //比赛开始以后能报名能进入
        START_CANSIGNUP_NOTENTER    : 6,    //比赛开始以后能报名不能进入
        START_NOTSIGNUP_CANENTER    : 7,    //比赛开始以后不能报名能进入
        START_NOTSIGNUP_NOTENTER    : 8,    //比赛开始以后不能报名不能进入
        END                         : 9,    //比赛结束
    },

    match_start_state : {
        NOT_START        : 0, // 未开始
        STARTING          : 1, // 进行中
        END_START        : 2, // 已结束
    },

    load_res_state : cc.Enum({
        UNKNOWN                 : 0,
        CHECK_VERSION           : 1,      //正在对比版本文件
        CHECK_NO_NEW_VERSION    : 2,      //版本对比完成，客户端资源已经是最新
        CHECK_DOWNLOAD_LIST     : 3,      //正在获取更新列表
        CHECK_NO_DOWNLOAD_LIST  : 4,      //更新列表获取完成!没有需要更新的资源
        DOWNLOADING_LIST        : 5,      //正在下载游戏资源
        DOWNLOADING_END         : 6,      //下载完成
        LOADING_CONFIG          : 7,      //正在加载配置文件
        LOADING_ATLAS           : 8,      //正在加载美术资源
        LOADING_FONT            : 9,      //正在加载字体资源
        LOADING_MEDIA           : 10,      //正在加载音效资源
        LOADING_ANIMATION       : 11,     //正在加载特效资源
        LOADING_PREFAB          : 12,     //正在加载预制体
        LOADING_DONE            : 13,     //加载资源完成，正在打开游戏界面
        ERROR                   : 1000
    }),

////////////////////对象类型枚举//////////////////
    game_name : {                             //游戏名字（英文，首字母大写）
        GAME_HALL         : "GameHall",        //大厅
        MAHJONG_DKG       : "MahjongDKG",      //断卡钩麻将
        WUZIQI            : "Wuziqi",
        NIUNIU            : "Niuniu",           //牛牛
        MAHJONG_SCXZ      : "MAHJONG_SCXZ", // 血战
        MAHJONG :       "Mahjong2D",             // 所有麻将
        REDBLACK:       "Redblack" , //红黑大战
        PAODEKUAI :     "Paodekuai", //跑的快
        LONGHUDOU:    "Longhudou", // 龙虎斗
        BAIJIALE :         "Baijiale",  // 百家乐
        SHUIHUZHUAN : "ShuiHuZhuan",//水浒传
        BREAKAWAY   :  "BreakAway",     //冰球突破
		ZHAJINHUA   :  "ZhaJinHua",		//炸金花
		BENCHIBAOMA : "Benchibaoma",     //奔驰宝马
        HIGHWAY    :  "HighWay",      //高速公路
        GEM_FRENZY    :  "GemFrenzy",      //疯狂宝石
        JINPINGMEI : "JinPingMei",//金瓶梅
        BAIRENNIUNIU :	"BaiRenNiuNiu",	//百人牛牛
        SUPER_WINER  :"SuperWiner",//超级玩家
        ROU_PU_TUAN    :  "RouPuTuan",      //肉蒲团
        FULUSHOU       : "FuLuShou",      //福禄寿
	    BASEKETBALL    : "Baseketball",  //疯狂篮球
        FRUIT          :  "Fruit",      //水果机
        FRUITNEW       : "FruitNew",    //带小玛丽的水果机
        BUYU           : "Buyu",//捕鱼
	},
    loadingType : {
        Default    : "Default",
        DKGLoading : "DKGLoading"
    },

    game_chinese_name : {
        MAHJONG_DKG     : "game_name_mahjong_dkg",
        WUZIQI          : "game_name_youxi_wzq",
        NIUNIU          : "game_name_youxi_niuniu",
        MAHJONG_SCXZ : "game_name_mahjong_scxz",
    },

    media_type : {                           //多媒体类型：
        BGM               : "bgm",           //背景音乐
        EFFECT            : "effect",        //音效
    },

    res_path : {                                  //资源直接目录：
        CONFIG            : "Config",           //配置目录
        ATLAS             : "Atlas",            //图集目录
        FONT              : "Font",             //字体目录
        IMAGE             : "Image",            //散图目录   散图主要用于做拉伸图片，如九宫等
        MEDIA             : "Media",            //音乐目录
        ANIMATION         : "Animation",        //动画目录
        SPINE             : "Spine",            //Spine目录
        PROTO             : "Proto",
        PREFAB            : "Prefabs",
    },

    storage_type : {
        EMAIL             : "email",
        CHAT_LOG          : "chatlog",
        ISSUE_ORDER       : "issueorder",       //充值(用于补单了)
        CHARGE_LOG        : "chargelog",       //充值日志(IOS);
        USER_ABOUT        : "userabout",
        REDBLACK_LOG      : "redblacklog"     //红黑日志
    },

    wechat_share_type : {
        TIME_LINE         : "TimeLine_Share",
        FRIEND            : "Friend_Share",
    },

    server_config_type : {
        SELFBUILDTABLE  : "selfbuildtablecfg",      // 自建桌配置;
        WECHATSHARES    : "wechatsharescfg",        // 分享
        COMMON          : "commoncfg",              // 公共配置
        SHOP            : "rechargecfg",            // 商城配置
        task               : "tasksysscfg",             // 任务系统
    },

    net_message_key : {
        RANKDATAUPDATE      : "rankDataUpdate",         // 排行榜数据更新
        SELFRANKDATAUPDATE  : "selfRankDataUpdate",     // 玩家自己的排行数据更新
    },

    //苹果支付失败错误码转英文
    purchase_error : {
        "1": "Error_Code_Not_Get_GoodData",
        "2": "Error_Code_Can_Not_Buy",
        "3": "Error_Code_Buy_From_App",
        "4": "Error_Code_Store_OK",
        "5": "Error_Code_Cancle_Buy",
        "6": "Error_Code_Unknown",

        "998": "Buy_Good_State",
        "1000": "SystemError_Code_Default",
    },

    pay_type : {
        IAP                           : 1,        // IOS支付
        WECHAT                        : 2,        // 微信支付
        ALIPAY                        : 3,        // 支付宝支付
        WECHAT_WEB                    : 4,        // 微信WEB支付
        ALIPAY_WEB                    : 5,        // 支付宝web支付
    },

    pay_state : {
        BEGIN: 1,
        STORE: 2,
        SEND: 3,     //已发送;
    },

    shop_type: {
        GOLD    : 1,
        Zuanshi : 2,
    },

    // 聊天类型
    chat_type :{
        quick_chat : 1,         //  快捷聊天
        record_voice : 2        //  录音聊天
    },

    // 结算类型
    roundSettlementType : cc.Enum({
        DEFINE                : 0,
        MATCH              : 1
    }),

    // 福利状态
    welfare_state : {
        state_new : 1,           // 新任务
        state_ing : 2,              // 进行中
        state_wait_award : 3,   // 等待领奖
        state_finish : 4        // 已完成
    },

    welfare_go_type : {
        type_ljbd : 1, // 立即绑定
        type_jxrz : 2, // 进行验证
        type_djqw : 3 // 点击前往
    },

    task_type : {
        TASK_TYPE_UNKNOWN : 0,
        TASK_TYPE_EVERYDAY : 1,  //每日任务
        TASK_TYPE_EVERYWEEK : 2, //每周任务
        TASK_TYPE_YONGYUAN : 3,  //永久开放
        TASK_TYPE_EVERYDAY_LINK : 4,  // 每日连续任务
    },

    MahjongCard_type : cc.Enum({
        li : "li",    // 普通立牌
        PengGang : "penggang", // 碰杠
        Mo : "mo", // 摸牌
        Hu : "hu", // 胡牌
        Dao : "dao", // 倒牌
        Out : "out", // 出牌
    }),

    MahjongHandCardLocation : cc.Enum({
        Bottom : 0,
        Right : 1,
        Top : 2,
        Left : 3
    }),

    MahjongHandCardPengGang : cc.Enum({
        Peng : 0,
        Gang_ming : 1,  // 明杠
        Gang_an : 2     // 暗杠
    }),

    MahjongCardUpAndDown : {
        up : 0,
        down : 1
    },

    MahjongDingqueType : {
        none : 0,
        tong : 1,
        tiao : 2,
        wan : 3,
    },

    Mahjong2DItemTouchType : {
        begin : 0,
        move : 1,
        end : 2,
        cancel : 3,
    },

    CreateRoomType : {
        Default : 0,
        Teahouse_coin : 1,
        Teahouse_RoomCard : 2,
    },

    ActivityViewType : cc.Enum({
       Activity : 0,
       Task : 1,
    }),

    LongHuDouGoldType : cc.Enum({
        Long : 0,
        Hu : 1,
        He : 2,
    }),

    BaiJiaLeJettonType : cc.Enum({
        player : 0,//闲
        dealer : 1,//庄
        drawn : 2,//和
        playerDouble : 3,//闲对
        dealerDouble : 4,//闲对
    }),

    BaiRenNiuNiuGoldType : cc.Enum({
        HeiTao : 0,
        HongTao : 1,
        MeiHua : 2,
        FanKuai:3,
    }),

    //slots奖励类型
    SlotsRewardType : cc.Enum({
        SLOTSREWARDTYPE_NULL			: 0,	//无奖
        SLOTSREWARDTYPE_LOSE			: 1,	//输奖
        SLOTSREWARDTYPE_WIN				: 2,	//赢奖
        SLOTSREWARDTYPE_FULLSCREEN		: 3,	//全屏奖
        SLOTSREWARDTYPE_FREE			: 4,	//免费奖
        SLOTSREWARDTYPE_SPECIALFS		: 5,	//特殊百搭全屏
        SLOTSREWARDTYPE_COMPARE			: 6,	//猜花色/比倍
        SLOTSREWARDTYPE_MULTIPLE		: 7,	//倍数奖
    }),
}