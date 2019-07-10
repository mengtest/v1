/*
 * @Author: Michael Zhang
 * @Date: 2019-07-09 18:10:37
 * @LastEditTime: 2019-07-10 11:45:57
 */

let ShopConfigContainer = require('../config/shopConfigContainer')

let ConfigManager = cc.Class({

    properties: {

        configContainerList: [],
        curLoadedCount : 0,
    },

    statics:{

        instance: null,

        getInstance(){
            if(this.instance == null)
            {
                this.instance = new ConfigManager();
            }
            return this.instance;
        },
    },

  

    loadAllConfig(callback) {

        this.loadConfig(ShopConfigContainer, this.callback, callback);
    },

    getConfig(configClass) {

        for(let i = 0; i < this.configContainerList.length; ++i)
        {
            if(this.configContainerList[i].tag == configClass)
            {
                return this.configContainerList[i];
            }
        }
        return null;
    },

    loadConfig(configClass, callback, arg) {
        
        let config = new configClass();
        config.init(callback, this, arg)
        config.tag = configClass;
        this.configContainerList.push(config);
    },

    callback(callback) {
      
        this.curLoadedCount += 1;
        if(this.configContainerList.length == this.curLoadedCount) {
            if(callback) {
                callback();
            }
        }
    }
})