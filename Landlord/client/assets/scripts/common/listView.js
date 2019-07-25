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
    extends: cc.ScrollView,

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
        itemSize:cc.Size,
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {
        this.orgSize = new cc.Size(this.content.getContentSize().width,this.content.getContentSize().height);
        this.content.anchorY = 1.0;
        this.content.y = this.orgSize.height/2.0;
        this.totalHeight = 0;
        this.currSize = new cc.Size(this.content.getContentSize().width,this.content.getContentSize().height);
        this.count = 0;
    },
    start () {
        if(this._super){
            this._super();
        }

    },
    rest(){
        cc.log("this.orgSize="+this.orgSize);
        this.content.setContentSize(this.orgSize);
        this.totalHeight = 0;
        this.currSize.width = this.orgSize.width;
        this.currSize.height = this.orgSize.height;
        this.count = 0;        
    },
    addItem(item){
        this.count += 1;
        this.totalHeight += this.itemSize.height;
        if(this.currSize.height < this.totalHeight){
            this.currSize.height = this.totalHeight;
        }
        cc.log(this.currSize);
        this.content.setContentSize(this.currSize);
        item.setPosition(0,-this.itemSize.height/2.0 - (this.count - 1)*this.itemSize.height);
        this.content.addChild(item);
    },
    removeItem(){

    },
    removeAllItem(){
        this.content.removeAllChildren();
        this.rest();
    }
    // update (dt) {},
});
