/*
 * @Author: Michael Zhang
 * @Date: 2019-07-09 14:57:22
 * @LastEditTime: 2019-07-09 17:01:32
 */

'use strict'

let proto = require('./common/dataModel/proto');
let HTTPTool = require('./common/network/httpTool')
let SocketTool = require('./common/network/socketTool')

let Enums = require('../dataModel/enums')
let CommonData = require('../dataModel/commonData')

let net = cc.Class({

    ctor () {

        this.netTool = null

        if( this.isWebSocket() ) { // 使用websocket
            
            this.netTool = new SocketTool()
            this.netTool.init()
            this.netTool.connect()

        } else { // 使用HTTP

            this.netTool  = HTTPTool;
        }

    },

    /**
     * 
     * @param {} act  动作 方法
     * @param {} isAsyncOrPost  是否是异步或者post请求
     * @param {} data 请求数据
     * @param {} callback 回调
     */
    send ( act, isAsyncOrPost , data, callback   ) {

        let obj = {
            heartbreak: proto.Hongzao.HeartBreak
        }

        let newClass = obj[act];
        data.base = {
            act: act,
            seq: 0,
            err: 0,
            isAsync: isAsyncOrPost,
            ts: (new Date()).getTime()
        };
        let request = newClass.create( data );

        if( this.isWebSocket() ) { // 使用websocket
        
            this.netTool.send( request, callback);

        } else { // 使用HTTP

            this.netTool.sendRequest(CommonData.GAME_SERVER_HTTP_URL(), act, data, callback, isAsyncOrPost, this);
        }
        

    },

    isWebSocket () {
        return CommonData.GAME_SERVER_TYPE == Enums.SERVER_TYPE.WEBSOCKET;
    }


}) 

module.exports = net;