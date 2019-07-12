/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:03:32
 * @LastEditTime: 2019-07-12 10:18:39
 */

let BaseView = require('./BaseView');
let LabbyView = require('./LabbyView');
let UIManager = require('./common/manager/uiManager')
let LoadingView = require('./LoadingView')

let ResManager = require('../common/manager/resManager')
let CommonData = require('../common/dataModel/commonData')

let eventMgr = require('./common/utils/eventCustom');
let netMgr = require('./common/manager/networkManager')

let LoginView = cc.Class({

    extends: BaseView,

    properties: {
        
        heartbreakindex : 0,
        heartbreakfunc : null
    },

    statics: {
        className : "LoginView"
    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

        this.heartbreakfunc = ()=>{

            netMgr.getInstance().send("heartbreak", true, {username: "hongzap"}, (res)=>{
                cc.log(res);
            })
                    
        }
        this.schedule( this.heartbreakfunc, 2)
        
        this.heartbreakindex = eventMgr.getInstance().on( "heartbreak", (res)=>{
            cc.log(res);
        })

    },

    onDisable () {

        eventMgr.getInstance().off( 'heartbreak' , this.heartbreakindex)

        this.unschedule(  this.heartbreakfunc )

    },

    // update (dt) {},

    onGameStart () {

        let onProgress = (completedCount, totalCount, item)=>{

            let value = Math.round(completedCount/totalCount * 100);
            
        };

        UIManager.getInstance().openUI( LoadingView, 10, ()=>{

            UIManager.getInstance().openUI(LabbyView, 9, ()=>{

                let callback0 = cc.callFunc(()=>{
                    
                    UIManager.getInstance().closeUI(LoadingView);
                })

                let action0 = cc.fadeOut(1);

                let callback = cc.callFunc(()=>{
                    
                    UIManager.getInstance().closeUI(LoginView);

                }, this);

                let action = cc.sequence( cc.delayTime(1.2), callback0 , action0, callback);

                this.node.runAction(action);
                
            }, onProgress);
        })
      
    }
});

module.exports = LoginView