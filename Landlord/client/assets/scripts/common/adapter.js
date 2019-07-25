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
        adapterBig:{
            default:false,
            //type:cc.Boolean,
        },  
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {
        //var rectSize = cc.visibleRect.size;
        var designSize = cc.view.getDesignResolutionSize();
        //cc.log(rectSize);
        cc.log(designSize);
        var scalewidth = cc.visibleRect.width/designSize.width;
        var scaleHeight = cc.visibleRect.height/designSize.height;
        var bigScale = null;
        if(scalewidth > scaleHeight){
            bigScale = scalewidth/scaleHeight;
        }else{
            bigScale = scaleHeight/scalewidth;
        }
        if(this.adapterBig){
            this.node.setScale(this.node.scaleX*bigScale,this.node.scaleY*bigScale);
        }else{
            this.node.setScale(this.node.scaleX*1/bigScale,this.node.scaleY*1/bigScale);
        }
    },

    // update (dt) {},
});
