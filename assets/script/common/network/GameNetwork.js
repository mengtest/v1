/*
 * @Author: Michael Zhang
 * @Date: 2019-07-05 14:05:55
 * @LastEditTime: 2019-07-10 15:32:05
 */

"use strict";

let GameWebSocket = require("./gameWebSocket")
let Enums = require('../dataModel/enums')

/**
 * 请求回调对象，收到服务器回调后的回调方法
 */
var NetworkCallback = cc.Class({

    properties: {

        /**
         * @type {BaseRequest} request
         */
        request: null,

        /**
         * 请求回调对方法
         */
        callback: null
    },

    /**
     * @param {BaseRequest} request
     * @param {function(BaseResponse): boolean} callback
     */
    init: function (request, callback) {
        this.request = request;
        this.callback = callback;
    }
});


let GameNetwork = cc.Class({
    
    extends: GameWebSocket.GameWebSocketDelegate,

    ctor: function() {

        this._socket = null;

        this._delegate = null;

        /**
         * 每次发送请求，都需要有一个唯一的编号
         * @type {number}
         * @private
         */
        this._requestSequenceId = 0;

        /**
         * 接受服务器主动下发的response回调
         * key 表示BaseResponse.act
         * @type {Object.<string, function(object.<string, *>)>}
         */
        this.pushResponseCallback = {};

        /**
         * 根据seq保存Request和其callback，以便在收到服务器的响应后回调
         * @type {Object.<int, NetworkCallback>}
         * @private
         */
        this._networkCallbacks = {};

        this._waitseqs = [];

    },

    setDelegate: function (delegate) {
        this._delegate = delegate;
    },

    /**
     * 注册服务器主动推送的response 回调
     */
    registerPushResponseCallback : function(act, callback){
        this.pushResponseCallback[act] = callback;
    },

    /**
     * 判断socket已连接成功，可以通信
     * @returns {boolean}
     */
    isSocketOpened: function(){
        return (!!this._socket && this._socket.getState() == Enums.GameWebSocketState.OPEN);
    },

    isSocketClosed: function () {
        return this._socket == null;
    },

    /**
     * 启动连接
     */
    connect: function (url) {
      
        this._requestSequenceId = 0;
        this._socket = new GameWebSocket.GameWebSocket();
        this._socket.init(url, this);
        this._socket.connect();
    },

    closeConnect: function () {
        
        if(this._socket){
            this._socket.close();
        }
    },

    onSocketOpen: function () {
        
        cc.log( "onSocketOpen" )
        if(this._delegate && this._delegate.onNetworkOpen){
            this._delegate.onNetworkOpen();
        }

        this.recoverWait();
    },

    onSocketError: function () {
        cc.log( "onSocketError" )
        if(this._delegate && this._delegate.onNetworkError){
            this._delegate.onNetworkError();
        }
    },

    onSocketClosed: function (reason) {
        cc.log( "onSocketClosed" )
        if (this._socket) {
            this._socket.close();
        }
        this._socket = null;

        if(this._delegate && this._delegate.onNetworkClose){
            this._delegate.onNetworkClose();
        }
    },

    onSocketMessage: function (msg) {
        cc.log( "onSocketMessage" )
        this._onResponse(msg);
    },

    _onResponse: function(responseData){

        var response = JSON.parse(responseData);
        
        // 如果指定了回调函数，先回调
        var ignoreError = false;
        if(response.base.seq != -1){

            // 处理服务器推送消息
            var pushCallback = this.pushResponseCallback[response.base.act];
            if(pushCallback){
                pushCallback(response);
            }

            // request回调 请求回调
            var callbackObj = this._networkCallbacks[response.base.seq];
            if(callbackObj){
                ignoreError = callbackObj.callback(response);
                delete this._networkCallbacks[response.base.seq];
            }
        }
        
        // 错误处理
    },

    /**
     * 向服务器发送请求。
     *
     * 如果提供了callback，在收到response后会被回调。如果response是一个错误(status!=ERR_OK)，则需要决定由谁来负责处理错误。
     * 如果callback中已经对错误进行了处理，应该返回true，这样会忽略该错误。否则应该返回false，则负责处理该错误。
     *
     * 特别注意：如果这是一个异步(is_async)请求，且出错，一般来讲应该重新登录/同步。但是如果callback返回了true，不会进行
     * 任何处理，也就是不会重新登录/同步。请小心确定返回值。
     *
     * @param {object.<BaseRequest>}
     * @param {function(BaseResponse): boolean=} opt_callback 回调函数。出错的情况下，如果返回true，则不会再次处理错误。
     */
    sendRequest: function (request, opt_callback) {
        
        // 每个请求的seq应该唯一，且递增
        request.base.seq = ++this._requestSequenceId;

        //生成NetworkCallback对象，绑定请求seq和回调方法
        if(opt_callback){
            this._networkCallbacks[request.base.seq] = new NetworkCallback();
            this._networkCallbacks[request.base.seq].init(request, opt_callback);
        }
        this._sendSocketRequest( request );
      
    },

    /**
     * @param {Boolean} isNoData
     * @param {object.<BaseRequest>} req
     */
    _sendSocketRequest: function ( req ) {
        
        if (this.isSocketOpened()){

            //通过json的方法生成请求字符串
            this._socket.send(JSON.stringify(req));

        } else {

            this.addToWaitList( req );
        }
    },

    // 添加到请求等待列表
    addToWaitList: function( req ) {

        this._waitseqs.push( req );
    },

    recoverWait: function() {

        if( this._waitseqs.length > 0 ) {
            for (let index = 0; index < this._waitseqs.length; index++) {
                let element = this._waitseqs[index];
                this._sendSocketRequest(element);
            }
            this._waitseqs = [];
        }
    }
});

module.exports = GameNetwork;