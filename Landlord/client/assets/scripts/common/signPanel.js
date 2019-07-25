// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var util = require("../common/util")
cc.Class({
    extends: cc.Component,

    properties: {
        // foo: {
        //     // ATTRIBUTES:
        //     default: null,        // The default value will be used only when the component attaching
        //                           // to a node for the first time
        //     type: cc.SpriteFrame, // optional, default is typeof default
        //     serializable: true,   // optional, default is true
        // },
        // bar: {
        //     get () {
        //         return this._bar;
        //     },
        //     set (value) {
        //         this._bar = value;
        //     }
        // },
        dayList:{
            default:null,
            type:cc.Node
        },
        signOk:{
            default:null,
            type:cc.Node
        },
        okBtn:{
            default:null,
            type:cc.Node
        },
        signAtla:{
            default:null,
            type:cc.SpriteAtlas
        }
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {
        var listday = this.dayList.children;
        var k = 0;
        for(var i  in listday)
        {
            k++;
            listday[i].getChildByName("day").getComponent(cc.Label).string = "第"+k+"天";
            //9==金币，10==月卡，11==倍
            cc.log(listday[i].getChildByName("icon"));
            this.dayList.getChildByName(k.toString()).getChildByName("icon").getComponent(cc.Sprite).spriteFrame = this.signAtla.getSpriteFrame("9");
            var selectbtn = this.dayList.getChildByName(k.toString()).addComponent(cc.Button);  
            util.addClickEvent(selectbtn.node,this.node,"signPanel","selectbtn");
        }
        util.addClickEvent(this.okBtn,this.node,"signPanel","getOk");
    },
    //签到处理
    selectbtn:function(e,obj)
    {
        cc.log("------->"+obj.name);
        this.signOk.active = true;
    },
    getOk:function(e,obj)
    {
        this.signOk.active = false;
    },
    closePanel:function()
    {
        this.node.destroy(); 
       
    }
    // update (dt) {},
});
