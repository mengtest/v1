/*
 * @Author: Michael Zhang
 * @Date: 2019-07-25 11:54:27
 * @LastEditTime: 2019-07-25 12:02:02
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

if( CC_EDITOR ) {

    // let data = "let hhdaff = 'a'"
    // Editor.assetdb.create( 'db://assets/foo/bar.js', data, function ( err, results ) {
    //     results.forEach(function ( result ) {
    //         // result.uuid
    //         // result.parentUuid
    //         // result.url
    //         // result.path
    //         // result.type
    //     });
    // });
}
