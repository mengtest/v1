/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 17:28:35
 * @LastEditTime: 2019-07-10 18:02:13
 */

let BasePop = require('./BasePop')

let pop1 = cc.Class({
    extends: BasePop,
    statics: {
        className : "pop1"
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

module.exports = pop1