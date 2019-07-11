/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 17:28:35
 * @LastEditTime: 2019-07-11 16:50:57
 */

let BasePop = require('./BasePop')

let popView = cc.Class({
    extends: BasePop,
    statics: {
        className : "popView"
    },
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
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

    },

    // update (dt) {},
    

});

module.exports = popView