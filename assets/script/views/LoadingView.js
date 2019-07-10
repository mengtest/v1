/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:03:32
 * @LastEditTime: 2019-07-10 16:47:33
 */

let BaseView = require('./BaseView');
let LabbyView = require('./LabbyView');
let UIManager = require('./common/manager/uiManager')

let LoadingView = cc.Class({

    extends: BaseView,

    properties: {
        
    },

    statics: {
        className : "LoadingView"
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

    },

    // update (dt) {},

    onGameStart () {

        let onProgress = (completedCount, totalCount, item)=>{

            let value = Math.round(completedCount/totalCount * 100);
            
        };

        UIManager.getInstance().openUI(LabbyView, 10, ()=>{

            let action0 = cc.fadeOut(1);

            let callback = cc.callFunc(()=>{
              
                UIManager.getInstance().closeUI(LoadingView);

            }, this);

            let action = cc.sequence(action0, callback);

            this.node.runAction(action);
            
        }, onProgress);
    }
});

module.exports = LoadingView