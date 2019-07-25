/*
 * @Author: Michael Zhang
 * @Date: 2019-07-08 17:33:35
 * @LastEditTime: 2019-07-24 14:10:56
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
        type: cc.String,
        indexe:null,

        ozide: null,
        nodeary: {
            default: [],
            type: cc.Node,
        },
        playCount: {
            default: [],
            type: cc.Integer,
        },
        await: {
            default: [],
            type: cc.Float,
        },

    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start() {
        this.ozide = 3;
        for (let i = 0; i < this.nodeary.length; i++) {
            this.ClickEvent(this.nodeary[i], i);
        }
        if (this.type=="DT") {
            this.PlayAnim();
        }else if (this.type=="SELECT") {
            this.indexe=0;
            this.orderPlay();
        }
        
    },
    PlayAnim: function () {
        var ide = util.random(0, this.nodeary.length);
        var count = util.random(this.playCount[0], this.playCount[1]);
        var anm = this.nodeary[ide].getComponent(cc.Animation);
        var anmPla = anm.play();
        anmPla.wrapMode = cc.WrapMode.Loop;
        anmPla.repeatCount = count;
        anm.on("finished", this.StopAnim, this);
    },
    StopAnim: function () {
        for (let i = 0; i < this.nodeary.length; i++) {
            this.nodeary[i].getComponent(cc.Animation).stop();
        }
        var suiji = util.random(this.await[0], this.await[1]);

        this.scheduleOnce(function () {
            this.PlayAnim();
        }, suiji);
    },

    orderPlay:function () {
        var anm = this.nodeary[this.indexe].getComponent(cc.Animation);
        anm.play();
        //anmPla.wrapMode = cc.WrapMode.Loop;
        //anmPla.repeatCount = 1;
        this.indexe++;
        if (this.indexe>=4) {
            this.indexe=0;
        }
        var dengdai=Math.random()+0.3;
        this.scheduleOnce(function () {
            this.orderPlay();
        },dengdai);
    },
    //点击事件
    ClickEvent: function (targ, index) {
        var tt = this;
        targ.on(cc.Node.EventType.TOUCH_START, function (event) {
            tt.ozide++;
            targ.parent.setSiblingIndex(tt.ozide);
        
            globalControl.changeScence( "roomselect", index )    

        });
    },
    // update (dt) {},
});
