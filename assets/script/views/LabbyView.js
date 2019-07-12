/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:35:14
 * @LastEditTime: 2019-07-12 10:15:03
 */
let BaseView = require('./BaseView');
let UIManager = require('../common/manager/uiManager')
let popView = require('./popView')
let eventMgr = require('./common/utils/eventCustom');
let ResMgr = require('../common/manager/resManager')
let CommonData = require('../common/dataModel/commonData')

let LabbyView = cc.Class({

    extends: BaseView,

    statics: {
        className : "LabbyView"
    },

    properties: {

        good: "dada"
    
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

        ResMgr.getInstance().loadAudioClip( CommonData.AUDIO_DIR + "fish_vocie13", ( ( asset )=>{

            cc.log( asset )

            cc.log( this.good )

        }).bind(this), cc.AudioClip)
    },

    // update (dt) {},

    pop () {

        UIManager.getInstance().showPopView( popView, this.node )

    }


});
