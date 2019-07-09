/*
 * @Author: Michael Zhang
 * @Date: 2019-07-09 18:10:37
 * @LastEditTime: 2019-07-09 18:15:17
 */

let ConfigManager = cc.Class(
{
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

    configContainerList: [],
    curLoadedCount: 0,

    loadAllConfig(callback) {

        this.loadConfig(FishConfigContainer, this.callback, callback);
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

    loadConfig(configClass, callback, arg)
    {
        let config = new configClass(callback, this, arg);
        config.tag = configClass;
        this.configContainerList.push(config);
    },

    callback(callback) {
      
        this.curLoadedCount += 1;
        if(this.configContainerList.length == this.curLoadedCount)
        {
            if(callback)
            {
                callback();
            }
        }
    }
})