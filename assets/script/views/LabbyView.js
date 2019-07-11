/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:35:14
 * @LastEditTime: 2019-07-11 17:21:31
 */
let BaseView = require('./BaseView');
let UIManager = require('../common/manager/uiManager')
let popView = require('./popView')
let eventMgr = require('./common/utils/eventCustom');

let LabbyView = cc.Class({

    extends: BaseView,

    statics: {
        className : "LabbyView"
    },

    properties: {
    
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

    },

    // update (dt) {},

    pop () {

        UIManager.getInstance().showPopView( popView, this.node )

    }


});
