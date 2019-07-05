/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 11:43:28
 * @LastEditTime: 2019-07-05 18:09:39
 */
// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html

let proto = require('./proto');
let HTTPTool = require('./common/utils/HTTPTool')

if(! CC_EDITOR ){
    // require('./common/utils/WebSocketTool')
}
let NetProxy = require('./common/network/NetProxy');
let netProxy = new NetProxy();
let eventMgr = require('./common/utils/EventCustom')

cc.Class({
    extends: cc.Component,

    properties: {
       
    },
    

    // LIFE-CYCLE CALLBACKS:

    onLoad () {

        // HTTPTool.sendRequest("http://localhost:3000/register", "",  {phone: "18408233953"}, ( msg )=>{
        // }, true, this)

        eventMgr.on("onNetworkOpen", ()=>{
            cc.log(421421)
        }, this.node);  

    },

    start () {

        netProxy.init();
        netProxy.connect();

    },

    
});
