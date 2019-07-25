/*
 * @Author: Michael Zhang
 * @Date: 2019-07-15 13:56:23
 * @LastEditTime: 2019-07-16 14:38:06
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
        _pic: null,


        waittime: {
            displayName:"等待时间", 
            tooltip:"等待开始的时间", 
            type: cc.Float,
            default: 2
        },
        roundtime:{
            displayName:"光效时间", 
            tooltip:"一次光效的时间", 
            type: cc.Float,
            default: 1.2
        },  
        delaytime:{
            displayName:"光效暂停时间", 
            tooltip:"一次光效后暂停的时间", 
            type: cc.Float,
            default: 5
        },
        loop:{
            displayName:"一直循环", 
            tooltip:"是否一直循环下去", 
            default: true
        },

        light:{
            displayName:"光效图片", 
            tooltip:"光效图片",
            type: cc.SpriteFrame, 
            default: null,
        },

    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {

        this._pic = this.node.getChildByName('lightpic');

        this._pic.getComponent(cc.Sprite).spriteFrame = this.light;
        this.node.getComponent(cc.Mask).spriteFrame = this.node.parent.getComponent(cc.Sprite).spriteFrame;

        this.resetGuang()

    },

    start () {

        this.scheduleOnce( ()=>{
            this.flash();
        } , this.waittime)

    },

    // update (dt) {},

    resetGuang() {

        this._pic.x = - this.node.getContentSize().width/2 - this._pic.getContentSize().width/2;
        this._pic.y = 0;
    },

    flash () {

        let lightSize = this._pic.getContentSize();
        let clipSize = this.node.getContentSize();

        let run = ()=>{
            let move = cc.moveTo( this.roundtime, cc.v2( clipSize.width/2 + lightSize.width/2, 0) )  
            move.easing( cc.easeSineIn  ( this.roundtime ) );
            let delay = cc.delayTime( this.delaytime );
            let endCall = cc.callFunc(()=>{
                if( this.loop ){
                    this.resetGuang();
                    run();
                }
            })
            this._pic.runAction( cc.sequence( move, delay, endCall ) );
        }
        run();
       
    },

    onDisable() {
        this.unscheduleAllCallbacks();
    }


});
