/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 11:43:28
 * @LastEditTime: 2019-07-10 16:46:52
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

let eventMgr = require('./common/utils/eventCustom');
let netMgr = require('./common/manager/networkManager')
let GameStateMgr = require('./common/manager/gameStateManager')
let UIManager = require('./common/manager/uiManager')

let LoadingView = require('./views/LoadingView')

cc.Class({
    extends: cc.Component,

    properties: {
        
    },
    
    // LIFE-CYCLE CALLBACKS:,

    onLoad () {

    },

    start () {
        
        UIManager.getInstance().openUI( LoadingView, 10, ()=>{

            GameStateMgr.getInstance().initGame();

        } , (completedCount, totalCount, item)=>{

        } ) 

        this.schedule( ()=>{

            netMgr.send("heartbreak", true, {username: "hongzap"}, (res)=>{
                cc.log(res);
            })
                    
        }, 5)
        
        eventMgr.on( "heartbreak", (res)=>{
            cc.log(res);
        })
    },

    
});
