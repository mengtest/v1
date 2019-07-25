
return {
    -- 公共
	waitingprocess = -1, 	 	--当前不能即时确定执行结果，需要等待后续处理返回的，返回这个值表示接受消息成功开始处理
	success = 0,
	token = 1,
	password = 2,
    game_not_open = 3,
    player_not_in_desk = 4,
    gold_not_enough = 5,
    player_game_args = 6,               -- 进游戏参数错误
    player_not_in_game = 7,             -- 不在游戏中
    player_is_in_game = 8,              -- 已经在游戏中
    player_exit_game = 9,               -- 退出游戏失败
    player_enter_desk = 10,             -- 进入桌子失败
    player_leave_desk = 11,             -- 离开桌子失败
    in_other_game = 12,                 -- 在其他游戏中

    -- 登录相关 50-69
    server_full = 50,                   -- 服务器满
    server_not_open = 51,               -- 服务器未开启
    server_auth = 52,                   -- 验证失败
    create_role_timeout = 53,           -- 创角超时
    create_role_name = 54,              -- 创角名字非法
    create_role_exist = 55,             -- 创角名字存在
    create_role_full = 56,              -- 创角满
    create_role_err = 57,               -- 创角错误

    login_not_find = 60,                -- 未找到角色
    login_timeout = 61,                 -- 登录超时
    login_err = 62,                     -- 登录错误

    -- 游戏内容 70-79
    emote_error = 70,                   -- 表情错误

    -- 邮件 80-89
    email_err = 80,
    email_readed = 81,
    email_reward = 82,
    email_nodata = 83,

    --保险箱 90 - 99
    safe_null = 90,                     -- 密码空
    safe_password = 91,                 -- 密码错误
    safe_not_open = 92,                 -- 未打开
    safe_save_gold = 93,                -- 存钱，身上钱不够
    safe_draw_gold = 94,                -- 取钱，卡里钱不够
    safe_tran_gold = 95,                -- 汇款，卡里钱不够

    -- 百人牛牛100-199
    cattle_player_already_in = 100,     --玩家已经进入游戏中
    cattle_deskid_err = 101,            --桌子id不正确
    cattle_enter_gold_less = 102,       --进入时钱不足
    cattle_not_in_bet_time = 103,       --不在押注时间内
    cattle_bet_pos_err = 104,           --押注位置错误
    cattle_bet_not_in_betpool = 105,    --押注档次不在配置表中
    cattle_bet_is_top = 106,            --押注达到了上限
    cattle_is_in_masterqueue = 107,     --已在庄家排队队列中，不能重复排队
    cattle_not_in_masterqueue = 108,    --不在庄家队列中，不能下庄
    cattle_bet_beyond_dealer_max = 109, --超过庄家受注上限
    cattle_bet_master_forbid = 110,     --庄家不能下注
    cattle_add_dealer_gold_less = 112,  --上庄钱不够
    cattle_bet_continue_sum_zero = 113, --记录的续投总额为零不能续投
    cattle_req_del_dealer_not_master = 114,         --在庄 申请下庄时，不是庄家申请
    cattle_master_req_del_dealer_again = 115,       --在庄 申请下庄时，重复申请
    cattle_cancle_req_del_dealer_not_master = 116,  --在庄 申请下庄取消，不是庄家申请
    cattle_cancle_req_del_dealer_again = 117,       --在庄 申请下庄取消，重复取消

    -- 抢庄牛牛200-299
    bull_dealer = 200,                  -- 抢庄失败
    bull_bet = 201,                     -- 押注失败
    bull_show = 202,                    -- 摊牌失败

    -- 水果小玛丽300-399
    mary_play = 300,                    -- 开奖失败
    mary_set = 301,                     -- 设置档次失败
    mary_game = 302,                    -- 小玛利次失败

    -- 水果小玛丽400-499
    fruit_play = 400,                    -- 开奖失败
    fruit_set = 401,                     -- 设置档次失败

    -- 百家乐500-599
    baccarat_bet_not_in_betpool = 500,      --押注档次不在配置表中
    baccarat_bet_is_top = 501,              --押注达到了上限
    baccarat_not_in_bet_time = 502,         --不在押注时间内
    baccarat_bet_pos_err = 503,             --押注位置错误
    baccarat_bet_continue_sum_zero = 504,   --记录的续投总额为零不能续投
    baccarat_deskid_err = 505,              --桌子id不正确
    baccarat_player_in_hall = 506,          --玩家已在大厅

    -- 炸金花 700-799
    goldenflower_roomid_err = 700,          --没有roomid
    goldenflower_desk_err = 701,            --该玩家不在桌上
    goldenflower_op_err = 702,              --当前不能操作
    goldenflower_roomid_enter_err = 703,    --进入房间错误
    goldenflower_look_already = 705,        --已经看过牌
    goldenflower_look_circle_less = 706,    --第二轮开始才能看牌
    goldenflower_compare_already = 707,     --已经有比牌的
    goldenflower_compare_circle_less = 708, --第三轮开始后玩家可执行比牌操作
    goldenflower_compare_rid_err = 709,     --比牌玩家rid错误
    goldenflower_compare_other_err = 710,   --对方无比牌资格
    goldenflower_deal_cannot_abandon = 711, --发牌时不能弃牌
    goldenflower_allin_player_num_err = 715, --全押人数错误
    goldenflower_allin_circle_less = 716,   --第三轮后才可全押
    goldenflower_allin_agree_rid_err = 717, --同意全押rid错误
    goldenflower_allin_agree_timeout = 718, --同意全押超时
    goldenflower_allin_already = 719,       --已经有全押的
    goldenflower_gradeidx_max = 720,        --已达加注最高档次
    goldenflower_gradeidx_err = 721,        --传入的加注档次错误
    goldenflower_allin_or_compare = 722,    --当前全押或比牌阶段操作错误
    goldenflower_allin_agree_err = 723,     --没有全押不能同意
    goldenflower_lastone_cannot_abandon = 724,--最后一个人不能主动弃牌
    goldenflower_robot_getscore_cannot_abandon = 725,--机器人收分期不能弃牌

    -- 夜戏貂蝉800-899
    yxdc_chose_type_err = 800,      --免费次数选择类型失败

    -- 斗地主1200-1299
    ddz_not_turn_me = 1200,                    --没有轮到自己
    ddz_call_not_in_phase = 1201,              --不是叫地主阶段
    ddz_call_score_err = 1202,                 --叫地主分数错误
    ddz_call_less_last_score = 1203,           --叫地主分数小于上家
    ddz_multiple_multiple_err = 1204,          --加倍倍数错误
    ddz_multiple_not_in_phase = 1205,          --不是加倍阶段
    ddz_multiple_already = 1206,               --已经加倍过
    ddz_landlord_can_not_multiple = 1207,      --地主不能加倍
    ddz_throw_not_in_phase = 1208,             --不是出牌阶段
    ddz_throw_not_your_cards = 1209,           --出的不是你的牌
    ddz_throw_no_select_cards = 1210,          --你没有选择任何牌
    ddz_throw_not_valid_type = 1211,           --不能组成有效牌型
    ddz_throw_not_same_type = 1212,            --不是同一牌型
    ddz_throw_not_bigger = 1213,               --打不过别人的牌
    ddz_throw_no_big_cards = 1214,             --没有牌能大过上家
    ddz_throw_no_your_cards = 1215,            --发的牌不是你的牌
};