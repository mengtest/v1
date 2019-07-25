/*
 * @Author: Michael Zhang
 * @Date: 2019-07-24 17:14:27
 * @LastEditTime: 2019-07-24 18:01:05
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
        
        text: {
            default: null,
            type: cc.Label
        }
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

    },

    // update (dt) {},
    
    setText( text , callback ) {
        
        this.text.string = text

        let moveby = cc.moveBy( 1.2, cc.v2(0, 200) ).easing(cc.easeInOut(1.2));;

        let end = cc.callFunc( ()=>{
            
            // this.node.destroy()>
            callback()

        } ) 

        this.node.runAction( cc.sequence( moveby , cc.fadeOut(0.1) , end ) )
    }

});
