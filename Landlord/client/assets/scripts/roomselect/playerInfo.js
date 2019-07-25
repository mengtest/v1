/*
 * @Author: Michael Zhang
 * @Date: 2019-07-24 11:15:34
 * @LastEditTime: 2019-07-24 15:49:57
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

cc.Class({
    extends: cc.Component,

    properties: {
        
        headicon: {
            default: null,
            type: cc.Sprite
        },
        nickName: {
            default: null,
            type: cc.Label
        },
        level:{
            default: null,
            type: cc.Label
        },

        goldNum:{
            default: null,
            type: cc.Label
        },
        zuanshiNum:{
            default: null,
            type: cc.Label
        }
        
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {
        cc.log( globalManager.playerInfo ) 

        this.setPlayerInfo()
    },

    // update (dt) {},

    setPlayerInfo() {

        // this.headicon.spriteFrame = null

        this.nickName.string = globalManager.playerInfo.rname

        this.level.string = "等级：" + "传说"

        this.goldNum.string = globalManager.playerInfo.gold + ""

        this.zuanshiNum.string = globalManager.playerInfo.gold + ""

    },

    addGoldBtnClicked () {

        panelManager.createPanel( panelCfg.basePanel, ( err, panel )=>{ }, this.onde )

    },
    addZuanshiBtnClicked () {

        panelManager.createPanel( panelCfg.basePanel, ( err, panel )=>{ }, this.onde )
        
    },

});
