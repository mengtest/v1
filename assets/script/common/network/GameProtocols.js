/*
 * @Author: Michael Zhang
 * @Date: 2019-07-05 14:06:31
 * @LastEditTime: 2019-07-05 14:15:14
 */

"use strict";

/**
 * 消息基类对象，请求消息BaseRequest， 回调消息BaseResponse都继承BaseProtocol
 */
let BaseProtocol = cc.Class({
    ctor: function () {
        /**
         * 请求动作类型
         */
        this.act = '';

        /**
         * 每个请求的sequence_id应该唯一
         */
        this.seq = 0;

        /**
         * 错误代码，0为正常
         */
        this.err = 0;

        /**
         * 是否需要等待服务器回调
         */
        this.is_async = false;
    }
});

/**
 * 请求消息基类，客户端的请求都继承这个类
 */
let BaseRequest = cc.Class({
    extends: BaseProtocol
});

/**
 * 服务器返回的消息对应的对象，包含返回数据，一般和BaseRequest成对使用
 * @class BaseResponse
 * @extends BaseProtocol
 */
let BaseResponse = cc.Class({
    extends: BaseProtocol,

    /**
     * 读取返回数据，设置BaseResponse对象
     */
    loadData: function (data) {
        var key;
        for (key in data) {
            if(!this.hasOwnProperty(key)){
                continue;
            }

            if(data[key] !== undefined && data[key] !== null){
                this[key] = data[key];
            }
        }
    }
});

let HeartRequest = cc.Class({
    extends: BaseRequest,
    ctor(){
        this.act = 'heart';
        this.t = -1;    // 发送时间
    }
});

let HeartResponse = cc.Class({
    extends: BaseResponse,

    ctor(){
        this.act = 'heart';
        this.t = -1;
    }
});

let ChatRequest = cc.Class({
    extends: BaseRequest,
    ctor(){
        this.act = 'chat';
        this.msg = '';
        this.uid = '';
    }
});

let ChatResponse = cc.Class({
    extends: BaseResponse,
    ctor(){
        this.act = 'chat';
        this.msg = '';
        this.uid = '';
    }
});

let LoginRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {
        this.act = 'login';

        /**
         * facebook用户的accessToken，或游客的UUID
         */
        this.token = '';

        /**
         * token来源，默认0:游客，1:facebook
         */
        this.origin = 0;

        /**
         * 平台: 必须为以下几种之一：android/ios/winphone/pc
         */
        this.os = '';

        /**
         * 平台系统版本
         */
        this.osVersion = '';

        /**
         * 设备产品型号, 示例 iPhone8,2, SM-G 9280
         */
        this.deviceModel = '';

        /**
         * 渠道ID
         */
        this.channelId = 0;

        /**
         * Ios设备广告标示符
         */
        this.idfa = '';

        /**
         * 安卓设备id
         */
        this.androidId = '';

        /**
         * Google广告平台账号，安装了google play的设备可取到
         */
        this.googleAid = '';

        /**
         * 应用版本号
         */
        this.appVersion = '';

        /**
         * 取package name或者bundle id
         */
        this.packName = '';


        /**
         * 设备语言
         * @type {string}
         */
        this.language = '';

        this.locale = "";

    }
});

let LoginResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'login';

        /**
         * 游客第一次登录时返回的token，需要客户端保存
         */
        this.token = '';

        /**
         * 离体力下次恢复点的剩余时间秒数
         * @type {number}
         */
        this.spStepLeftTime = 0;

        /**
         * 体力恢复周期
         * @type {Number}
         */
        this.spInterval = 0;

        /**
         * 农场每天产出量，产出未解锁时为-1
         * @type {number}
         */
        this.farmDailyOut = -1;

        /**
         * 农场已产出量
         * @type {number}
         */
        this.farmCoins = 0;

        /**
         * 农场产出间隔
         * @type {number}
         */
        this.farmInterval = null;

        /**
         * 用json object表示的一个player对象，字段说明参见player json对象
         */
        this.me = {};

        /**
         * 建筑数据数组
         * @type {Array}
         */
        this.buildings = [];

        /**
         * 农民数据数组
         * @type {Array}
         */
        this.farms = [];

        /**
         * 富豪数据
         */
        this.cashking = {};

        /**
         * 行星配置
         */
        this.planetConf = {};

        /**
         * 农民配置
         */
        this.farmConfList = [];

        /**
         * 其他配置
         */
        this.settingConf = {};

        /**
         * 好友数据
         */
        this.friends = [];

        /**
         * 好友通缉的目标列表
         */
        this.helpWantList = [];

        /**
         * 邮件消息列表
         */
        this.newsList = [];

        /**
         * 复仇列表
         */
        this.revengeList = [];

        /**
         * 商品信息
         * @type {Array}
         */
        this.rechargeConfs = [];

        /**
         * 总岛数
         * @type {Number}
         */
        this.planetConfListSize = 0;

        /**
         * 他人行星信息对象,仅在转到fire断线重新登录时有效
         * @type {Object}
         */
        this.fireTarget = null;

        /**
         * 他人行星信息对象列表,仅在转到steal断线重新登录时有效
         * @type {Array}
         */
        this.stealTarget = null;
    }
});

let LogoutRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {
        this.act = 'logout';
    }
});

let LogoutResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'logout';
    }
});

/**
 * 绑定fb账号
 * @extends BaseRequest
 */
let BindFacebookRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {
        this.act = 'bindFb';

        /**
         * facebook用户的accessToken，或游客的UUID
         */
        this.token = '';
    }
});
/**
 * 绑定fb账号
 * @extends BaseResponse
 */
let BindFacebookResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'bindFb';

        /**
         * fb数据
         */
        this.me = 0;

        /**
         * fb好友
         */
        this.friends = 0;
    }
});

let SpinRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {
        this.act = 'spin';

        /**
         * 倍数
         * @type {Number}
         */
        this.x = 1;
    }
});

let SpinResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'spin';

        /**
         * 摇中的转盘ID
         */
        this.hit = 0;

        /**
         * 转到护盾，但护盾已满时，存在
         * @type {number}
         */
        this.shieldfull = 0;

        /**
         * 玩家数据对象
         */
        this.me = {};

        /**
         * 他人行星信息对象,仅在转到fire时有效
         * @type {*}
         */
        this.fireTarget = {};

        /**
         * 偷取对象数据
         */
        this.stealTarget = [];

        /**
         * 离体力下次恢复点的剩余时间秒数
         * @type {number}
         */
        this.spStepLeftTime = 0;

        /**
         * 体力恢复周期
         * @type {Number}
         */
        this.spInterval = 0;

        /**
         * 倍数
         * @type {Number}
         */
        this.x = 1;
    }
});

/**
 * 获取排名
 * @extends BaseRequest
 */
let RankRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {
        this.act = 'rankboard';

        /**
         * 请求动作类型{ 0全部，1本地，2好友 }
         * @type {int}
         */
        this.type = 0;
    }
});
/**
 * 获取排名
 * @extends BaseResponse
 */
let RankResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'rankboard';

        /**
         *  我的排名
         */
        this.myRank = 0;

        /**
         * 排名玩家数据
         */
        this.men = [];
    }
});


//push------------------------------------------------------------------------------

/**
 * 推送消息 被攻击
 * @extends BaseResponse
 */
var PushAttackedResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'attacked';

        /**
         * 玩家更新数据
         */
        this.me = null;

        /**
         * 建筑数据
         */
        this.building = null;

        /**
         * 敌人
         */
        this.hatredman = null;

        /**
         * 消息
         */
        this.news = null;
    }
});


/**
 * 推送消息 推送消息好友已赠送体力
 * @extends BaseResponse
 */
var PushSendSpResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'sendSpNotify';

        /**
         * 好友对象
         */
        this.friend = null;
    }
});

/**
 * 推送消息 推送消息好友已领取赠送的体力
 * @extends BaseResponse
 */
var PushTakeSpResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'takeSpNotify';

        /**
         * 好友对象
         */
        this.friend = null;
    }
});

/**
 * 推送消息 同步好友信息
 * @extends BaseResponse
 */
var PushSyncFriendInfo = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = 'friendInfoSync';

        /**
         * 好友
         */
        this.friend = null;
    }
});

/**
 * 推送消息 新增好友
 * @extends BaseResponse
 */
var PushAddNewFriend = cc.Class({
    extends: BaseResponse,

    ctor: function () {

        this.act = 'newFriend';

        /**
         * 好友
         */
        this.friend = null;

        /**
         * 消息
         */
        this.news = null;
    }
});

/**
 * debug回调
 * @extends BaseRequest
 */
let DebugChangeMeRequest = cc.Class({
    extends: BaseRequest,

    ctor: function () {

        this.act = "cmdTest";                    //请求动作类型
        this.cmd = "";
        //  "player coins add 100", cmd格式：player field value 或者 player field add value
        //  Building field [add] value where playerId value type value
    }

});
/**
 * debug回调
 * @extends BaseResponse
 */
let DebugChangeMeResponse = cc.Class({
    extends: BaseResponse,

    ctor: function () {
        this.act = "cmdTest";

        /**
         * 玩家数据
         * @type {Object}
         */
        this.me = {};

        /**
         * 体力恢复周期
         * @type {Number}
         */
        this.spInterval = null;

        /**
         * 体力恢复剩余时间
         * @type {Number}
         */
        this.spStepLeftTime = null;

        /**
         * 存钱罐速度
         * @type {Number}
         */
        this.farmDailyOut = null;

        /**
         * 存钱罐可回收金币
         * @type {Number}
         */
        this.farmCoins = null;

        /**
         * 存钱罐回收周期
         * @type {Number}
         */
        this.farmInterval = null;

        /**
         * 岛屿建筑数据
         * @type {Array}
         */
        this.buildings = null;
    }
});

let response_classes = {
    login: LoginResponse,
    logout: LogoutResponse,
    spin: SpinResponse,
    bindFb: BindFacebookResponse,
    rankboard: RankResponse,
    heart: HeartResponse,
    chat: ChatResponse,

    //push
    attacked: PushAttackedResponse,
    sendSpNotify: PushSendSpResponse,
    takeSpNotify: PushTakeSpResponse,
    newFriend: PushAddNewFriend,
    friendInfoSync: PushSyncFriendInfo,

    // debug
    cmdTest: DebugChangeMeResponse,
};

module.exports = {
    LoginRequest: LoginRequest,
    LoginResponse: LoginResponse,
    LogoutRequest: LogoutRequest,
    LogoutResponse: LogoutResponse,
    SpinRequest: SpinRequest,
    SpinResponse: SpinResponse,
    BindFacebookRequest: BindFacebookRequest,
    BindFacebookResponse: BindFacebookResponse,
    RankRequest: RankRequest,
    RankResponse: RankResponse,
    HeartRequest: HeartRequest,
    HeartResponse: HeartResponse,
    ChatRequest: ChatRequest,
    ChatResponse: ChatResponse,

    // debug
    DebugChangeMeRequest: DebugChangeMeRequest,
    DebugChangeMeResponse: DebugChangeMeResponse,

    //push消息
    PushAttackedResponse: PushAttackedResponse,
    PushSendSpResponse: PushSendSpResponse,
    PushTakeSpResponse: PushTakeSpResponse,
    PushAddNewFriend: PushAddNewFriend,
    PushSyncFriendInfo: PushSyncFriendInfo,

    response_classes: response_classes
};