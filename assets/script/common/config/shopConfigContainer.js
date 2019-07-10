/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 11:20:15
 * @LastEditTime: 2019-07-10 13:50:13
 */

 let BaseConfigContainer = require('./BaseConfigContainer')
 let CommonData = require('../dataModel/commonData')

let ShopConfigContainer = cc.Class({

    extends: BaseConfigContainer,

    properties: {
        shopConfigData: [],
    },


    init (callback, caller, arg) {
        
        cc.loader.loadRes(CommonData.CONFIG_FILE_DIR + "shopConfig", (err, object)=>{
            if (err) {
                cc.log("load shopConfig.json err");
                cc.log(err);
            } else {
                object = object.json || object;
                for(var i in object) {
                    this.shopConfigData[i] = object[i];
                }
                if(callback) {
                    callback.call(caller, arg);
                }
            }
        }
        );
    },
   
    getShopConfigData() {
        return this.shopConfigData;
    }
})

module.exports = ShopConfigContainer;