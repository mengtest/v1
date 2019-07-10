/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 16:03:32
 * @LastEditTime: 2019-07-10 17:00:58
 */
let CommonData = require('../common/dataModel/commonData')

let BaseView = cc.Class({

    extends: cc.Component,

    properties: {

        tag: {
            get() {
                return this.mTag;
            },
            set (value) {
                this.mTag = value;
            }
        },
        

    },

    statics: {
        
        className: "BaseView",
        
        getUrl(){
            return CommonData.PREFAB_UI_DIR + this.className;
        }
    },

    onDestroy() {
        cc.log( "Destroy: " + this.name )
    }

});

module.exports = BaseView;
