/*
 * @Author: Michael Zhang
 * @Date: 2019-07-18 10:24:14
 * @LastEditTime: 2019-07-18 10:25:03
 */

cc.Class({
    extends: cc.Component,

    properties: {
        zIndex: {
            type: cc.Integer, //使用整型定义
            default: 0,            
            //使用notify函数监听属性变化
            notify(oldValue) {                
                //减少无效赋值
                if (oldValue === this.zIndex) {               
                    return;
                }
                this.node.zIndex = this.zIndex;
            }
        }
    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {
        this.node.zIndex = this.zIndex;
    },

    start () {

    },

    // update (dt) {},
});
