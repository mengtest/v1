/*
 * @Author: Michael Zhang
 * @Date: 2019-07-17 13:50:19
 * @LastEditTime: 2019-07-22 13:41:42
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

        scrollView: {
            default: null,
            type: cc.ScrollView,
        },

        bbItem: {
            default: null,
            type: cc.Prefab,
        },
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {
        
       this.navChanged()
    },
    onDisable() {

     

    },

    start () {

    },

    // update (dt) {},

    navChanged ( selectedIndex ) {
  
        this.scrollView.content.removeAllChildren(true);

        for (let index = 0; index < 10; index++) {

            let bbItem = cc.instantiate( this.bbItem );
            
            this.scrollView.content.addChild( bbItem );
            
        }
    }
});
