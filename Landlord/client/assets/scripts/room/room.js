/*
 * @Author: Michael Zhang
 * @Date: 2019-07-17 09:12:44
 * @LastEditTime: 2019-07-24 17:04:04
 */

var roomControl = require("./roomControl")
var roomManager = require("./roomManager")

var panelCfg = require('../common/panelCfg')
var panelMgr = require('../common/panelManager')

cc.Class({
    
    extends: cc.Component,

    properties: {

        rightBtn: cc.Animation,

        moreBtn: cc.Button,
    },

    // LIFE-CYCLE CALLBACKS:
    addEvents(){
        eventManager.addEvent("NET_"+msgNameDefine.exitGame+"_EVENT",util.handler(this.recExitGameMsg,this),"entergame1");
    },
    recExitGameMsg(msg) {

        cc.log(msg)
        
        if( msg.e == 0 ) {

            cc.director.loadScene("lobby");
        } else {

            cc.log( "退出房间失败" )
        }
    },
    onLoad () {
        roomControl.init();
        roomManager.init();
        
    },
    start () {
        this.addEvents()

        if( sceneManager.sceneParams.has( cc.director.getScene().name ) ){

            let params = sceneManager.sceneParams.get( cc.director.getScene().name )[0];
            
             // 1 新手场 2 普通场 3 精英场 4 大师场
            cc.log( params )
        } 

    },
    returnlobby:function()
    {
        netManager.sendMsg(msgNameDefine.exitGame,{});
       
    },

    /**
     * 记录列表
     */
    recordList () {

    },


    /**
     * 托管
     */
    trusteeship () {

    },

    /**
     * 领奖
     */
    receive () {

    },
    
    /**
     * 任务
     */
    assignment () {
        
        panelMgr.createPanel( panelCfg.TaskPanel, ( err, panel )=>{ }, this.onde )
    },

    /**
     * 更多
     */
    more (  ) {

        this.rightBtn.node.active = true;

        this.moreBtn.interactable = false
        this.rightBtn.play().wrapMode = cc.WrapMode.Reverse;
    },

    /**
     * 关闭更多
     */
    moreBack () {
        
        this.moreBtn.interactable = true
        this.rightBtn.play().wrapMode = cc.WrapMode.Normal;
    },

    /**
     * 背包
     */
    knapsack () {

        cc.log("knapsack")
        panelMgr.createPanel( panelCfg.knapsackPanel, ( err, panel )=>{ }, this.onde )
    },

    /**
     * 设置
     */
    setting (){

        cc.log("setting")
        panelMgr.createPanel( panelCfg.SetPanel, ( err, panel )=>{ }, this.onde )
    },

    /**
     * 规则
     */
    rule () {
        
        cc.log("rule")
    },

    onDestroy(){
        roomControl.onDestroy();
        roomManager.onDestroy();
        this.removeEvents()
    },
    // update (dt) {},
    removeEvents(){
        eventManager.removeEvent("NET_"+msgNameDefine.exitGame+"_EVENT","entergame1");
    }
});
