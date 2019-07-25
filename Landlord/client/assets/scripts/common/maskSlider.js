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
    extends: cc.Slider,

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
            sliderMask:{
                default:null,
                type:cc.Node,
            }
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

    },
    _updateHandlePosition () {
        // if (!this.handle) { return; }
        // var handlelocalPos;
        // if (this.direction === Direction.Horizontal) {
        //     handlelocalPos = cc.v2(-this.node.width * this.node.anchorX + this.progress * this.node.width, 0);
        // }
        // else {
        //     handlelocalPos = cc.v2(0, -this.node.height * this.node.anchorY + this.progress * this.node.height);
        // }
        // var worldSpacePos = this.node.convertToWorldSpaceAR(handlelocalPos);
        // this.handle.node.position = this.handle.node.parent.convertToNodeSpaceAR(worldSpacePos);
        if(this._super){
            this._super();
        }
        this._updateMaskSize();
    },
    _updateMaskSize(){
        if(this.direction == 0){
            this.sliderMask.setContentSize(this.progress * this.node.width,this.node.height);
        }else{
            this.sliderMask.setContentSize(this.node.width,this.progress * this.node.height);
        }
        
    },
    // update (dt) {},
});
