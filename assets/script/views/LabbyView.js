/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:35:14
 * @LastEditTime: 2019-07-10 18:09:44
 */
let BaseView = require('./BaseView');
let UIManager = require('../common/manager/uiManager')
let pop1 = require('./pop1')

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

        UIManager.getInstance().showPopView( pop1, LabbyView )

    }


});
