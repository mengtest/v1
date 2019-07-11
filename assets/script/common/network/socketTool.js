/*
 * @Author: Michael Zhang
 * @Date: 2019-07-05 14:07:37
 * @LastEditTime: 2019-07-11 17:18:55
 */

"use strict";

let GameNetwork = require("./gameNetwork");
let eventMgr = require('../utils/eventCustom')
let CommonData = require('../dataModel/commonData');

let NetProxy = cc.Class({

    ctor: function () {

        this.network = null;
        this._cachePushCallback = [];
    },

    init: function () {
        
        this.network = new GameNetwork();
        this.network.setDelegate(this);
        this.initPushCallback();
    },

    connect: function () {
        this.network.connect( CommonData.GAME_SERVER_WS_URL() );
    },

    closeConnect: function () {
        this.network.closeConnect();
    },

    isNetworkOpened: function () {
        return this.network.isSocketOpened();
    },

    isNetworkClosed: function () {
        return this.network.isSocketClosed();
    },

    onNetworkOpen: function () {
        eventMgr.getInstance().emit("onNetworkOpen")
    },

    onNetworkClose: function () {
        eventMgr.getInstance().emit("onNetworkClose")
    },

    onNetworkError: function () {
        eventMgr.getInstance().emit("onNetworkError")
    },

    /**
     * 注册push回调接口
     */
    initPushCallback: function () {

        let self = this;
  
        this.network.registerPushResponseCallback( 'heartbreak', self.pushCallback.bind(self) );
    },

    
    send: function( obj, callback ) {

        this.network.sendRequest(obj, callback);
    },

    //push回调------------------------------------------------------------------------------

    /**
     * 推送回调
     */
    pushCallback: function (response) {

        switch (response.base.act){
  
            case "heartbreak":
                
                this.pushChat(response);
                break;
        }
    },
   
    pushChat: function (resp) {
        
        eventMgr.getInstance().emit('heartbreak', resp);
    },

});

module.exports = NetProxy;